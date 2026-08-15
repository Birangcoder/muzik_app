// lib/features/song/presentation/widgets/like_and_play_row.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../providers/audio_player_provider.dart';

class LikeAndPlayRow extends StatefulWidget {
  final int? likeCount;
  const LikeAndPlayRow({super.key, required this.likeCount});

  @override
  State<LikeAndPlayRow> createState() => _LikeAndPlayRowState();
}

class _LikeAndPlayRowState extends State<LikeAndPlayRow> {
  bool _liked = false;
  late int? _count = widget.likeCount;

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      if (_count != null) _count = _count! + (_liked ? 1 : -1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                iconSize: 26,
                icon: Icon(
                  _liked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: _liked ? colors.purple : colors.text2,
                ),
                onPressed: _toggleLike,
              ),
              if (_count != null)
                Text(
                  _formatCount(_count),
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: colors.text3),
                ),
            ],
          ),
          const SizedBox(width: 24),
          const _PlayPauseButton(),
        ],
      ),
    );
  }
}

class _PlayPauseButton extends ConsumerWidget {
  const _PlayPauseButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final playerState = ref.watch(playerStateStreamProvider).asData?.value;
    final processingState = playerState?.processingState;
    final playing = playerState?.playing ?? false;

    final isBuffering = processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering;
    final size = MediaQuery.of(context).size.width > 600 ? 72.0 : 64.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: colors.purple),
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
          final controller = ref.read(audioControllerProvider.notifier);
          if (processingState == ProcessingState.completed) {
            controller.replay();
          } else {
            controller.togglePlayPause();
          }
        },
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