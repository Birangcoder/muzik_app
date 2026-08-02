import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../model/login_response.dart';

class SecureStorageService {
  static const _tokenKey = 'jamendo_login_response';

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

  Future<void> clearTokens() async {
    await _storage.delete(key: _tokenKey);
  }
}
