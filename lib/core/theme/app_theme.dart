import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Builds the two ThemeData objects MaterialApp needs.
/// This is the only file that assembles everything together.
class AppTheme {
  static ThemeData get light => _build(AppColors.light, Brightness.light);

  static ThemeData get dark => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      dividerColor: colors.stroke,
      textTheme: AppTextStyles.build(text: colors.text, text2: colors.text2),

      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.purple,
        onPrimary: Colors.white,
        secondary: colors.blue,
        onSecondary: Colors.white,
        tertiary: colors.cyan,
        onTertiary: Colors.white,
        error: colors.error,
        onError: Colors.white,
        surface: colors.surface,
        onSurface: colors.text,
      ),

      // Attaches the extra tokens (surface2, stroke, text2/3, success,
      // warning) that ColorScheme doesn't have a slot for. Read them
      // back anywhere with `context.colors.xxx`.
      extensions: [colors],

      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.text,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.stroke),
        ),
      ),
    );
  }
}
