import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';

class PopularArtistCard extends StatelessWidget {
  final String name;
  final int trackCount;
  final Gradient gradient;
  final VoidCallback? onTap;

  const PopularArtistCard({
    super.key,
    required this.name,
    required this.trackCount,
    required this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.colors;
    final size = Responsive.mediaCardSize(context);

    return InkWell(
      borderRadius: BorderRadius.circular(size / 2),
      onTap: onTap,
      child: SizedBox(
        width: size,
        child: Column(
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: gradient,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge?.copyWith(
                color: colors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "$trackCount tracks",
              style: textTheme.labelMedium?.copyWith(color: colors.text2),
            ),
          ],
        ),
      ),
    );
  }
}
