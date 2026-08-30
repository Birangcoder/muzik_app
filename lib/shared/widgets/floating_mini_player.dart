// lib/widgets/floating_mini_player.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../app/routes.dart';
import '../../core/constants/appRouteName.dart';
import '../../core/theme/app_colors.dart';
import '../../features/song/presentation/providers/song_provider.dart';
import '../../providers/audio_player_provider.dart';
import '../../providers/player_ui_provider.dart';

const double _kBarWidth = 250;
const double _kBarHeight = 60;

class FloatingMiniPlayer extends ConsumerStatefulWidget {
  const FloatingMiniPlayer({super.key});

  @override
  ConsumerState<FloatingMiniPlayer> createState() => _FloatingMiniPlayerState();
}

class _FloatingMiniPlayerState extends ConsumerState<FloatingMiniPlayer> {
  @override
  Widget build(BuildContext context) {
    final isMinimized = ref.watch(isPlayerMinimizedProvider);
    final songId = ref.watch(audioControllerProvider);

    if (!isMinimized || songId == null) return const SizedBox.shrink();

    // LayoutBuilder gives real, settled constraints (avoids the zero-size
    // race on the very first frame). Positioned MUST be a direct child of a
    // Stack, so we build that Stack ourselves right here instead of relying
    // on some ancestor Stack we don't control (since this widget now lives
    // inside our own Overlay at the app root — see main.dart).
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = Size(constraints.maxWidth, constraints.maxHeight);
        if (screenSize.width == 0 || screenSize.height == 0) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: Stack(
            children: [
              _MiniPlayerContent(songId: songId, screenSize: screenSize),
            ],
          ),
        );
      },
    );
  }
}

class _MiniPlayerContent extends ConsumerWidget {
  final int songId;
  final Size screenSize;

  const _MiniPlayerContent({required this.songId, required this.screenSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final topInset = MediaQuery.of(context).padding.top;

    final saved = ref.watch(miniPlayerOffsetProvider);
    final offset =
        saved ??
            Offset(
              screenSize.width - _kBarWidth - 16,
              screenSize.height - _kBarHeight - 140,
            );

    // Defensive bounds — never let a clamp's min exceed its max, even on
    // unusually small screens.
    final maxDx = (screenSize.width - _kBarWidth - 8).clamp(
      8.0,
      double.infinity,
    );
    final maxDy = (screenSize.height - _kBarHeight - 24).clamp(
      topInset + 8,
      double.infinity,
    );

    final clampedOffset = Offset(
      offset.dx.clamp(8.0, maxDx),
      offset.dy.clamp(topInset + 8, maxDy),
    );

    final songAsync = ref.watch(songProvider(songId));

    return Positioned(
      left: clampedOffset.dx,
      top: clampedOffset.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          final next = Offset(
            (clampedOffset.dx + details.delta.dx).clamp(8.0, maxDx),
            (clampedOffset.dy + details.delta.dy).clamp(topInset + 8, maxDy),
          );
          ref.read(miniPlayerOffsetProvider.notifier).state = next;
        },
        onTap: () {
          ref.read(isPlayerMinimizedProvider.notifier).state = false;
          // Call GoRouter directly (not via context/Navigator). This widget
          // lives outside go_router's own Navigator tree, and mixing
          // Navigator.push with go_router's declarative pages caused
          // duplicate-key crashes. router.pushNamed is a plain instance
          // method — no BuildContext/ancestor lookup needed at all.
          ref
              .read(routerProvider)
              .pushNamed(
            RouteName.song,
            pathParameters: {'id': songId.toString()},
          );
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: _kBarWidth,
            height: _kBarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(_kBarHeight / 2),
              border: Border.all(color: colors.stroke),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    Theme.of(context).brightness == Brightness.light
                        ? 0.12
                        : 0.45,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(_kBarHeight / 2 - 6),
                  child: songAsync.maybeWhen(
                    data: (song) => Image.network(
                      song.media.coverUrl,
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _fallbackArt(colors),
                    ),
                    orElse: () => _fallbackArt(colors),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: songAsync.maybeWhen(
                    data: (song) => Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    orElse: () => Text(
                      'Loading…',
                      style: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(color: colors.text3),
                    ),
                  ),
                ),
                const _MiniPlayPauseButton(),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: colors.text3,
                    size: 20,
                  ),
                  splashRadius: 18,
                  tooltip: 'Stop',
                  onPressed: () async {
                    await ref
                        .read(audioControllerProvider.notifier)
                        .stopAndReportProgress();
                    ref.read(isPlayerMinimizedProvider.notifier).state = false;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallbackArt(AppColors colors) => Container(
    width: 42,
    height: 42,
    color: colors.surface2,
    child: Icon(Icons.music_note_rounded, color: colors.text3, size: 18),
  );
}

class _MiniPlayPauseButton extends ConsumerWidget {
  const _MiniPlayPauseButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final playerState = ref.watch(playerStateStreamProvider).asData?.value;
    final playing = playerState?.playing ?? false;
    final processingState = playerState?.processingState;

    return IconButton(
      splashRadius: 18,
      icon: Icon(
        processingState == ProcessingState.completed
            ? Icons.replay_rounded
            : (playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
        color: colors.purple,
        size: 22,
      ),
      onPressed: () {
        final controller = ref.read(audioControllerProvider.notifier);
        if (processingState == ProcessingState.completed) {
          controller.replay();
        } else {
          controller.togglePlayPause();
        }
      },
    );
  }
}