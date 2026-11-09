import 'dart:convert';

import '../../../../core/constants/api_config.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';
import '../repositories/secure_storage_service.dart';

class AuthRepository {
  final SecureStorageService _storage;

  AuthRepository(this._storage);

  /// POST /auth/register. Does NOT log the user in.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await ApiClient.post(
      Uri.parse(ApiConfig.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    return UserModel.fromJson(unwrapMap(response));
  }

  /// POST /auth/login — expects `data: {token, user}`.
  Future<({LoginResponse tokens, UserModel user})> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      Uri.parse(ApiConfig.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = unwrapMap(response);

    final tokens = LoginResponse.fromJson(data);
    final userJson = data['user'];
    if (userJson is! Map) {
      throw const FormatException('Login response did not contain a user');
    }
    final user = UserModel.fromJson(Map<String, dynamic>.from(userJson));

    await _storage.saveTokens(tokens);
    await _storage.saveUser(user);

    return (tokens: tokens, user: user);
  }

  Future<UserModel> fetchProfile(String accessToken) async {
    final response = await ApiClient.get(
      Uri.parse(ApiConfig.profile),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    final user = UserModel.fromJson(unwrapMap(response));
    await _storage.saveUser(user);
    return user;
  }

  Future<UserModel> updateProfile(String accessToken, UserModel user) async {
    final response = await ApiClient.put(
      Uri.parse(ApiConfig.profile),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(user.toUpdatePayload()),
    );

    final updated = UserModel.fromJson(unwrapMap(response));
    await _storage.saveUser(updated);
    return updated;
  }

  Future<({LoginResponse tokens, UserModel user})?>
  loadPersistedSession() async {
    final tokens = await _storage.readTokens();
    final user = await _storage.readUser();
    if (tokens == null || user == null) return null;
    return (tokens: tokens, user: user);
  }

  Future<void> logout(String accessToken) async {
    try {
      await ApiClient.post(
        Uri.parse(ApiConfig.logout),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
    } catch (_) {
      // ignore — we're clearing local state either way
    }
    await _storage.clearTokens();
  }
}
