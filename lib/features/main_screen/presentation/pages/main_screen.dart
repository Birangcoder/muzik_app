import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class MainScreen extends StatelessWidget {
  final Widget child;
  final int index;
  const MainScreen({super.key, required this.child, required this.index});

  static const _routes = ['/', '/search', '/library', '/profile'];
  static const _labels = ['Home', 'Search', 'Library', 'Profile'];
  static const _icons = [
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.library_music_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: child,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              top: BorderSide(color: colors.stroke.withValues(alpha: .65)),
            ),
          ),
          child: NavigationBar(
            height: 68,
            backgroundColor: colors.surface,
            surfaceTintColor: Colors.transparent,
            indicatorColor: colors.purple.withValues(alpha: .16),
            selectedIndex: index.clamp(0, 3),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (i) {
              if (i != index) context.go(_routes[i]);
            },
            destinations: List.generate(
              4,
              (i) => NavigationDestination(
                icon: Icon(_icons[i], size: 21),
                selectedIcon: Icon(_icons[i], color: colors.purple, size: 22),
                label: _labels[i],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
