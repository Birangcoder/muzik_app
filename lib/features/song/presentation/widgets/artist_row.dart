// lib/features/song/presentation/widgets/artist_row.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/helper/imageSize.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/artists_model.dart';

class ArtistRow extends StatelessWidget {
  final List<ArtistsModel> artists;

  const ArtistRow({
    super.key,
    required this.artists,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: artists.length <= 3
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        itemCount: artists.length,
        separatorBuilder: (_, __) => const SizedBox(width: 18),
        itemBuilder: (context, i) {
          final artist = artists[i];

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: ClipOval(
                      child: artist.imageUrl != null &&
                          artist.imageUrl!.isNotEmpty
                          ? CachedNetworkImage(
                        imageUrl: CloudinaryImage.resize(
                          artist.imageUrl!,
                          width: 96,
                        ),
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,

                        // Decode only what is needed.
                        memCacheWidth: 96,
                        memCacheHeight: 96,

                        placeholder: (context, url) {
                          return ColoredBox(
                            color: colors.surface2,
                            child: Center(
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
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
                                Icons.person_rounded,
                                color: colors.text3,
                                size: 24,
                              ),
                            ),
                          );
                        },
                      )
                          : ColoredBox(
                        color: colors.surface2,
                        child: Center(
                          child: Icon(
                            Icons.person_rounded,
                            color: colors.text3,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (artist.verified == true)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: colors.background,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_rounded,
                          color: colors.purple,
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 6),

              SizedBox(
                width: 64,
                child: Text(
                  artist.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: colors.text2,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}