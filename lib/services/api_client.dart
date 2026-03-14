import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/config/api_config.dart';

/// Thin HTTP client that automatically attaches the JWT access token and
/// handles 401 → token refresh logic.
class ApiClient {
  ApiClient._internal();
  static final ApiClient instance = ApiClient._internal();

  final _storage = const FlutterSecureStorage();
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  // ── Token Storage ──────────────────────────────────────────────────────────

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
    ]);
  }

  Future<String?> get accessToken => _storage.read(key: _accessKey);
  Future<String?> get refreshTokenValue => _storage.read(key: _refreshKey);

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
    ]);
  }

  // ── HTTP Helpers ──────────────────────────────────────────────────────────

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = await accessToken;
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ── Public Methods ────────────────────────────────────────────────────────

  static const _timeout = Duration(seconds: 15);

  Future<ApiResponse> get(String path) async {
    final res = await http
        .get(_uri(path), headers: await _headers())
        .timeout(_timeout);
    if (res.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final retry = await http
            .get(_uri(path), headers: await _headers())
            .timeout(_timeout);
        return ApiResponse(retry.statusCode, _decode(retry.body));
      }
    }
    return ApiResponse(res.statusCode, _decode(res.body));
  }

  Future<ApiResponse> post(String path, Map<String, dynamic> body,
      {bool auth = true}) async {
    final res = await http
        .post(
          _uri(path),
          headers: await _headers(auth: auth),
          body: jsonEncode(body),
        )
        .timeout(_timeout);
    if (res.statusCode == 401 && auth) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final retry = await http
            .post(
              _uri(path),
              headers: await _headers(),
              body: jsonEncode(body),
            )
            .timeout(_timeout);
        return ApiResponse(retry.statusCode, _decode(retry.body));
      }
    }
    return ApiResponse(res.statusCode, _decode(res.body));
  }

  Future<ApiResponse> delete(String path) async {
    final res = await http
        .delete(_uri(path), headers: await _headers())
        .timeout(_timeout);
    if (res.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final retry = await http
            .delete(_uri(path), headers: await _headers())
            .timeout(_timeout);
        return ApiResponse(retry.statusCode, _decode(retry.body));
      }
    }
    return ApiResponse(res.statusCode, _decode(res.body));
  }

  Future<ApiResponse> multipartPost(
      String path, Map<String, String> fields, List<MultipartFile> files) async {
    final token = await accessToken;
    final request = http.MultipartRequest('POST', _uri(path));
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);
    for (final f in files) {
      request.files.add(http.MultipartFile.fromBytes(
        f.field,
        f.bytes,
        filename: f.filename,
      ));
    }
    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    return ApiResponse(streamed.statusCode, _decode(body));
  }

  // ── Token Refresh ─────────────────────────────────────────────────────────

  Future<bool> _tryRefresh() async {
    final token = await refreshTokenValue;
    if (token == null) return false;
    try {
      final res = await http.post(
        _uri(ApiConfig.refreshToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': token}),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        await saveTokens(
          accessToken: data['access_token'] as String,
          refreshToken: data['refresh_token'] as String,
        );
        return true;
      }
      await clearTokens();
      return false;
    } catch (_) {
      return false;
    }
  }

  dynamic _decode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }
}

class ApiResponse {
  final int status;
  final dynamic data;

  ApiResponse(this.status, this.data);

  bool get ok => status >= 200 && status < 300;
  String? get errorMessage {
    if (ok) return null;
    if (data is Map) return data['message']?.toString();
    return 'Request failed ($status)';
  }
}

class MultipartFile {
  final String field;
  final List<int> bytes;
  final String filename;
  const MultipartFile(
      {required this.field, required this.bytes, required this.filename});
}
