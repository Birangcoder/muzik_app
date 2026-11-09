import 'dart:async';

import 'api_exception.dart';

/// Converts ANY thrown object into a short message that is safe to show.
/// Raw Dart errors ("type 'Null' is not a subtype of type 'String'",
/// RangeError, NoSuchMethodError…) never reach the UI.
String friendlyError(Object? error) {
  if (error == null) return 'Something went wrong. Please try again.';
  if (error is AppException) return error.message;
  if (error is TimeoutException) {
    return 'The request timed out. Please try again.';
  }
  if (error is FormatException) {
    return 'We received unexpected data from the server.';
  }
  return 'Something went wrong. Please try again.';
}
