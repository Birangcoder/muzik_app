import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../shared/widgets/song_list_tile.dart';
import '../../../home/presentation/widgets/show_song_options.dart';
import '../../../song/data/models/song_model.dart';
import '../providers/album_provider.dart';

/// The album's songs, loaded from GET /albums/:id/tracks (the album detail
/// endpoint itself does not return tracks). Same tile + options sheet as the
/// home page.
class AlbumSongsSection extends ConsumerWidget {
  final int albumId;

  /// Used only if the tracks endpoint returns nothing but the album payload
  /// already contained songs.
  final List<SongModel> fallbackSongs;

  const AlbumSongsSection({
    super.key,
    required this.albumId,
    this.fallbackSongs = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final state = ref.watch(albumTracksProvider(albumId));
    final notifier = ref.read(albumTracksProvider(albumId).notifier);

    final songs = state.tracks.isNotEmpty ? state.tracks : fallbackSongs;

    Widget body;
    if (state.isLoading && songs.isEmpty) {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (state.error != null && songs.isEmpty) {
      body = AppErrorView(
        error: state.error,
        title: "Couldn't load the songs",
        onRetry: notifier.refresh,
      );
    } else if (songs.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'No songs in this album yet.',
            style: TextStyle(color: colors.text2),
          ),
        ),
      );
    } else {
      body = Column(
        children: [
          for (final song in songs)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SongListTile(
                song: song,
                onTap: () => context.pushNamed(
                  RouteName.song,
                  pathParameters: {'id': song.id.toString()},
                ),
                onMore: () => showSongOptions(context, song),
              ),
            ),
          if (state.isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.hasNext && state.tracks.isNotEmpty)
            TextButton(
              onPressed: notifier.loadMore,
              child: const Text('Load more'),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'songs',
          style: TextStyle(
            color: colors.text,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        body,
      ],
    );
  }
}
