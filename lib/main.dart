import 'package:flutter/material.dart';

import 'app/routes.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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