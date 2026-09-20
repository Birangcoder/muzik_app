import 'dart:convert';
import 'package:http/http.dart' as http;

/// Thrown for any {"success": false, ...} response from the API.
/// [fieldErrors] is populated for validation failures, e.g.
/// {"password_confirmation": ["The field is required."]}
class ApiException implements Exception {
  final String message;
  final Map<String, dynamic>? fieldErrors;
  final int statusCode;

  ApiException(this.message, {this.fieldErrors, required this.statusCode});

  /// Convenience: the first validation message, if any — handy for
  /// showing a single line under a specific field.
  String? firstErrorFor(String field) {
    final list = fieldErrors?[field];
    if (list is List && list.isNotEmpty) return list.first as String;
    return null;
  }

  @override
  String toString() => message;
}

/// Every endpoint in MusicAPI V2 returns either:
///   {"success": true, "data": ...}
///   {"success": false, "message": "...", "errors": {...}?}
/// This unwraps that envelope once, in one place, instead of every
/// repository method re-parsing it by hand.
dynamic unwrapData(http.Response response) {
  final Map<String, dynamic> body;
  try {
    body = jsonDecode(response.body) as Map<String, dynamic>;
  } catch (_) {
    throw ApiException(
      'Unexpected response from server (status ${response.statusCode})',
      statusCode: response.statusCode,
    );
  }

  final success = body['success'] == true;
  if (!success) {
    throw ApiException(
      body['message'] as String? ?? 'Request failed',
      fieldErrors: body['errors'] as Map<String, dynamic>?,
      statusCode: response.statusCode,
    );
  }

  return body['data'];
}
