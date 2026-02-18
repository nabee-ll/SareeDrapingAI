import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

enum AuthMode { login, register }

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthState _state = AuthState.initial;
  AuthMode _authMode = AuthMode.login;
  UserModel? _user;
  String? _errorMessage;
  bool _isOtpSent = false;
  String _loginMethod = 'email';
  String? _verificationId;
  int? _resendToken;

  AuthState get state => _state;
  AuthMode get authMode => _authMode;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isOtpSent => _isOtpSent;
  String get loginMethod => _loginMethod;
  bool get isAuthenticated => _state == AuthState.authenticated;

  AuthProvider() {
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        _user = await _firestoreService.getUser(firebaseUser.uid);
        _user ??= _userFromFirebase(firebaseUser);
        _state = AuthState.authenticated;
      } else {
        _user = null;
        _state = AuthState.unauthenticated;
      }
      notifyListeners();
    });
  }

  void setAuthMode(AuthMode mode) {
    _authMode = mode;
    _errorMessage = null;
    notifyListeners();
  }

  void setLoginMethod(String method) {
    _loginMethod = method;
    _isOtpSent = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  UserModel _userFromFirebase(User firebaseUser, {String? name}) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email,
      phone: firebaseUser.phoneNumber,
      fullName: name ?? firebaseUser.displayName ?? 'User',
      avatarUrl: firebaseUser.photoURL,
      role: 'user',
      createdAt: DateTime.now(),
      credits: 0,
    );
  }

  Future<UserModel> _saveOrFetch(User firebaseUser, {String? name}) async {
    UserModel? existing = await _firestoreService.getUser(firebaseUser.uid);
    if (existing != null) return existing;
    final newUser = _userFromFirebase(firebaseUser, name: name);
    await _firestoreService.saveUser(newUser);
    return newUser;
  }

  //  Email / Password 

  Future<bool> loginWithEmail(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      _user = await _saveOrFetch(result.user!);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _state = AuthState.error;
      _errorMessage = _authMsg(e.code);
      notifyListeners();
      return false;
    } catch (_) {
      _state = AuthState.error;
      _errorMessage = 'Login failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerWithEmail(String name, String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await result.user!.updateDisplayName(name);
      _user = await _saveOrFetch(result.user!, name: name);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _state = AuthState.error;
      _errorMessage = _authMsg(e.code);
      notifyListeners();
      return false;
    } catch (_) {
      _state = AuthState.error;
      _errorMessage = 'Registration failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  //  Phone OTP 

  Future<bool> sendOtp(String phone) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    final formatted = phone.startsWith('+') ? phone : '+91$phone';
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: formatted,
        forceResendingToken: _resendToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential cred) async {
          try {
            final r = await _auth.signInWithCredential(cred);
            _user = await _saveOrFetch(r.user!);
            _state = AuthState.authenticated;
            notifyListeners();
          } catch (_) {}
        },
        verificationFailed: (FirebaseAuthException e) {
          _state = AuthState.error;
          _errorMessage = _authMsg(e.code);
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _isOtpSent = true;
          _state = AuthState.unauthenticated;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return true;
    } on FirebaseAuthException catch (e) {
      _state = AuthState.error;
      _errorMessage = _authMsg(e.code);
      notifyListeners();
      return false;
    } catch (_) {
      _state = AuthState.error;
      _errorMessage = 'Failed to send OTP. Check the phone number.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    if (_verificationId == null) {
      _errorMessage = 'Session expired. Please request OTP again.';
      notifyListeners();
      return false;
    }
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!, smsCode: otp);
      final result = await _auth.signInWithCredential(credential);
      _user = await _saveOrFetch(result.user!);
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _state = AuthState.error;
      _errorMessage = _authMsg(e.code);
      notifyListeners();
      return false;
    } catch (_) {
      _state = AuthState.error;
      _errorMessage = 'OTP verification failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  //  Social 

  Future<bool> loginWithSocial(String provider) async {
    switch (provider) {
      case 'Google':   return _loginGoogle();
      case 'Apple':    return _loginApple();
      case 'Facebook': return _loginFacebook();
      default:
        _errorMessage = 'Unknown provider.';
        notifyListeners();
        return false;
    }
  }

  Future<bool> _loginGoogle() async {
    _state = AuthState.loading; _errorMessage = null; notifyListeners();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) { _state = AuthState.unauthenticated; notifyListeners(); return false; }
      final googleAuth = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      final result = await _auth.signInWithCredential(cred);
      _user = await _saveOrFetch(result.user!, name: googleUser.displayName);
      _state = AuthState.authenticated; notifyListeners(); return true;
    } on FirebaseAuthException catch (e) {
      _state = AuthState.error; _errorMessage = _authMsg(e.code); notifyListeners(); return false;
    } catch (_) {
      _state = AuthState.error; _errorMessage = 'Google sign-in failed.'; notifyListeners(); return false;
    }
  }

  Future<bool> _loginApple() async {
    _state = AuthState.loading; _errorMessage = null; notifyListeners();
    try {
      final appleCred = await SignInWithApple.getAppleIDCredential(
          scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName]);
      final oauthCred = OAuthProvider('apple.com').credential(
          idToken: appleCred.identityToken, accessToken: appleCred.authorizationCode);
      final result = await _auth.signInWithCredential(oauthCred);
      final name = [appleCred.givenName ?? '', appleCred.familyName ?? '']
          .where((s) => s.isNotEmpty).join(' ');
      _user = await _saveOrFetch(result.user!, name: name.isNotEmpty ? name : null);
      _state = AuthState.authenticated; notifyListeners(); return true;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) { _state = AuthState.unauthenticated; notifyListeners(); return false; }
      _state = AuthState.error; _errorMessage = 'Apple sign-in failed.'; notifyListeners(); return false;
    } catch (_) {
      _state = AuthState.error; _errorMessage = 'Apple sign-in failed.'; notifyListeners(); return false;
    }
  }

  Future<bool> _loginFacebook() async {
    _state = AuthState.loading; _errorMessage = null; notifyListeners();
    try {
      final loginResult = await FacebookAuth.instance.login();
      if (loginResult.status == LoginStatus.cancelled) { _state = AuthState.unauthenticated; notifyListeners(); return false; }
      if (loginResult.status != LoginStatus.success) {
        _state = AuthState.error; _errorMessage = loginResult.message ?? 'Facebook sign-in failed.'; notifyListeners(); return false;
      }
      final fbCred = FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
      final result = await _auth.signInWithCredential(fbCred);
      _user = await _saveOrFetch(result.user!);
      _state = AuthState.authenticated; notifyListeners(); return true;
    } on FirebaseAuthException catch (e) {
      _state = AuthState.error; _errorMessage = _authMsg(e.code); notifyListeners(); return false;
    } catch (_) {
      _state = AuthState.error; _errorMessage = 'Facebook sign-in failed.'; notifyListeners(); return false;
    }
  }

  //  Sign Out 

  Future<void> logout() async {
    await Future.wait([_auth.signOut(), _googleSignIn.signOut()]);
    _user = null; _state = AuthState.unauthenticated;
    _isOtpSent = false; _verificationId = null; _errorMessage = null;
    notifyListeners();
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try { await _auth.sendPasswordResetEmail(email: email); return true; } catch (_) { return false; }
  }

  //  Error messages 

  String _authMsg(String code) {
    const map = {
      'user-not-found': 'No account found. Please register first.',
      'wrong-password': 'Incorrect password. Please try again.',
      'email-already-in-use': 'This email is already registered.',
      'invalid-email': 'Please enter a valid email address.',
      'weak-password': 'Password is too weak. Use at least 6 characters.',
      'too-many-requests': 'Too many attempts. Please wait and try again.',
      'invalid-verification-code': 'Incorrect OTP. Please check and try again.',
      'invalid-phone-number': 'Invalid phone number. Include country code (+91).',
      'session-expired': 'OTP expired. Please request a new one.',
      'account-exists-with-different-credential':
          'Account exists with a different sign-in method.',
      'network-request-failed': 'Network error. Check your connection.',
    };
    return map[code] ?? 'Authentication failed ($code). Please try again.';
  }
}
