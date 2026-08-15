import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';

import '../features/song/data/models/songs_model.dart';
import '../features/song/data/repository/song_repository.dart';
import '../features/song/presentation/providers/song_provider.dart';

/// One shared AudioPlayer instance for the whole app.
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose); // cleaned up automatically
  return player;
});

/// Controls loading/playing songs, and tracks which song is currently loaded
/// so we don't reload the same song on every rebuild.
// audio_player_provider.dart

class AudioController extends StateNotifier<int?> {
  final AudioPlayer _player;
  final SongRepository _api;
  final Ref _ref;

  StreamSubscription<PlayerState>? _completionSub;
  bool _progressReported = false;
  bool _isReporting = false;
  Future<void>? _recordPlayFuture; // NEW: track the in-flight /play call

  AudioController(this._player, this._api, this._ref) : super(null);

  Future<void> loadAndPlay(SongModel song) async {
    if (state == song.id) return;
    await _reportIfNeeded(completed: false);
    try {
      await _player.setUrl(song.media.audioUrl);
      state = song.id;
      _progressReported = false;

      // DO NOT await this — just_audio's play() future doesn't complete
      // until playback pauses/stops/finishes, not when it starts.
      unawaited(_player.play());

      final sentAt = DateTime.now();
      debugPrint(
        '[$sentAt] calling recordPlay immediately after play() is triggered',
      );

      _recordPlayFuture = _api.recordPlay(song.id).catchError((e) {
        debugPrint('recordPlay failed: $e');
      });

      _completionSub?.cancel();
      _completionSub = _player.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          _reportIfNeeded(completed: true);
        }
      });
    } catch (e) {
      state = null;
      rethrow;
    }
  }

  Future<void> stopAndReportProgress() async {
    final actuallyCompleted =
        _player.processingState == ProcessingState.completed;
    await _reportIfNeeded(completed: actuallyCompleted);
    await _completionSub?.cancel();
    _completionSub = null;
    await _player.stop();
    state = null;
  }

  Future<void> _reportIfNeeded({required bool completed}) async {
    if (state == null || _progressReported || _isReporting) return;

    _isReporting = true;

    // CRITICAL: wait for the /play request to actually finish
    // before ever sending /progress, so the server always
    // processes them in the correct order.
    if (_recordPlayFuture != null) {
      debugPrint('_reportIfNeeded: waiting for recordPlay to finish first...');
      await _recordPlayFuture;
      debugPrint('_reportIfNeeded: recordPlay finished, proceeding');
    }

    final rawPosition = _player.position;
    final totalDuration = _player.duration;
    final clampedPosition =
        (totalDuration != null && rawPosition > totalDuration)
        ? totalDuration
        : rawPosition;
    final playDuration = clampedPosition.inSeconds;

    try {
      await _api.recordProgress(
        state!,
        playDuration: playDuration,
        completed: completed,
      );
      _progressReported = true;
      debugPrint('_reportIfNeeded: success, marked as reported');
    } catch (e) {
      debugPrint('_reportIfNeeded: FAILED, will allow retry later: $e');
    } finally {
      _isReporting = false;
    }
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> replay() async {
    _progressReported = false;
    await _player.seek(Duration.zero);
    await _player.play();
  }
}

final audioControllerProvider = StateNotifierProvider<AudioController, int?>((
  ref,
) {
  final player = ref.watch(audioPlayerProvider);
  final api = ref.watch(songApiServiceProvider);
  return AudioController(player, api, ref);
});

// Convenience stream providers for the UI to watch
final playerStateStreamProvider = StreamProvider<PlayerState>((ref) {
  return ref.watch(audioPlayerProvider).playerStateStream;
});

final positionStreamProvider = StreamProvider<Duration>((ref) {
  return ref.watch(audioPlayerProvider).positionStream;
});

final durationStreamProvider = StreamProvider<Duration?>((ref) {
  return ref.watch(audioPlayerProvider).durationStream;
});
