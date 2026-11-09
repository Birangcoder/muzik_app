import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/models/artist_model_ref.dart';
import '../../../../shared/widgets/round_card.dart';
import '../../../song/data/models/song_model.dart';
import '../../data/models/album_model.dart';
import '../providers/album_provider.dart';

/// Round artist photos + names, like "popular artists" on the home page.
///
/// The album payload often has artist names without photos, while the song
/// payloads carry the photos — so both lists are merged, one entry per
/// artist, preferring the entry that has an image.
class AlbumArtistsSection extends ConsumerWidget {
  final AlbumModel album;
  const AlbumArtistsSection({super.key, required this.album});

  List<ArtistsModelRef> _merge(List<SongModel> songs) {
    final byKey = <String, ArtistsModelRef>{}; // insertion-ordered

    void add(ArtistsModelRef a) {
      final key = a.id > 0 ? 'id:${a.id}' : 'name:${a.name.toLowerCase()}';
      final existing = byKey[key];
      final existingHasImage = (existing?.imageUrl ?? '').trim().isNotEmpty;
      final newHasImage = (a.imageUrl ?? '').trim().isNotEmpty;
      if (existing == null || (!existingHasImage && newHasImage)) {
        byKey[key] = a;
      }
    }

    for (final a in album.artists ?? const <ArtistsModelRef>[]) {
      add(a);
    }
    for (final s in songs) {
      for (final a in s.artists) {
        add(a);
      }
    }
    return byKey.values.toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final tracks = ref.watch(albumTracksProvider(album.id)).tracks;
    final songs = tracks.isNotEmpty ? tracks : (album.songs ?? const []);
    final artists = _merge(songs);

    if (artists.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          artists.length == 1 ? 'artist' : 'artists',
          style: TextStyle(
            color: colors.text,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: Responsive.mediaRailHeight(context),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: artists.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, i) => RoundCard(
              name: artists[i].name,
              coverImg: artists[i].imageUrl ?? '',
            ),
          ),
        ),
      ],
    );
  }
}
