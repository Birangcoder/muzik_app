import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muzik/core/constants/appRouteName.dart';
import 'package:muzik/core/theme/app_spacing.dart';

import '../../../../core/theme/app_colors.dart';

class MainScreen extends StatelessWidget {
  final Widget child;
  final int index;

  const MainScreen({super.key, required this.child, required this.index});

  final dect = const [
    Text('home'),
    Text('search'),
    Text('library'),
    Text('profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Padding(padding: AppSpacing.screenMargin, child: child),
      ),
      bottomNavigationBar: NavigationBar(
        indicatorColor: context.colors.surface2,
        surfaceTintColor: Colors.transparent,
        selectedIndex: index,
        elevation: 2,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.goNamed(RouteName.home);
              break;
            case 1:
              context.goNamed(RouteName.search);
              break;
            case 2:
              context.goNamed(RouteName.library);
              break;
            case 3:
              context.goNamed(RouteName.profile);
              break;
          }
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            label: "home",
            selectedIcon: Icon(Icons.home_outlined, color: context.colors.blue),
          ),
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            label: "search",
            selectedIcon: Icon(
              Icons.search_outlined,
              color: context.colors.blue,
            ),
          ),
          NavigationDestination(
            icon: const Icon(Icons.my_library_music_outlined),
            label: "library",
            selectedIcon: Icon(
              Icons.my_library_music_outlined,
              color: context.colors.blue,
            ),
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: "profile",
            selectedIcon: Icon(
              Icons.person_outline,
              color: context.colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
