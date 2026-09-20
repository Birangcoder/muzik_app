import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muzik/core/router/route_names.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/auth_state.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    ref
        .read(authProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    final isLoading = authState is AuthLoading;
    final error = authState is AuthError ? authState.message : null;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Logo
              Image.asset('assets/images/logo.png', width: 56, height: 56),

              const SizedBox(height: 36),

              /// Title
              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.displayLarge,
              ),

              const SizedBox(height: 16),

              /// Description
              Text(
                'Sign in to sync your favorites, playlists, and listening '
                'history everywhere.',
                style: Theme.of(context).textTheme.labelMedium,
              ),

              const SizedBox(height: 32),

              /// Email field
              Text('Email', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: 'you@email.com',
                  filled: true,
                  fillColor: context.colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// Password field
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Password',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  GestureDetector(
                    // TODO: wire up to a real forgot-password flow when
                    // that endpoint exists on the backend.
                    onTap: () {},
                    child: Text(
                      'Forgot?',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xff1CB5E0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                onSubmitted: (_) => isLoading ? null : _submit(),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  filled: true,
                  fillColor: context.colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),

              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error, style: const TextStyle(color: Colors.red)),
              ],

              const SizedBox(height: 28),

              /// Sign in button
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
                    onPressed: isLoading ? null : _submit,
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
                            'Sign in',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: Colors.white),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Divider
              Row(
                children: [
                  Expanded(child: Divider(color: context.colors.stroke)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  Expanded(child: Divider(color: context.colors.stroke)),
                ],
              ),

              const SizedBox(height: 20),

              /// Create account button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () => context.goNamed(RouteName.register),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: context.colors.surface,
                    side: BorderSide(color: context.colors.stroke),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Create an account',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
