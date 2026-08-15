// lib/features/song/presentation/widgets/song_page_states.dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SongPageLoading extends StatelessWidget {
  const SongPageLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.background,
      child: Center(child: CircularProgressIndicator(color: colors.purple)),
    );
  }
}

class SongPageError extends StatelessWidget {
  final String message;
  const SongPageError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, color: colors.text3, size: 40),
              const SizedBox(height: 12),
              Text(
                "Couldn't load this song",
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600, color: colors.text),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: colors.text3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}