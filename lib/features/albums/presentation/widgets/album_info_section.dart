import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/album_model.dart';
import '../providers/album_provider.dart';

/// Kicker (ALBUM · year), title, artist names and "N Songs · M mins".
class AlbumInfoSection extends ConsumerWidget {
  final AlbumModel album;
  const AlbumInfoSection({super.key, required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final tracks = ref.watch(albumTracksProvider(album.id)).tracks;

    final year = album.metaData?.releaseDate?.year;
    final type = (album.metaData?.albumType ?? '').trim();
    final kicker = [
      if (type.isNotEmpty) type.toUpperCase() else 'ALBUM',
      if (year != null) '$year',
    ].join(' · ');

    final count = tracks.isNotEmpty
        ? tracks.length
        : (album.metaData?.totalTracks ?? 0);
    final seconds = tracks.fold<int>(0, (a, s) => a + s.media.durationSeconds);
    final subtitle = [
      if (count > 0) '$count ${count == 1 ? 'Song' : 'Songs'}',
      if (seconds > 0) '${(seconds / 60).ceil()} mins',
    ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          kicker,
          style: TextStyle(
            color: colors.purple,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          album.title,
          style: TextStyle(
            color: colors.text,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: colors.text3, fontSize: 12)),
        ],
      ],
    );
  }
}
