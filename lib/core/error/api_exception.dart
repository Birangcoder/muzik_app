import 'dart:convert';
import 'package:http/http.dart' as http;

/// Base for every error we deliberately show to the user.
class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown for network failures and any {"success": false, ...} response.
class ApiException extends AppException {
  final Map<String, dynamic>? fieldErrors;
  final int statusCode;

  const ApiException(
    super.message, {
    this.fieldErrors,
    required this.statusCode,
  });

  String? firstErrorFor(String field) {
    final list = fieldErrors?[field];
    if (list is List && list.isNotEmpty) return list.first.toString();
    if (list is String) return list;
    return null;
  }
}

/// Thrown when audio can't be loaded / played.
class PlaybackException extends AppException {
  const PlaybackException(super.message);
}

String _messageForStatus(int code) {
  if (code == 401) return 'Your session has expired. Please log in again.';
  if (code == 403) return "You don't have permission to do that.";
  if (code == 404) return "We couldn't find what you were looking for.";
  if (code == 429) return 'Too many requests. Please wait a moment.';
  if (code >= 500) {
    return 'The server is having problems. Please try again later.';
  }
  return 'Request failed. Please try again.';
}

/// Unwraps `{"success": true, "data": ...}` and turns anything else into an
/// [ApiException] with a human readable message.
dynamic unwrapData(http.Response response) {
  final code = response.statusCode;

  Map<String, dynamic>? body;
  try {
    final decoded = jsonDecode(response.body);
    if (decoded is Map) body = Map<String, dynamic>.from(decoded);
  } catch (_) {}

  if (body == null) {
    throw ApiException(
      code >= 400
          ? _messageForStatus(code)
          : 'Unexpected response from server. Please try again.',
      statusCode: code,
    );
  }

  final successFlag = body['success'];
  final ok =
      successFlag == true || (successFlag == null && code >= 200 && code < 300);

  if (!ok || code >= 400) {
    final msg = body['message'];
    final errors = body['errors'];
    throw ApiException(
      (msg is String && msg.trim().isNotEmpty) ? msg : _messageForStatus(code),
      fieldErrors: errors is Map ? Map<String, dynamic>.from(errors) : null,
      statusCode: code,
    );
  }

  return body['data'];
}

/// Same as [unwrapData] but guarantees a Map (never `null`/List).
Map<String, dynamic> unwrapMap(http.Response response) {
  final data = unwrapData(response);
  if (data is Map) return Map<String, dynamic>.from(data);
  throw ApiException(
    'The server returned no data. Please try again.',
    statusCode: response.statusCode,
  );
}
