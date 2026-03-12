import '../core/config/api_config.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  const AuthService();

  static final _api = ApiClient.instance;

  /// Register with email & password. Returns [UserModel] on success.
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
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
    final res = await _api.post(
      ApiConfig.login,
      {'email': email, 'password': password},
      auth: false,
    );
    return _handleAuthResponse(res);
  }

  /// Login with Google ID token. Backend verifies token and returns JWTs.
  Future<AuthResult> loginWithGoogle(String idToken) async {
    final res = await _api.post(
      ApiConfig.googleAuth,
      {'id_token': idToken},
      auth: false,
    );
    return _handleAuthResponse(res);
  }

  /// Fetch the currently authenticated user's profile.
  Future<UserModel?> getMe() async {
    final res = await _api.get(ApiConfig.me);
    if (res.ok && res.data is Map) {
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    }
    return null;
  }

  /// Logout: clear stored tokens client-side.
  Future<void> logout() => _api.clearTokens();

  /// Whether the client currently has a stored access token.
  Future<bool> hasSession() async {
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
}

class AuthResult {
  final UserModel? user;
  final String? error;
  const AuthResult({this.user, this.error});
  bool get ok => user != null && error == null;
}
