import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    );
  }
}