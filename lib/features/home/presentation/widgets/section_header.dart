import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// The `.section-head` component from design-system.md — title + optional
/// "see all", consistent spacing everywhere it's used (Home, Library,
/// Search Results, etc).
class SectionHead extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const SectionHead({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // final colors = context.colors;

    return Padding(
      // 32px between sections, 12px header->content, per Spacing section
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (onSeeAll != null)
            OutlinedButton.icon(
              onPressed: onSeeAll,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 16),
              label: const Text('View All', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}
