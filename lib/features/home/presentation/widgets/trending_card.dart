import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';

class TrendingCard extends StatelessWidget {
  final int rank;
  final String title;
  final String artist;
  final String license;
  final Gradient gradient;
  final VoidCallback? onTap;

  const TrendingCard({
    super.key,
    required this.rank,
    required this.title,
    required this.artist,
    required this.gradient,
    this.license = "CC BY-NC-SA",
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = Responsive.trendingCardSize(context);

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.hero),
      onTap: onTap,
      child: Container(
        width: size.width,
        height: size.height,
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.hero),
          gradient: gradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: Text(
                "#$rank TRENDING",
                style: textTheme.labelSmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              "$artist · $license",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
