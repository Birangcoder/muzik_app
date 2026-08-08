import 'package:flutter/material.dart';

enum DeviceType { mobile, tablet, desktop }

class Responsive {
  Responsive._();

  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1024;
  static const double contentMaxWidth = 1200;

  static DeviceType deviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= tabletMaxWidth) return DeviceType.desktop;
    if (width >= mobileMaxWidth) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static bool isMobile(BuildContext context) =>
      deviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      deviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      deviceType(context) == DeviceType.desktop;

  /// Page gutter that grows with screen size.
  static double horizontalPadding(BuildContext context) {
    switch (deviceType(context)) {
      case DeviceType.desktop:
        return 32; // was 64
      case DeviceType.tablet:
        return 24; // was 40
      case DeviceType.mobile:
        return 12; // was 20
    }
  }

  /// Columns for the genre grid.
  static int gridColumns(BuildContext context) {
    switch (deviceType(context)) {
      case DeviceType.desktop:
        return 4;
      case DeviceType.tablet:
        return 3;
      case DeviceType.mobile:
        return 2;
    }
  }

  /// Square/round media card art size (NewReleaseCard, PopularArtistCard).
  static double mediaCardSize(BuildContext context) {
    switch (deviceType(context)) {
      case DeviceType.desktop:
        return 160;
      case DeviceType.tablet:
        return 140;
      case DeviceType.mobile:
        return 122;
    }
  }

  /// Full rail height for a media card: art + spacing + two lines of text
  /// (title + subtitle). Derived directly from the art size so the text
  /// can never get clipped by an under-sized SizedBox.
  static double mediaRailHeight(BuildContext context) {
    return mediaCardSize(context) + 8 /* spacing */ + 44 /* title + subtitle */;
  }

  /// Trending hero card width/height.
  static Size trendingCardSize(BuildContext context) {
    switch (deviceType(context)) {
      case DeviceType.desktop:
        return const Size(340, 190);
      case DeviceType.tablet:
        return const Size(300, 170);
      case DeviceType.mobile:
        return const Size(280, 150);
    }
  }

  /// Rail height for the trending hero cards — just the card height itself
  /// plus a small buffer (there's no text below it, it's baked into the card).
  static double trendingRailHeight(BuildContext context) {
    return trendingCardSize(context).height + 8;
  }
}
