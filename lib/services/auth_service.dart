import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/api_config.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  const AuthService();

  static final _api = ApiClient.instance;
  static const _useLocalAuth = bool.fromEnvironment(
    'USE_LOCAL_AUTH',
    defaultValue: true,
  );

  static const _localUsersKey = 'local_auth_users';
  static const _localSessionUserIdKey = 'local_auth_session_user_id';

  /// Register with email & password. Returns [UserModel] on success.
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_useLocalAuth) {
      return _registerLocal(name: name, email: email, password: password);
    }

    final res = await _api.post(
      ApiConfig.register,
      {'name': name, 'email': email, 'password': password},
      auth: false,
    );
    return _handleAuthResponse(res);
  }

  /// Login with email & password.
  Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    if (_useLocalAuth) {
      return _loginLocal(email: email, password: password);
    }

    final res = await _api.post(
      ApiConfig.login,
      {'email': email, 'password': password},
      auth: false,
    );
    return _handleAuthResponse(res);
  }

  /// Login with Google ID token. Backend verifies token and returns JWTs.
  Future<AuthResult> loginWithGoogle(String idToken) async {
    if (_useLocalAuth) {
      return const AuthResult(
        error: 'Google login requires backend configuration.',
      );
    }

    final res = await _api.post(
      ApiConfig.googleAuth,
      {'id_token': idToken},
      auth: false,
    );
    return _handleAuthResponse(res);
  }

  /// Fetch the currently authenticated user's profile.
  Future<UserModel?> getMe() async {
    if (_useLocalAuth) {
      return _getCurrentLocalUser();
    }

    final res = await _api.get(ApiConfig.me);
    if (res.ok && res.data is Map) {
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    }
    return null;
  }

  /// Logout: clear stored tokens client-side.
  Future<void> logout() async {
    if (_useLocalAuth) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localSessionUserIdKey);
      return;
    }
    await _api.clearTokens();
  }

  /// Whether the client currently has a stored access token.
  Future<bool> hasSession() async {
    if (_useLocalAuth) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_localSessionUserIdKey) != null;
    }

    final token = await _api.accessToken;
    return token != null;
  }

  // ── Private ───────────────────────────────────────────────────────────────

  AuthResult _handleAuthResponse(ApiResponse res) {
    if (res.ok && res.data is Map) {
      final data = res.data as Map<String, dynamic>;
      final user = UserModel.fromJson(
          data['user'] as Map<String, dynamic>? ?? data);
      _api.saveTokens(
        accessToken: data['access_token'] as String? ?? '',
        refreshToken: data['refresh_token'] as String? ?? '',
      );
      return AuthResult(user: user);
    }
    return AuthResult(error: res.errorMessage ?? 'Authentication failed');
  }

  Future<AuthResult> _registerLocal({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _readLocalUsers();
    final duplicate = users.any(
      (u) => ((u['email'] as String?) ?? '').toLowerCase() == normalizedEmail,
    );
    if (duplicate) {
      return const AuthResult(error: 'An account with this email already exists.');
    }

    final userId = DateTime.now().millisecondsSinceEpoch.toString();
    final user = UserModel(
      id: userId,
      fullName: name,
      email: normalizedEmail,
      createdAt: DateTime.now(),
      role: 'user',
      credits: 10,
    );

    users.add({
      'password': password,
      'user': user.toJson(),
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localUsersKey, jsonEncode(users));
    await prefs.setString(_localSessionUserIdKey, userId);
    return AuthResult(user: user);
  }

  Future<AuthResult> _loginLocal({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final users = await _readLocalUsers();

    for (final row in users) {
      final storedUser = row['user'] as Map<String, dynamic>?;
      final storedEmail = ((storedUser?['email'] as String?) ?? '').toLowerCase();
      if (storedEmail == normalizedEmail && row['password'] == password) {
        final user = UserModel.fromJson(storedUser ?? <String, dynamic>{});
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_localSessionUserIdKey, user.id ?? '');
        return AuthResult(user: user);
      }
    }

    return const AuthResult(error: 'Invalid email or password.');
  }

  Future<UserModel?> _getCurrentLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionUserId = prefs.getString(_localSessionUserIdKey);
    if (sessionUserId == null || sessionUserId.isEmpty) return null;

    final users = await _readLocalUsers();
    for (final row in users) {
      final storedUser = row['user'] as Map<String, dynamic>?;
      if ((storedUser?['id'] as String?) == sessionUserId) {
        return UserModel.fromJson(storedUser ?? <String, dynamic>{});
      }
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _readLocalUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_localUsersKey);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <Map<String, dynamic>>[];
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }
}

class AuthResult {
  final UserModel? user;
  final String? error;
  const AuthResult({this.user, this.error});
  bool get ok => user != null && error == null;
}
