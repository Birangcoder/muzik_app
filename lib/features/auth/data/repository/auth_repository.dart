import 'dart:math';
import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_key_secret.dart';
import '../model/user_model.dart';
import '../repository/secure_storage_service.dart';

import '../model/login_response.dart';

// change client id and client secret
class AuthRepository {
  static const _clientId = ApiKeySecret.clientId;
  static const _clientSecret = ApiKeySecret.clientSecret;
  static const _redirectUri = 'muzik://jamendo-callback';
  static const _callbackScheme = 'muzik';

  final SecureStorageService _storage;

  AuthRepository(this._storage);

  String _generateState() {
    final rand = Random.secure();
    return List.generate(
      16,
      (_) => rand.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }

  /// Full login flow: open browser -> get code -> exchange for tokens -> save
  Future<LoginResponse> login() async {
    final expectedState = _generateState();

    final authUrl = Uri.https('api.jamendo.com', '/v3.0/oauth/authorize', {
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'scope': 'music',
      'response_type': 'code',
      'state': expectedState,
    });
    print("auth url: $authUrl");
    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: _callbackScheme,
    );

    final returnedUri = Uri.parse(result);
    final returnedState = returnedUri.queryParameters['state'];

    if (returnedState != expectedState) {
      throw Exception('State mismatch — possible CSRF attack, aborting login');
    }

    final code = returnedUri.queryParameters['code'];
    if (code == null) throw Exception('No authorization code returned');

    final tokens = await _exchangeCodeForToken(code);
    await _storage.saveTokens(tokens);
    return tokens;
  }

  Future<LoginResponse> _exchangeCodeForToken(String code) async {
    final response = await http.post(
      Uri.parse('https://api.jamendo.com/v3.0/oauth/grant'),
      body: {
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': _redirectUri,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Token exchange failed: ${response.body}');
    }
    return LoginResponse.fromJson(jsonDecode(response.body));
  }

  Future<LoginResponse> refreshToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('https://api.jamendo.com/v3.0/oauth/grant'),
      body: {
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Token refresh failed: ${response.body}');
    }
    final tokens = LoginResponse.fromJson(jsonDecode(response.body));
    await _storage.saveTokens(tokens);
    return tokens;
  }

  /// Fetch the logged-in user's profile using the access_token
  Future<UserModel> fetchCurrentUser(String accessToken) async {
    final response = await http.get(
      Uri.parse(
        'https://api.jamendo.com/v3.0/users/?client_id=$_clientId&access_token=$accessToken&format=json',
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch user: ${response.body}');
    }
    final body = jsonDecode(response.body);
    final results = body['results'] as List;
    if (results.isEmpty) throw Exception('No user data returned');
    return UserModel.fromJson(results.first);
  }

  Future<LoginResponse?> loadPersistedTokens() => _storage.readTokens();

  Future<void> logout() => _storage.clearTokens();
}
