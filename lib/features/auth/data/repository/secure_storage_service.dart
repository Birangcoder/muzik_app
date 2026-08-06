import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/login_response.dart';
import '../model/user_model.dart';

class SecureStorageService {
  static const _tokenKey = 'auth_session';
  static const _userKey = 'auth_user';

  final _storage = const FlutterSecureStorage();

  Future<void> saveTokens(LoginResponse tokens) async {
    await _storage.write(
      key: _tokenKey,
      value: jsonEncode(tokens.toStorageJson()),
    );
  }

  Future<LoginResponse?> readTokens() async {
    final raw = await _storage.read(key: _tokenKey);
    if (raw == null) return null;
    return LoginResponse.fromStorageJson(jsonDecode(raw));
  }

  /// The API's login response already includes the full user object, so
  /// we cache it locally at login time instead of re-fetching it from a
  /// dedicated "current user" endpoint.
  Future<void> saveUser(UserModel user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<UserModel?> readUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }
}
