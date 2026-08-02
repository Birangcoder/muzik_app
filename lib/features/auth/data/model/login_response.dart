class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String scope;
  final DateTime expiresAt;

  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.scope,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
      scope: json['scope'],
      expiresAt: DateTime.now().add(Duration(seconds: json['expires_in'])),
    );
  }

  // used to save into secure storage
  Map<String, dynamic> toStorageJson() => {
    'access_token': accessToken,
    'refresh_token': refreshToken,
    'token_type': tokenType,
    'scope': scope,
    'expires_at': expiresAt.toIso8601String(),
  };

  // used to read back from secure storage
  factory LoginResponse.fromStorageJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
      scope: json['scope'],
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }
}
