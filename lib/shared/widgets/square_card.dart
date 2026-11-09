import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/image_size.dart';
import '../../core/utils/responsive.dart';

class SquareCard extends StatelessWidget {
  final String title;
  final String artist;
  final String coverImg;
  final VoidCallback? onTap;

  /// Fixed width for horizontal-rail usage (home page).
  /// Leave null when placed inside a GridView — it will then fill
  /// whatever width the grid cell gives it instead.
  final double? width;

  const SquareCard({
    super.key,
    required this.title,
    required this.artist,
    required this.coverImg,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = context.colors;

    // Rail usage: fixed size. Grid usage: fill parent (LayoutBuilder below
    // reads the actual cell width for correct memCache sizing).
    final fixedWidth = width ?? Responsive.mediaCardSize(context);

    Widget cover(double cellWidth) => AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.chip),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.chip),
          child: coverImg.trim().isEmpty
              ? Container(
                  color: colors.surface,
                  child: Icon(Icons.music_note, color: colors.text2),
                )
              : CachedNetworkImage(
                  imageUrl: CloudinaryImage.resize(
                    coverImg,
                    width: cellWidth * 2,
                  ),
                  fit: BoxFit.cover,
                  memCacheWidth: (cellWidth * 2).toInt(),
                  memCacheHeight: (cellWidth * 2).toInt(),
                  maxWidthDiskCache: (cellWidth * 2).toInt(),
                  maxHeightDiskCache: (cellWidth * 2).toInt(),
                  placeholder: (context, url) =>
                      Container(color: colors.surface),
                  errorWidget: (context, url, error) => Container(
                    color: colors.surface,
                    child: Icon(Icons.music_note, color: colors.text2),
                  ),
                ),
        ),
      ),
    );

    Widget textBlock() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.sm),
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyLarge?.copyWith(
            color: colors.text,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          artist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelMedium?.copyWith(
            color: colors.text2,
            height: 1.2,
          ),
        ),
      ],
    );

    final card = InkWell(
      borderRadius: BorderRadius.circular(AppRadius.chip),
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth = width ?? constraints.maxWidth;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RepaintBoundary(child: cover(cellWidth)),
              textBlock(),
            ],
          );
        },
      ),
    );

    // Only wrap in a fixed-width SizedBox for rail usage.
    return width != null ? SizedBox(width: fixedWidth, child: card) : card;
  }
}
