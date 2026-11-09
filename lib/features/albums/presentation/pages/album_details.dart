import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../data/models/album_model.dart';
import '../providers/album_provider.dart';
import '../widgets/album_action_row.dart';
import '../widgets/album_artists_section.dart';
import '../widgets/album_header.dart';
import '../widgets/album_info_section.dart';
import '../widgets/album_songs_section.dart';

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AlbumHeader(coverUrl: album.coverUrl),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AlbumInfoSection(album: album),
                const SizedBox(height: 20),
                AlbumActionRow(albumId: album.id),
                const SizedBox(height: 24),
                AlbumSongsSection(
                  albumId: album.id,
                  fallbackSongs: album.songs ?? const [],
                ),
                const SizedBox(height: 24),
                AlbumArtistsSection(album: album),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
