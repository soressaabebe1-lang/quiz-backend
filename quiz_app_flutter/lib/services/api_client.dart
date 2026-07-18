import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Thrown for any non-2xx response. Carries the status code and whatever
/// message the backend sent, since the backend is inconsistent about using
/// "message" vs "msg" vs "status" for errors — normalized here into one
/// field so the UI layer only has to handle one shape.
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => "ApiException($statusCode): $message";
}

class ApiClient {
  static const _tokenKey = "auth_token";
  static const _userIdKey = "user_id";
  static const _isAdminKey = "is_admin";

  Future<void> saveSession(String token, int userId, bool isAdmin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setBool(_isAdminKey, isAdmin);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_isAdminKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  Future<bool> getIsAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isAdminKey) ?? false;
  }

  Future<bool> isLoggedIn() async => (await getToken()) != null;

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {"Content-Type": "application/json"};
    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }
    return headers;
  }

  /// Extracts a human-readable message no matter which key the backend
  /// used ("message", "msg", or flask-jwt-extended's own "msg" on 401s).
  String _extractMessage(Map<String, dynamic> body, int statusCode) {
    return (body['message'] ?? body['msg'] ?? "Request failed ($statusCode)")
        .toString();
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) return {};
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, dynamic>> get(String url, {bool auth = true}) async {
    final res = await http.get(Uri.parse(url), headers: await _headers(auth: auth));
    final body = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw ApiException(res.statusCode, _extractMessage(body, res.statusCode));
  }

  Future<Map<String, dynamic>> post(
    String url,
    dynamic data, {
    bool auth = true,
  }) async {
    final res = await http.post(
      Uri.parse(url),
      headers: await _headers(auth: auth),
      body: jsonEncode(data),
    );
    final body = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw ApiException(res.statusCode, _extractMessage(body, res.statusCode));
  }

  Future<Map<String, dynamic>> put(
    String url,
    dynamic data, {
    bool auth = true,
  }) async {
    final res = await http.put(
      Uri.parse(url),
      headers: await _headers(auth: auth),
      body: jsonEncode(data),
    );
    final body = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw ApiException(res.statusCode, _extractMessage(body, res.statusCode));
  }

  Future<Map<String, dynamic>> delete(String url, {bool auth = true}) async {
    final res = await http.delete(Uri.parse(url), headers: await _headers(auth: auth));
    final body = _decode(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    throw ApiException(res.statusCode, _extractMessage(body, res.statusCode));
  }
}
