import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = const AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  AuthState _state = AuthState.initial;
  UserModel? _user;
  String? _errorMessage;
  String _loginMethod = 'email';

  AuthState get state => _state;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  String get loginMethod => _loginMethod;
  bool get isAuthenticated => _state == AuthState.authenticated;

  AuthProvider() {
    _tryRestoreSession();
  }

  void setLoginMethod(String method) {
    _loginMethod = method;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Session Restore ───────────────────────────────────────────────────────

  Future<void> _tryRestoreSession() async {
    final hasSession = await _authService.hasSession();
    if (!hasSession) {
      _state = AuthState.unauthenticated;
      notifyListeners();
      return;
    }
    _state = AuthState.loading;
    notifyListeners();
    try {
      final me = await _authService.getMe();
      if (me != null) {
        _user = me;
        _state = AuthState.authenticated;
      } else {
        await _authService.logout();
        _state = AuthState.unauthenticated;
      }
    } catch (_) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // ── Email / Password ──────────────────────────────────────────────────────

  Future<bool> loginWithEmail(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _authService.loginWithEmail(
        email: email,
        password: password,
      );
      if (result.ok) return _handleResult(result);
      _state = AuthState.error;
      _errorMessage = result.error ?? 'Login failed. Please try again.';
      notifyListeners();
      return false;
    } catch (_) {
      _state = AuthState.error;
      _errorMessage = 'Login failed. Please try again.';
    }
    notifyListeners();
    return false;
  }

  Future<bool> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      return _handleResult(result);
    } catch (_) {
      _state = AuthState.error;
      _errorMessage = 'Registration failed. Please check your connection and try again.';
    }
    notifyListeners();
    return false;
  }

  // ── Google OAuth ──────────────────────────────────────────────────────────

  Future<bool> loginWithSocial(String provider) async {
    if (provider != 'Google') return false;
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _state = AuthState.unauthenticated;
        notifyListeners();
        return false;
      }
      final auth = await googleUser.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        _state = AuthState.error;
        _errorMessage = 'Google sign-in failed. Missing token.';
        notifyListeners();
        return false;
      }
      try {
        final result = await _authService.loginWithGoogle(idToken);
        if (result.ok) return _handleResult(result);
        _state = AuthState.error;
        _errorMessage =
            result.error ?? 'Google sign-in failed. Please try again.';
        notifyListeners();
        return false;
      } catch (_) {
        _state = AuthState.error;
        _errorMessage = 'Google sign-in failed. Please try again.';
      }
      notifyListeners();
      return false;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Google sign-in failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await _authService.logout();
    await _googleSignIn.signOut().catchError((_) => null);
    _user = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  // ── Private ───────────────────────────────────────────────────────────────

  bool _handleResult(AuthResult result) {
    if (result.ok) {
      _user = result.user;
      _state = AuthState.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _state = AuthState.error;
      _errorMessage = result.error;
      notifyListeners();
      return false;
    }
  }
}
