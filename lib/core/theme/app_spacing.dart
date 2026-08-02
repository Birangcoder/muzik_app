import 'package:flutter/material.dart';

/// All spacing/margin/padding numbers from the "Spacing" section
/// of design-system.md. Same values regardless of dark or light theme.
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
  static const huge = 64.0;

  // Ready-made EdgeInsets so you don't retype these constantly
  static const screenMargin = EdgeInsets.symmetric(horizontal: 20, vertical: 20);
  static const cardPadding = EdgeInsets.all(16);

  // Touch target sizes
  static const minTouchTarget = 48.0;
  static const primaryControlTarget = 60.0; // 56–64dp per design-system.md
}

/// Corner radius values from the "Shape & Elevation" section.
class AppRadius {
  static const chip = 12.0;
  static const card = 20.0;
  static const hero = 26.0;
}
