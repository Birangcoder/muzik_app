import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../providers/audio_player_provider.dart';
import '../../../../providers/player_ui_provider.dart';
import '../../../song/data/models/songs_model.dart';
import '../../../song/presentation/providers/song_provider.dart';

class SongOptionsSheet extends ConsumerStatefulWidget {
  const SongOptionsSheet({super.key, required this.song});

  final SongModel song;

  @override
  ConsumerState<SongOptionsSheet> createState() => SongOptionSheetState();
}

class SongOptionSheetState extends ConsumerState<SongOptionsSheet> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    bool _isLoading = false;
    bool _isExiting = false;
    void _handleMinimize() {
      if (_isExiting) return;
      _isExiting = true;
      ref.read(audioControllerProvider.notifier).loadAndPlay(widget.song);
      ref.read(isPlayerMinimizedProvider.notifier).state = true;
      Navigator.pop(context);
    }

    final favoritesAsync = ref.watch(userFavoritesProvider);

    final isLiked = favoritesAsync.when(
      data: (ids) => ids.contains(widget.song.id),
      loading: () => false,
      error: (_, __) => false,
    );

    Future<void> _toggleLike() async {
      if (_isLoading) return;

      final favoriteIds = ref.read(userFavoritesProvider).value ?? [];
      final isCurrentlyLiked = favoriteIds.contains(widget.song.id);
      final willBeLiked = !isCurrentlyLiked;

      setState(() => _isLoading = true);

      try {
        final repo = ref.read(songApiServiceProvider);
        if (willBeLiked) {
          await repo.addSongToFavorites(widget.song.id);
        } else {
          await repo.removeSongFromFavorites(widget.song.id);
        }

        ref.invalidate(userFavoritesProvider);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
      Navigator.pop(context);
    }

    final bool buttonDisabled = favoritesAsync.isLoading || _isLoading;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Play now'),
              onTap: () {
                _handleMinimize();
              },
            ),

            ListTile(
              leading: const Icon(Icons.queue_music),
              title: const Text('Add to queue'),
              onTap: () {
                Navigator.pop(context);
                // add to queue
              },
            ),

            ListTile(
              leading: Icon(
                isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isLiked ? colors.purple : colors.text2,
              ),
              title: const Text('Add to favourites'),
              onTap: () {
                if (!buttonDisabled) {
                  _toggleLike();
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Add to playlist'),
              onTap: () {
                Navigator.pop(context);
                // show playlist selection
              },
            ),

            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Download'),
              onTap: () {
                Navigator.pop(context);
                // download
              },
            ),

            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Go to artist'),
              onTap: () {
                Navigator.pop(context);
                // navigate to artist
              },
            ),

            ListTile(
              leading: const Icon(Icons.album_outlined),
              title: const Text('Go to album'),
              onTap: () {
                Navigator.pop(context);
                // navigate to album
              },
            ),

            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // share song
              },
            ),
          ],
        ),
      ),
    );
  }
}
