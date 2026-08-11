import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/responsive.dart';

class RoundCard extends StatelessWidget {
  final String name;

  // final int trackCount;
  final String coverImg;
  final VoidCallback? onTap;

  const RoundCard({
    super.key,
    required this.name,
    // required this.trackCount,
    required this.coverImg,
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
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: coverImg,
                width: size,
                height: size,
                fit: BoxFit.cover,

                // Don't decode a huge image when the card is small.
                memCacheWidth: (size * 2).toInt(),
                memCacheHeight: (size * 2).toInt(),

                // Also keep a smaller version in disk cache.
                maxWidthDiskCache: (size * 2).toInt(),
                maxHeightDiskCache: (size * 2).toInt(),

                placeholder: (context, url) => SizedBox(
                  width: size,
                  height: size,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => SizedBox(
                  width: size,
                  height: size,
                  child: const Icon(Icons.person),
                ),
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
          ],
        ),
      ),
    );
  }
}
