import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_message.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../player/presentation/providers/audio_player_provider.dart';
import '../../../player/presentation/providers/player_ui_provider.dart';
import '../../../song/data/models/song_model.dart';
import '../../../song/presentation/providers/song_provider.dart';

class SongOptionsSheet extends ConsumerStatefulWidget {
  const SongOptionsSheet({super.key, required this.song});

  final SongModel song;

  @override
  ConsumerState<SongOptionsSheet> createState() => SongOptionSheetState();
}

class SongOptionSheetState extends ConsumerState<SongOptionsSheet> {
  bool _isLoading = false;
  bool _isExiting = false;

  Future<void> _handleMinimize() async {
    if (_isExiting) return;
    _isExiting = true;
    final audio = ref.read(audioControllerProvider.notifier);
    ref.read(isPlayerMinimizedProvider.notifier).state = true;
    Navigator.pop(context);
    await audio.loadAndPlay(widget.song);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final favoritesAsync = ref.watch(userFavoritesProvider);

    final isLiked = favoritesAsync.when(
      data: (ids) => ids.contains(widget.song.id),
      loading: () => false,
      error: (_, _) => false,
    );

    Future<void> toggleLike() async {
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

        if (!context.mounted) return;

        ref.invalidate(userFavoritesProvider);
        Navigator.of(context).pop();
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendlyError(e))));
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
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
                  toggleLike();
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

            if (widget.song.hasAlbum)
              ListTile(
                leading: const Icon(Icons.album_outlined),
                title: const Text('Go to album'),
                onTap: () {
                  final albumId = widget.song.album?.id;
                  if (albumId == null) return;
                  final router = GoRouter.of(context);
                  Navigator.pop(context);
                  router.pushNamed(
                    RouteName.album,
                    pathParameters: {'id': albumId.toString()},
                  );
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
