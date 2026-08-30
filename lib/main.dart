import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/widgets/floating_mini_player.dart';

import 'app/routes.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'muzik',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,       // used when the phone is in light mode
      darkTheme: AppTheme.dark,    // used when the phone is in dark mode
      themeMode: ThemeMode.system, // <- this line is the whole trick:
      routerConfig: router,
      builder: (context, child) {
        // `child` already contains go_router's Navigator + its own Overlay.
        // Our own Overlay here is only so FloatingMiniPlayer's IconButton
        // tooltips (which need an Overlay ancestor) work correctly, since
        // FloatingMiniPlayer sits OUTSIDE / above that inner Navigator.
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => Stack(
                children: [
                  if (child != null) child,
                  const FloatingMiniPlayer(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}