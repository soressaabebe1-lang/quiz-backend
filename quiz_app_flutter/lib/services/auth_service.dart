import '../config/constants.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _client = ApiClient();

  /// Returns the raw response body on success. Throws ApiException on
  /// failure (e.g. name already taken, incomplete data).
  Future<Map<String, dynamic>> register({
    required String name,
    required int age,
    required String password,
  }) async {
    return _client.post(
      ApiConfig.register,
      {"name": name, "age": age, "password": password},
      auth: false,
    );
  }

  /// Logs in, then persists the token + user_id to local storage so
  /// subsequent requests are authenticated automatically.
  Future<void> login({required String name, required String password}) async {
    final body = await _client.post(
      ApiConfig.login,
      {"name": name, "password": password},
      auth: false,
    );

    final token = body['token'] as String?;
    final userId = body['user_id'] as int?;
    final isAdmin = body['is_admin'] as bool? ?? false;

    if (token == null || userId == null) {
      throw ApiException(500, "Login response missing token or user_id");
    }

    await _client.saveSession(token, userId, isAdmin);
  }

  Future<void> logout() async {
    await _client.clearSession();
  }

  Future<bool> isLoggedIn() => _client.isLoggedIn();

  Future<int?> currentUserId() => _client.getUserId();

  Future<bool> isAdmin() => _client.getIsAdmin();
}
