import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/error/api_exception.dart';
import '../../../../core/error/error_message.dart';
import '../../../song/data/models/song_model.dart';
import '../../../song/data/repositories/song_repository.dart';
import '../../../song/presentation/providers/song_provider.dart';

/// One shared AudioPlayer instance for the whole app.
final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(player.dispose);
  return player;
});

/// Last playback problem as a user-friendly message (null = none).
/// MyApp listens to this and shows a SnackBar, then clears it.
final playbackErrorProvider = StateProvider<String?>((ref) => null);

class AudioController extends StateNotifier<int?> {
  final AudioPlayer _player;
  final SongRepository _api;
  final Ref _ref;

  StreamSubscription<PlayerState>? _completionSub;
  StreamSubscription<PlaybackEvent>? _errorSub;
  bool _progressReported = false;
  bool _isReporting = false;
  Future<void>? _recordPlayFuture;

  int _loadToken = 0; // invalidates stale/concurrent loads
  int? _loadingSongId;
  SongModel? _lastRequested;

  AudioController(this._player, this._api, this._ref) : super(null) {
    // Errors that happen DURING playback (network drop, bad stream…).
    _errorSub = _player.playbackEventStream.listen(
      (_) {},
      onError: (Object e, StackTrace st) {
        debugPrint('Playback error: $e');
        _reportError(_messageFor(e));
      },
    );
  }

  void _reportError(String message) {
    if (!mounted) return;
    try {
      _ref.read(playbackErrorProvider.notifier).state = message;
    } catch (_) {}
  }

  String _messageFor(Object e) {
    if (e is AppException) return e.message;
    if (e is TimeoutException) {
      return 'This song is taking too long to load. Please try again.';
    }
    if (e is PlayerException || e is PlayerInterruptedException) {
      return "This song can't be played right now.";
    }
    return friendlyError(e);
  }

  /// Loads and starts [song]. Never throws — failures are reported through
  /// [playbackErrorProvider] and `false` is returned.
  Future<bool> loadAndPlay(SongModel song) async {
    _lastRequested = song;
    if (!mounted) return false;
    if (state == song.id) return true;
    if (_loadingSongId == song.id) return true; // already loading this one

    if (!song.isPlayable) {
      _reportError('This song has no audio available.');
      return false;
    }

    final token = ++_loadToken;
    _loadingSongId = song.id;

    try {
      await _reportIfNeeded(completed: false);

      await _player
          .setUrl(song.media.audioUrl)
          .timeout(
            const Duration(seconds: 45),
            onTimeout: () => throw TimeoutException('setUrl timed out'),
          );

      if (token != _loadToken || !mounted) return false; // superseded

      state = song.id;
      _progressReported = false;

      unawaited(_safePlay());

      _recordPlayFuture = _api.recordPlay(song.id).catchError((Object e) {
        debugPrint('recordPlay failed: $e');
      });

      await _completionSub?.cancel();
      _completionSub = _player.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          _reportIfNeeded(completed: true);
        }
      }, onError: (Object e) => debugPrint('playerStateStream error: $e'));
      return true;
    } catch (e) {
      debugPrint('loadAndPlay failed: $e');
      if (token == _loadToken && mounted) {
        state = null;
        _reportError(_messageFor(e));
      }
      return false;
    } finally {
      if (token == _loadToken) _loadingSongId = null;
    }
  }

  Future<void> _safePlay() async {
    try {
      await _player.play();
    } catch (e) {
      debugPrint('play() failed: $e');
      _reportError(_messageFor(e));
    }
  }

  Future<void> stopAndReportProgress() async {
    _loadToken++; // cancel any in-flight load
    _loadingSongId = null;
    try {
      final actuallyCompleted =
          _player.processingState == ProcessingState.completed;
      await _reportIfNeeded(completed: actuallyCompleted);
    } catch (e) {
      debugPrint('stopAndReportProgress report failed: $e');
    }
    try {
      await _completionSub?.cancel();
      _completionSub = null;
      await _player.stop();
    } catch (e) {
      debugPrint('stop failed: $e');
    }
    if (mounted) state = null;
  }

  Future<void> _reportIfNeeded({required bool completed}) async {
    final songId = state;
    if (songId == null || _progressReported || _isReporting) return;

    _isReporting = true;
    try {
      // /play must finish before /progress so the server sees them in order.
      if (_recordPlayFuture != null) await _recordPlayFuture;

      final rawPosition = _player.position;
      final totalDuration = _player.duration;
      final clamped = (totalDuration != null && rawPosition > totalDuration)
          ? totalDuration
          : rawPosition;

      await _api.recordProgress(
        songId,
        playDuration: clamped.inSeconds,
        completed: completed,
      );
      _progressReported = true;
    } catch (e) {
      debugPrint('_reportIfNeeded failed, will retry later: $e');
    } finally {
      _isReporting = false;
    }
  }

  Future<void> togglePlayPause() async {
    try {
      // Nothing loaded (e.g. the first load failed) → retry the last song.
      if (state == null) {
        final last = _lastRequested;
        if (last != null) await loadAndPlay(last);
        return;
      }
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } catch (e) {
      _reportError(_messageFor(e));
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      debugPrint('seek failed: $e');
    }
  }

  Future<void> replay() async {
    try {
      _progressReported = false;
      await _player.seek(Duration.zero);
      await _player.play();
    } catch (e) {
      _reportError(_messageFor(e));
    }
  }

  @override
  void dispose() {
    _completionSub?.cancel();
    _errorSub?.cancel();
    super.dispose();
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
