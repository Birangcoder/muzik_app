import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/model/auth_state.dart';
import '../provider/authProvider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final isLoading = authState is AuthLoading;
    final error = authState is AuthError ? authState.message : null;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Logo
              Image.asset('assets/images/logo.png', width: 56, height: 56),

              const SizedBox(height: 36),

              /// Title
              Text(
                'Connect your Jamendo account',
                style: Theme.of(context).textTheme.displayLarge,
              ),

              const SizedBox(height: 16),

              /// Description
              Text(
                'Optional — browse and stream music without signing in. '
                'Connect to sync your favorites and playlists with your Jamendo account.',
                style: Theme.of(context).textTheme.labelMedium,
              ),

              const SizedBox(height: 36),

              /// Login Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xff6E40F5), Color(0xff1CB5E0)],
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => ref.read(authProvider.notifier).login(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Continue with Jamendo',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: Colors.white),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Info
              Center(
                child: Text(
                  "You'll be redirected to Jamendo to authorize.\n"
                  'This app never sees your password.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),

              const SizedBox(height: 24),

              if (error != null) ...[
                const SizedBox(height: 16),
                Center(
                  child: Text(error, style: const TextStyle(color: Colors.red)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
