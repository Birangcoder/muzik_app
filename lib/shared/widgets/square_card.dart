import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/helper/imageSize.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/responsive.dart';

class SquareCard extends StatelessWidget {
  final String title;
  final String artist;
  final String coverImg;
  final VoidCallback? onTap;

  const SquareCard({
    super.key,
    required this.title,
    required this.artist,
    required this.coverImg,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.colors;
    final size = Responsive.mediaCardSize(context);

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.chip),
      onTap: onTap,
      child: SizedBox(
        width: size,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.chip),
              child: CachedNetworkImage(
                imageUrl: CloudinaryImage.resize(coverImg, width: size * 2),
                width: size,
                height: size,
                fit: BoxFit.cover,

                // Don't decode a huge image when the card is small.
                memCacheWidth: (size * 2).toInt(),
                memCacheHeight: (size * 2).toInt(),

                // Also keep a smaller version in disk cache.
                maxWidthDiskCache: (size * 2).toInt(),
                maxHeightDiskCache: (size * 2).toInt(),

                placeholder: (context, url) =>
                    Container(width: size, height: size, color: colors.surface),
                errorWidget: (context, url, error) => Container(
                  width: size,
                  height: size,
                  color: colors.surface,
                  child: const Icon(Icons.music_note),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge?.copyWith(
                color: colors.text,
                fontWeight: FontWeight.w600,
              ),
            ),

            Text(
              artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(color: colors.text2),
            ),
          ],
        ),
      ),
    );
  }
}
