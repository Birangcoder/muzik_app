import 'package:flutter/foundation.dart';

/// Null-safe JSON readers. A missing / null / wrongly typed field can never
/// throw "type 'Null' is not a subtype of type 'String'" again.
class Json {
  Json._();

  static String str(dynamic v, {String fallback = ''}) {
    if (v == null) return fallback;
    if (v is String) return v;
    if (v is num || v is bool) return v.toString();
    return fallback;
  }

  static String? strOrNull(dynamic v) {
    final s = str(v);
    return s.isEmpty ? null : s;
  }

  static int intOf(dynamic v, {int fallback = 0}) => intOrNull(v) ?? fallback;

  static int? intOrNull(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      return int.tryParse(v.trim()) ?? double.tryParse(v)?.toInt();
    }
    return null;
  }

  /// For fields that make a record meaningless when absent (e.g. an id).
  static int requiredInt(dynamic v, String field) {
    final r = intOrNull(v);
    if (r == null) throw FormatException('Missing required field "$field"');
    return r;
  }

  static bool boolOf(dynamic v, {bool fallback = false}) =>
      boolOrNull(v) ?? fallback;

  static bool? boolOrNull(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase().trim();
      if (s == 'true' || s == '1') return true;
      if (s == 'false' || s == '0') return false;
    }
    return null;
  }

  static DateTime? dateOrNull(dynamic v) {
    if (v is DateTime) return v;
    if (v is String && v.trim().isNotEmpty) return DateTime.tryParse(v.trim());
    return null;
  }

  static Map<String, dynamic> map(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return <String, dynamic>{};
  }

  static Map<String, dynamic>? mapOrNull(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : null;

  /// Parses a list, silently skipping items that are malformed instead of
  /// failing the whole screen because of one bad record.
  static List<T> list<T>(dynamic v, T Function(Map<String, dynamic>) parse) {
    if (v is! List) return <T>[];
    final out = <T>[];
    for (final item in v) {
      if (item is! Map) continue;
      try {
        out.add(parse(Map<String, dynamic>.from(item)));
      } catch (e) {
        debugPrint('Skipped malformed item: $e');
      }
    }
    return out;
  }
}
