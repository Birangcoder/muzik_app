import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/helper/imageSize.dart';
import '../../../../core/theme/app_colors.dart';

class CoverArt extends StatelessWidget {
  final String url;

  const CoverArt({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxSide = screenWidth.clamp(0.0, 480.0);

    // Request roughly 2x the displayed resolution.
    final imageSize = (maxSide * 2).round().toDouble();

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxSide),
        child: AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.stroke),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isLight ? 0.12 : 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CachedNetworkImage(
                imageUrl: CloudinaryImage.resize(url, width: imageSize),
                width: maxSide,
                height: maxSide,
                fit: BoxFit.cover,

                // Prevent unnecessarily large decoded images.
                memCacheWidth: imageSize.toInt(),
                memCacheHeight: imageSize.toInt(),

                placeholder: (context, url) {
                  return ColoredBox(
                    color: colors.surface2,
                    child: Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.text3,
                        ),
                      ),
                    ),
                  );
                },

                errorWidget: (context, url, error) {
                  return ColoredBox(
                    color: colors.surface2,
                    child: Center(
                      child: Icon(
                        Icons.music_note_rounded,
                        size: 60,
                        color: colors.text3,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
