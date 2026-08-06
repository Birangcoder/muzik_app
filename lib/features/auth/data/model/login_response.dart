import 'dart:convert';

/// Matches login.php / register.php's auth payload.
///
/// Changes from the original:
/// - No `refreshToken`, `tokenType`, or `scope` — our API is a plain
///   bearer JWT, not OAuth2. There's no refresh flow: when the token
///   expires (7 days), the user just logs in again.
/// - The server doesn't send `expires_in` — the JWT already carries its
///   own `exp` claim, so we decode that directly instead of duplicating
///   the expiry logic client-side. (If you'd rather keep the original
///   shape, it's a one-line addition to login.php: return
///   `'expires_in' => 60 * 60 * 24 * 7` alongside `token`.)
class LoginResponse {
  final String accessToken;
  final DateTime expiresAt;

  const LoginResponse({required this.accessToken, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String;
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
    final payload = jsonDecode(payloadJson) as Map<String, dynamic>;
    final expSeconds = payload['exp'] as int?;
    if (expSeconds == null) {
      throw const FormatException('Token payload missing "exp" claim');
    }
    return DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000);
  }

  // used to save into secure storage
  Map<String, dynamic> toStorageJson() => {
    'access_token': accessToken,
    'expires_at': expiresAt.toIso8601String(),
  };

  // used to read back from secure storage
  factory LoginResponse.fromStorageJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }
}
