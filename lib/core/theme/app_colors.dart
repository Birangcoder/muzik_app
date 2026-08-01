import 'package:flutter/material.dart';

/// All colors from the "Color System" section of design-system.md.
///
/// This is a ThemeExtension — Flutter's built-in way to attach custom
/// colors (ones ColorScheme doesn't have a slot for) onto ThemeData,
/// so they travel alongside the rest of the theme automatically.
///
/// You never create this yourself in a screen — AppTheme (in
/// app_theme.dart) attaches AppColors.dark or AppColors.light to
/// ThemeData, and you read it back with `context.colors`.
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color surface2;
  final Color stroke;
  final Color text;
  final Color text2;
  final Color text3;
  final Color purple;
  final Color blue;
  final Color cyan;
  final Color success;
  final Color warning;
  final Color error;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surface2,
    required this.stroke,
    required this.text,
    required this.text2,
    required this.text3,
    required this.purple,
    required this.blue,
    required this.cyan,
    required this.success,
    required this.warning,
    required this.error,
  });

  // Dark theme values, straight from the table in design-system.md
  static const dark = AppColors(
    background: Color(0xFF0A0A10),
    surface: Color(0xFF141420),
    surface2: Color(0xFF1B1B29),
    stroke: Color(0xFF242435),
    text: Color(0xFFF5F4FA),
    text2: Color(0xFF9997A8),
    text3: Color(0xFF5E5C70),
    purple: Color(0xFF7C3AED),
    blue: Color(0xFF3B82F6),
    cyan: Color(0xFF06B6D4),
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
  );

  // Light theme values, straight from the table in design-system.md
  static const light = AppColors(
    background: Color(0xFFF8F6FC),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF1EDF8),
    stroke: Color(0xFFE1DBEF),
    text: Color(0xFF1C1730),
    text2: Color(0xFF6E6680),
    text3: Color(0xFF9C93AC),
    purple: Color(0xFF7C3AED),
    blue: Color(0xFF3B82F6),
    cyan: Color(0xFF06B6D4),
    success: Color(0xFF16A34A),
    warning: Color(0xFFD97706),
    error: Color(0xFFDC2626),
  );

  // Required by ThemeExtension — lets Flutter animate/merge between themes.
  // You don't need to call these yourself.
  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surface2,
    Color? stroke,
    Color? text,
    Color? text2,
    Color? text3,
    Color? purple,
    Color? blue,
    Color? cyan,
    Color? success,
    Color? warning,
    Color? error,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      stroke: stroke ?? this.stroke,
      text: text ?? this.text,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      purple: purple ?? this.purple,
      blue: blue ?? this.blue,
      cyan: cyan ?? this.cyan,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      stroke: Color.lerp(stroke, other.stroke, t)!,
      text: Color.lerp(text, other.text, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      text3: Color.lerp(text3, other.text3, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      cyan: Color.lerp(cyan, other.cyan, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

/// Shortcut so you can write `context.colors.text` instead of the longer
/// `Theme.of(context).extension<AppColors>()!.text`.
extension AppColorsGetter on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
