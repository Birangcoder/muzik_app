import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_config.dart';
import '../../../../core/constants/api_exception.dart';
import '../model/user_model.dart';
import '../model/login_response.dart';
import '../repository/secure_storage_service.dart';

/// Talks to MusicAPI V2's auth + profile routes.
///
/// Changes from the previous version (the flat music-api PHP project):
/// - Routes are pretty URLs under a base path (ApiConfig.baseUrl +
///   '/auth/...'), not standalone .php files.
/// - Every response is wrapped in {success, data} / {success:false,
///   message, errors} — unwrapData() handles that in one place instead
///   of each method re-parsing it.
/// - register() now requires password_confirmation — the server
///   validates it and returns a 422-style {success:false, errors:{...}}
///   if it's missing or doesn't match, which surfaces as an
///   ApiException with fieldErrors populated.
/// - logout() is now a real server call (POST /auth/logout, Bearer
///   token required) instead of just a local storage wipe. We still
///   clear local storage even if the network call fails, so the user
///   is never stuck "logged in" locally after tapping logout.
/// - fetchCurrentUser()/me.php is replaced by GET /profile, which
///   returns the fuller UserModel shape (country, birth_date, gender,
///   bio) documented in section 17.
class AuthRepository {
  final SecureStorageService _storage;

  AuthRepository(this._storage);

  /// POST /auth/register.
  /// Does NOT log the user in — the API returns the created user only,
  /// no token. Call login() right after, same as before.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    final data = unwrapData(response) as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }

  /// POST /auth/login — expects `data: {token, user}`.
  Future<({LoginResponse tokens, UserModel user})> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = unwrapData(response) as Map<String, dynamic>;

    final tokens = LoginResponse.fromJson(data);
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

    await _storage.saveTokens(tokens);
    await _storage.saveUser(user);

    return (tokens: tokens, user: user);
  }

  /// GET /profile — the fullest user shape, used to refresh cached data
  /// (e.g. after editing the profile, or to repopulate fields that
  /// login/register didn't return).
  Future<UserModel> fetchProfile(String accessToken) async {
    final response = await http.get(
      Uri.parse(ApiConfig.profile),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    final data = unwrapData(response) as Map<String, dynamic>;
    final user = UserModel.fromJson(data);
    await _storage.saveUser(user);
    return user;
  }

  /// PUT /profile
  Future<UserModel> updateProfile(String accessToken, UserModel user) async {
    final response = await http.put(
      Uri.parse(ApiConfig.profile),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(user.toUpdatePayload()),
    );

    final data = unwrapData(response) as Map<String, dynamic>;
    final updated = UserModel.fromJson(data);
    await _storage.saveUser(updated);
    return updated;
  }

  /// Rehydrate a previous session from local storage on app launch —
  /// no network call, same as before.
  Future<({LoginResponse tokens, UserModel user})?>
  loadPersistedSession() async {
    final tokens = await _storage.readTokens();
    final user = await _storage.readUser();
    if (tokens == null || user == null) return null;
    return (tokens: tokens, user: user);
  }

  /// POST /auth/logout, then clear local storage regardless of whether
  /// the network call succeeded (e.g. token already expired server-side
  /// shouldn't block the user from logging out locally).
  Future<void> logout(String accessToken) async {
    try {
      await http.post(
        Uri.parse(ApiConfig.logout),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
    } catch (_) {
      // ignore — we're clearing local state either way
    }
    await _storage.clearTokens();
  }
}
