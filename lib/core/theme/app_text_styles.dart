import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds the text styles from the "Typography" section of design-system.md.
/// Called once per theme inside app_theme.dart — you don't call this
/// directly from a screen. In a screen, read styles back with:
///   Theme.of(context).textTheme.titleLarge
class AppTextStyles {
  static TextTheme build({required Color text, required Color text2}) {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      // Display L
      displayMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: text,
      ),
      // Display M
      titleLarge: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      // Title
      bodyLarge: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: text,
      ),
      // Body
      labelMedium: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: text2,
      ),
      // Caption
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: text2,
      ), // Micro
    );
  }
}

/*
  How each design-system.md style maps to Theme.of(context).textTheme:

  Display L (32/700, Poppins) -> textTheme.displayLarge
  Display M (24/700, Poppins) -> textTheme.displayMedium
  Title     (18/600, Poppins) -> textTheme.titleLarge
  Body      (15/400, Inter)   -> textTheme.bodyLarge
  Caption   (13/500, Inter)   -> textTheme.labelMedium
  Micro     (11/500, Inter)   -> textTheme.labelSmall
*/
