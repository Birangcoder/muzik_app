import 'package:flutter/material.dart';

import '../error/error_message.dart';

/// Friendly inline error with an optional Retry button.
/// Pass the raw error (or a ready message) — raw exception text is never shown.
class AppErrorView extends StatelessWidget {
  final Object? error;
  final String? message;
  final String title;
  final VoidCallback? onRetry;
  final String retryLabel;

  const AppErrorView({
    super.key,
    this.error,
    this.message,
    this.title = "Couldn't load this",
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              message ?? friendlyError(error),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: onRetry, child: Text(retryLabel)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Replaces Flutter's red error screen when a widget fails to build.
/// Has no Theme/Material dependency so it can never fail itself.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Something went wrong.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF888888),
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }
}
