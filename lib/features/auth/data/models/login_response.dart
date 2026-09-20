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
    final token = json['token'] as String; // <- adjust key here if needed
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
