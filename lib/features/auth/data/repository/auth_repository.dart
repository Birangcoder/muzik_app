import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_config.dart';
import '../model/user_model.dart';
import '../model/login_response.dart';
import '../repository/secure_storage_service.dart';

/// Talks to the music-api PHP backend (register.php / login.php only —
/// no separate "current user" endpoint exists, so we don't call one).
///
/// Changes from the original:
/// - No more flutter_web_auth_2 / browser redirect flow — our API is a
///   plain email+password POST, not OAuth2 authorization-code.
/// - No client_id/client_secret, no PKCE state param, no redirect URI —
///   none of that applies to a first-party API you own.
/// - refreshToken() is gone. The JWT has no refresh flow: when
///   isExpired is true, the only option is to call login() again.
/// - fetchCurrentUser() is gone too — login.php's response already
///   includes the full user object, so login() returns both the token
///   and the user in one call. That user is cached locally (see
///   SecureStorageService) so it can be restored on app relaunch
///   without hitting the network again.
class AuthRepository {
  final SecureStorageService _storage;

  AuthRepository(this._storage);

  /// POST /register.php — create a new account.
  /// Note: registering does NOT log the user in — call login() after,
  /// same as the API's behavior (register.php returns no token).
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    debugPrint("URL: ${Uri.parse(ApiConfig.register)}");
    debugPrint("Status: ${response.statusCode}");
    debugPrint("Body: ${response.body}");
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201) {
      throw Exception(body['error'] ?? 'Registration failed');
    }
    return UserModel.fromJson(body['user'] as Map<String, dynamic>);
  }

  /// POST /login.php — returns both the session token and the user
  /// profile in a single response. Both get persisted locally.
  Future<({LoginResponse tokens, UserModel user})> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(body['error'] ?? 'Login failed');
    }

    final tokens = LoginResponse.fromJson(body);
    final user = UserModel.fromJson(body['user'] as Map<String, dynamic>);

    await _storage.saveTokens(tokens);
    await _storage.saveUser(user);

    return (tokens: tokens, user: user);
  }

  /// Rehydrate a previous session from local storage on app launch.
  /// Returns null if there's nothing saved, or if the saved token has
  /// already expired (caller should route to sign-in either way).
  Future<({LoginResponse tokens, UserModel user})?>
  loadPersistedSession() async {
    final tokens = await _storage.readTokens();
    final user = await _storage.readUser();
    if (tokens == null || user == null) return null;
    return (tokens: tokens, user: user);
  }

  Future<void> logout() => _storage.clearTokens();
}
