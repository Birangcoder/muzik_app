import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/login_response.dart';
import '../models/user_model.dart';

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

  /// Returns null (and wipes the bad entry) if storage is unreadable or
  /// corrupted, instead of throwing into the UI.
  Future<LoginResponse?> readTokens() async {
    try {
      final raw = await _storage.read(key: _tokenKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) throw const FormatException('bad session');
      return LoginResponse.fromStorageJson(Map<String, dynamic>.from(decoded));
    } catch (e) {
      debugPrint('readTokens failed, clearing: $e');
      await _safeDelete(_tokenKey);
      return null;
    }
  }

  Future<void> saveUser(UserModel user) async {
    await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<UserModel?> readUser() async {
    try {
      final raw = await _storage.read(key: _userKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) throw const FormatException('bad user');
      return UserModel.fromJson(Map<String, dynamic>.from(decoded));
    } catch (e) {
      debugPrint('readUser failed, clearing: $e');
      await _safeDelete(_userKey);
      return null;
    }
  }

  Future<void> clearTokens() async {
    await _safeDelete(_tokenKey);
    await _safeDelete(_userKey);
  }

  Future<void> _safeDelete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (_) {}
  }
}
