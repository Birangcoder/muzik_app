import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/image_size.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../shared/models/artist_model_ref.dart';
import '../../../../shared/widgets/round_card.dart';
import '../../../../shared/widgets/song_list_tile.dart';
import '../../../home/presentation/widgets/show_song_options.dart';
import '../../../song/data/models/song_model.dart';
import '../../data/models/album_model.dart';
import '../providers/album_provider.dart';

class AlbumScreen extends ConsumerWidget {
  final int id;

  const AlbumScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final albumAsync = ref.watch(albumProvider(id));

    return Scaffold(
      backgroundColor: colors.background,
      body: albumAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: colors.text),
                  onPressed: () => Navigator.maybePop(context),
                ),
              ),
              Expanded(
                child: AppErrorView(
                  error: e,
                  title: "Couldn't load this album",
                  onRetry: () => ref.invalidate(albumProvider(id)),
                ),
              ),
            ],
          ),
        ),
        data: (album) => _AlbumBody(album: album),
      ),
    );
  }
}

class _AlbumBody extends StatelessWidget {
  final AlbumModel album;

  const _AlbumBody({required this.album});

  String _subtitle() {
    final songs = album.songs ?? const <SongModel>[];
    final total = album.metaData?.totalTracks ?? 0;
    final count = songs.isNotEmpty ? songs.length : total;
    final seconds = songs.fold<int>(0, (a, s) => a + s.media.durationSeconds);
    final parts = <String>[
      if (count > 0) '$count ${count == 1 ? 'Song' : 'Songs'}',
      if (seconds > 0) '${(seconds / 60).ceil()} mins',
    ];
    return parts.join(' · ');
  }

  /// Album artists first, then any artist that only appears on a song.
  /// De-duplicated so each artist is shown once.
  List<ArtistsModelRef> _allArtists(List<SongModel> songs) {
    final seen = <String>{};
    final result = <ArtistsModelRef>[];

    void add(ArtistsModelRef a) {
      final key = a.id > 0 ? 'id:${a.id}' : 'name:${a.name.toLowerCase()}';
      if (seen.add(key)) result.add(a);
    }

    for (final a in album.artists ?? const <ArtistsModelRef>[]) {
      add(a);
    }
    for (final s in songs) {
      for (final a in s.artists) {
        add(a);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final songs = album.songs ?? const <SongModel>[];
    final artists = _allArtists(songs);
    final year = album.metaData?.releaseDate?.year;
    final type = (album.metaData?.albumType ?? '').trim();
    final kicker = [
      if (type.isNotEmpty) type.toUpperCase() else 'ALBUM',
      if (year != null) '$year',
    ].join(' · ');
    final artistNames = album.artistNames;
    final subtitle = _subtitle();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(coverUrl: album.coverUrl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
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
                if (artistNames.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    artistNames,
                    style: TextStyle(color: colors.text2, fontSize: 14),
                  ),
                ],
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: colors.text3, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 20),
                _ActionRow(
                  onPlay: songs.isEmpty
                      ? null
                      : () => _openSong(context, songs.first),
                ),
                const SizedBox(height: 16),

                // ── Songs: same tile + options sheet as the home page ──
                if (songs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No songs in this album yet.',
                        style: TextStyle(color: colors.text2),
                      ),
                    ),
                  )
                else
                  for (final song in songs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SongListTile(
                        song: song,
                        onTap: () => _openSong(context, song),
                        onMore: () => showSongOptions(context, song),
                      ),
                    ),

                // ── Artists: round image + name, like the home page ──
                if (artists.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    artists.length == 1 ? 'artist' : 'artists',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 20,
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openSong(BuildContext context, SongModel song) {
    context.pushNamed(
      RouteName.song,
      pathParameters: {'id': song.id.toString()},
    );
  }
}

class _Header extends StatelessWidget {
  final String coverUrl;

  const _Header({required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF97316), Color(0xFF7C3AED)],
        ),
      ),
      child: const Icon(Icons.album_rounded, color: Colors.white70, size: 56),
    );

    return Container(
      height: 285,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C3AED), Color(0xFF3B82F6)],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              left: 12,
              top: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.maybePop(context),
              ),
            ),
            Center(
              child: Container(
                width: 167,
                height: 167,
                margin: const EdgeInsets.only(top: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: coverUrl.trim().isEmpty
                      ? fallback
                      : CachedNetworkImage(
                          imageUrl: CloudinaryImage.resize(
                            coverUrl,
                            width: 334,
                          ),
                          fit: BoxFit.cover,
                          placeholder: (_, _) => fallback,
                          errorWidget: (_, _, _) => fallback,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  final IconData icon;

  const _SquareButton(this.icon);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: SizedBox(
            width: 50,
            height: 50,
            child: Icon(icon, size: 20, color: colors.text2),
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final VoidCallback? onPlay;

  const _ActionRow({this.onPlay});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        const _SquareButton(Icons.favorite_border),
        const _SquareButton(Icons.file_download_outlined),
        const _SquareButton(Icons.more_horiz),
        const Spacer(),
        const _SquareButton(Icons.repeat),
        Opacity(
          opacity: onPlay == null ? 0.4 : 1,
          child: GestureDetector(
            onTap: onPlay,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.purple.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
