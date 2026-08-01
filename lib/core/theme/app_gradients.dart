import 'package:flutter/material.dart';

/// The one signature gradient from design-system.md — purple → blue → cyan.
/// Used on CTAs, progress bars, splash mark, toggle-on state.
/// Same in both themes, so this file never changes with dark/light.
class AppGradients {
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF7C3AED), // purple
      Color(0xFF3B82F6), // blue
      Color(0xFF06B6D4), // cyan
    ],
  );
}
