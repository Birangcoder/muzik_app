import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../providers/audio_player_provider.dart';

class SeekBar extends ConsumerStatefulWidget {
  final Duration fallbackDuration;

  const SeekBar({super.key, required this.fallbackDuration});

  @override
  ConsumerState<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends ConsumerState<SeekBar> {
  double? _dragValueMs;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final streamDuration = ref.watch(durationStreamProvider).asData?.value;
    final duration = (streamDuration == null || streamDuration == Duration.zero)
        ? widget.fallbackDuration
        : streamDuration;

    final streamPosition =
        ref.watch(positionStreamProvider).asData?.value ?? Duration.zero;
    final clampedStreamPos = streamPosition > duration
        ? duration
        : streamPosition;

    final maxMs = duration.inMilliseconds
        .toDouble()
        .clamp(1, double.infinity)
        .toDouble();

    final isDragging = _dragValueMs != null;

    final displayMs =
        (_dragValueMs ?? clampedStreamPos.inMilliseconds.toDouble())
            .clamp(0, maxMs)
            .toDouble();
    final displayPosition = Duration(milliseconds: displayMs.toInt());

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            activeTrackColor: colors.purple,
            inactiveTrackColor: colors.stroke,
            thumbColor: colors.text,
            overlayColor: colors.purple.withOpacity(0.2),
            valueIndicatorColor: colors.purple,
            valueIndicatorTextStyle: TextStyle(
              color: colors.text,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: isDragging ? 8 : 6,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            showValueIndicator: ShowValueIndicator.onDrag,
          ),
          child: Slider(
            min: 0,
            max: maxMs,
            value: displayMs,
            label: _formatDuration(displayPosition),
            onChangeStart: (value) {
              HapticFeedback.selectionClick();
              setState(() => _dragValueMs = value);
            },
            onChanged: (value) {
              setState(() => _dragValueMs = value);
            },
            onChangeEnd: (value) {
              ref
                  .read(audioControllerProvider.notifier)
                  .seek(Duration(milliseconds: value.toInt()));
              setState(() => _dragValueMs = null);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(displayPosition),
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: colors.text3),
              ),
              Text(
                _formatDuration(duration),
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: colors.text3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatDuration(Duration d) {
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}
