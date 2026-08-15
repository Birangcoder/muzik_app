// lib/features/song/presentation/widgets/artist_row.dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/artists_model.dart';

class ArtistRow extends StatelessWidget {
  final List<ArtistsModel> artists;
  const ArtistRow({super.key, required this.artists});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: colors.surface2,
                    backgroundImage: artist.imageUrl != null
                        ? NetworkImage(artist.imageUrl!)
                        : null,
                    child: artist.imageUrl == null
                        ? Icon(Icons.person_rounded, color: colors.text3)
                        : null,
                  ),
                  if (artist.verified!)
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: colors.background,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.verified_rounded,
                            color: colors.purple, size: 14),
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
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: colors.text2),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}