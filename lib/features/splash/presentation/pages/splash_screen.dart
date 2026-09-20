import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      body: Stack(
        children: [
          // Soft glow
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.deepPurple.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Icon
                  Image.asset(
                    'assets/images/logo.png', // Change to your icon path
                    width: 90,
                    height: 90,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'muzik',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'music, decentralized',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
