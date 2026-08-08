import 'package:flutter/material.dart';

/// Gradients from the "Color System" and "Flutter Production Notes"
/// sections of design-system.md.
class AppGradients {
  /// The signature brand gradient — purple → blue → cyan, 135deg.
  /// Reserved for CTA fill, progress fill, splash mark, toggle-on state.
  /// Never re-declared per screen or reused as a card background.
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF3B82F6), Color(0xFF06B6D4)],
    stops: [0.0, 0.5, 1.0],
  );

  // Six fixed duotone gradients, sampled from the accent family, used for
  // album-art fallback tiles, MediaCard, PopularArtistCard, GenreTile, and
  // HeroCard backgrounds — identical in both themes.
  static const g1 = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)], // purple -> indigo
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const g2 = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)], // blue -> navy
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const g3 = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0F766E)], // cyan -> teal
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const g4 = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF2563EB)], // violet -> blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const g5 = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF06B6D4)], // indigo -> cyan
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const g6 = LinearGradient(
    colors: [Color(0xFF9333EA), Color(0xFF3B82F6)], // purple -> blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cycle through these for album art / avatar fallback tiles so grids
  /// stay cohesive before real artwork loads.
  static const fallbackTiles = [g1, g2, g3, g4, g5, g6];
}
