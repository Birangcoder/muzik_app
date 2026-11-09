import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../error/api_exception.dart';

/// Thin wrapper over `package:http` that adds a timeout and converts
/// connection problems into [ApiException]. Swap [client] in tests.
class ApiClient {
  ApiClient._();

  static http.Client client = http.Client();
  // Render free-tier servers can take a while to wake up.
  static const Duration timeout = Duration(seconds: 60);

  static Future<http.Response> get(Uri uri, {Map<String, String>? headers}) =>
      _send(() => client.get(uri, headers: headers));

  static Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) => _send(
    () => client.post(
      uri,
      headers: headers,
      body: body is Map ? jsonEncode(body) : body,
    ),
  );

  static Future<http.Response> put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) => _send(
    () => client.put(
      uri,
      headers: headers,
      body: body is Map ? jsonEncode(body) : body,
    ),
  );

  static Future<http.Response> delete(
    Uri uri, {
    Map<String, String>? headers,
  }) => _send(() => client.delete(uri, headers: headers));

  static Future<http.Response> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(timeout);
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to respond. Please try again.',
        statusCode: 0,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      final s = e.toString();
      if (e is http.ClientException ||
          s.contains('SocketException') ||
          s.contains('HandshakeException') ||
          s.contains('Failed host lookup')) {
        throw const ApiException(
          'No internet connection. Check your network and try again.',
          statusCode: 0,
        );
      }
      throw const ApiException(
        'Could not reach the server. Please try again.',
        statusCode: 0,
      );
    }
  }
}
