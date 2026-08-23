import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/models/songs_model.dart';
import 'artist_row.dart';
import 'cover_art.dart';
import 'genre_chips.dart';
import 'like_and_play_row.dart';
import 'seek_bar.dart';
import 'stats_row.dart';

class NowPlayingBody extends StatelessWidget {
  final SongModel song;

  const NowPlayingBody({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hPad = Responsive.horizontalPadding(context);

    final subtitleParts = [
      if (song.album != null) song.album!.title,
      song.metaData.language,
    ];

    return Container(
      color: colors.background,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: Responsive.contentMaxWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 40),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  CoverArt(url: song.media.coverUrl),
                  const SizedBox(height: 24),
                  LikeAndPlayRow(likeCount: song.statistics?.likeCount),
                  const SizedBox(height: 28),
                  Text(
                    song.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitleParts.join(' • '),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: colors.text2),
                  ),
                  const SizedBox(height: 28),
                  SeekBar(
                    fallbackDuration: Duration(
                      seconds: song.media.durationSeconds,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ArtistRow(artists: song.artists),
                  if (song.genres != null && song.genres!.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    GenreChips(genres: song.genres!),
                  ],
                  const SizedBox(height: 18),
                  StatsRow(
                    playCount: song.statistics?.playCount,
                    releaseDate: song.metaData.releaseDate,
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
