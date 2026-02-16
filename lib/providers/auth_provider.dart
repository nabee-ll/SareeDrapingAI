import 'package:flutter/material.dart';
import '../models/user_model.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

enum AuthMode { login, register }

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  AuthMode _authMode = AuthMode.login;
  UserModel? _user;
  String? _errorMessage;
  bool _isOtpSent = false;
  String _loginMethod = 'email'; // 'email', 'phone'

  AuthState get state => _state;
  AuthMode get authMode => _authMode;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isOtpSent => _isOtpSent;
  String get loginMethod => _loginMethod;
  bool get isAuthenticated => _state == AuthState.authenticated;

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

  Future<bool> loginWithEmail(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 2));

      _user = UserModel(
        id: '1',
        email: email,
        fullName: 'Test User',
        role: 'user',
      );
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Login failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerWithEmail(
      String name, String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 2));

      _user = UserModel(
        id: '1',
        email: email,
        fullName: name,
        role: 'user',
      );
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Registration failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendOtp(String phone) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 2));

      _isOtpSent = true;
      _state = AuthState.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'Failed to send OTP. Please try again.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 2));

      _user = UserModel(
        id: '1',
        phone: phone,
        fullName: 'Phone User',
        role: 'user',
      );
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = 'OTP verification failed.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithSocial(String provider) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: Replace with actual social login
      await Future.delayed(const Duration(seconds: 2));

      _user = UserModel(
        id: '1',
        email: '$provider@example.com',
        fullName: '$provider User',
        role: 'user',
      );
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = '$provider login failed.';
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _user = null;
    _state = AuthState.unauthenticated;
    _isOtpSent = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
