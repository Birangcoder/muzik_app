import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../providers/audio_player_provider.dart';
import '../providers/song_provider.dart';

class LikeAndPlayRow extends ConsumerStatefulWidget {
  final int? likeCount;
  final int songId;

  const LikeAndPlayRow({
    super.key,
    required this.likeCount,
    required this.songId,
  });

  @override
  ConsumerState<LikeAndPlayRow> createState() => _LikeAndPlayRowState();
}

class _LikeAndPlayRowState extends ConsumerState<LikeAndPlayRow> {
  bool _isLoading = false;
  late int? _displayCount = widget.likeCount;

  Future<void> _toggleLike() async {
    if (_isLoading) return;

    // Read current truth from provider
    final favoriteIds = ref.read(userFavoritesProvider).value ?? [];
    final isCurrentlyLiked = favoriteIds.contains(widget.songId);
    final willBeLiked = !isCurrentlyLiked;

    // Optimistically update local count
    if (_displayCount != null) {
      setState(() => _displayCount = _displayCount! + (willBeLiked ? 1 : -1));
    }
    setState(() => _isLoading = true);

    try {
      final repo = ref.read(songApiServiceProvider);
      if (willBeLiked) {
        await repo.addSongToFavorites(widget.songId);
      } else {
        await repo.removeSongFromFavorites(widget.songId);
      }

      // Refresh the favorites list so the whole app knows
      ref.invalidate(userFavoritesProvider);
    } catch (e) {
      // Revert count on failure
      if (_displayCount != null && mounted) {
        setState(
          () => _displayCount = _displayCount! + (isCurrentlyLiked ? 1 : -1),
        );
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Watch favorites — rebuilds when list refreshes
    final favoritesAsync = ref.watch(userFavoritesProvider);
    final isLiked = favoritesAsync.when(
      data: (ids) => ids.contains(widget.songId),
      loading: () => false,
      error: (_, __) => false,
    );

    // Audio state for play button
    final playerState = ref.watch(playerStateStreamProvider).asData?.value;
    final processingState = playerState?.processingState;
    final playing = playerState?.playing ?? false;
    final isBuffering =
        processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering;
    final size = MediaQuery.of(context).size.width > 600 ? 72.0 : 64.0;

    final bool buttonDisabled = favoritesAsync.isLoading || _isLoading;

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // ── LIKE BUTTON ──
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: 26,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.purple,
                        ),
                      )
                    : Icon(
                        isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isLiked ? colors.purple : colors.text2,
                      ),
                onPressed: buttonDisabled ? null : _toggleLike,
              ),
              if (_displayCount != null)
                Text(
                  _formatCount(_displayCount),
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: colors.text3),
                ),
            ],
          ),

          const SizedBox(width: 24),

          // ── PLAY/PAUSE BUTTON ──
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.purple,
            ),
            child: isBuffering
                ? Padding(
                    padding: const EdgeInsets.all(18),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: colors.text,
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      processingState == ProcessingState.completed
                          ? Icons.replay_rounded
                          : (playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded),
                      color: Colors.white,
                      size: 34,
                    ),
                    onPressed: () {
                      final controller = ref.read(
                        audioControllerProvider.notifier,
                      );
                      if (processingState == ProcessingState.completed) {
                        controller.replay();
                      } else {
                        controller.togglePlayPause();
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

String _formatCount(int? n) {
  if (n == null) return '—';
  final s = n.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}
