// lib/shared/widgets/section_head.dart
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
    final colors = context.colors;

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
          Text(title, style: textTheme.titleLarge),
          if (onSeeAll != null)
            InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(AppRadius.chip),
              child: Padding(
                // keeps the tap target reasonable without visually
                // growing the text
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xs,
                ),
                child: Text(
                  "see all",
                  style: textTheme.labelMedium?.copyWith(color: colors.blue),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
