import 'dart:convert';

/// Wraps the JWT returned inside `data.token` from POST /auth/login.
///
/// The README confirms JWT_EXPIRE = 7 days server-side, but doesn't
/// document a separate `expires_in` field in the response, so — same
/// approach as before — we decode `exp` straight out of the token's own
/// payload rather than guessing at a response field that may not exist.
///
/// NOTE: this assumes `fromJson` receives the *unwrapped* `data` object
/// (i.e. `data: {token: "...", user: {...}}`), not the outer
/// {success, data} envelope — the repository is responsible for
/// unwrapping that first via `unwrapData()`.
/// If your login response nests the token differently (e.g.
/// `access_token` instead of `token`), update the single line marked
/// below — everything else stays the same.
class LoginResponse {
  final String accessToken;
  final DateTime expiresAt;

  const LoginResponse({required this.accessToken, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final raw =
        json['token'] ?? json['access_token']; // <- adjust key here if needed
    final token = raw is String ? raw.trim() : '';
    if (token.isEmpty) {
      throw const FormatException('Login response did not contain a token');
    }
    return LoginResponse(accessToken: token, expiresAt: _expiryFromJwt(token));
  }

  static DateTime _expiryFromJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('Malformed token: expected 3 segments');
    }
    final payloadJson = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final payload = jsonDecode(payloadJson);
    final exp = payload is Map ? payload['exp'] : null;
    if (exp is! num) {
      // No/invalid expiry: assume 1 day instead of crashing the login.
      return DateTime.now().add(const Duration(days: 1));
    }
    return DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
  }

  // used to save into secure storage
  Map<String, dynamic> toStorageJson() => {
    'access_token': accessToken,
    'expires_at': expiresAt.toIso8601String(),
  };

  // used to read back from secure storage
  factory LoginResponse.fromStorageJson(Map<String, dynamic> json) {
    final token = json['access_token'];
    final expires = DateTime.tryParse('${json['expires_at']}');
    if (token is! String || token.isEmpty || expires == null) {
      throw const FormatException('Stored session is corrupted');
    }
    return LoginResponse(accessToken: token, expiresAt: expires);
  }
}
