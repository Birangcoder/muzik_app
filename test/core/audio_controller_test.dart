import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzik/core/error/api_exception.dart';
import 'package:muzik/features/player/presentation/providers/audio_player_provider.dart';
import 'package:muzik/features/song/data/models/song_model.dart';
import 'package:muzik/features/song/presentation/providers/song_provider.dart';

import '../helpers/fakes.dart';
import '../helpers/test_data.dart';

void main() {
  late FakeAudioPlayer player;
  late FakeSongRepository repo;
  late ProviderContainer container;

  setUp(() {
    player = FakeAudioPlayer();
    repo = FakeSongRepository();
    container = ProviderContainer(
      overrides: [
        audioPlayerProvider.overrideWithValue(player),
        songApiServiceProvider.overrideWithValue(repo),
      ],
    );
  });

  tearDown(() => container.dispose());

  AudioController controller() =>
      container.read(audioControllerProvider.notifier);
  int? loadedId() => container.read(audioControllerProvider);
  String? error() => container.read(playbackErrorProvider);

  test('plays a normal song', () async {
    final ok = await controller().loadAndPlay(fullSong(id: 5));
    expect(ok, isTrue);
    expect(loadedId(), 5);
    expect(player.loadedUrls, ['https://example.com/5.mp3']);
    expect(error(), isNull);
    await Future<void>.delayed(Duration.zero);
    expect(repo.playedIds, [5]);
  });

  test('song with no audio url -> friendly error, nothing loaded', () async {
    final ok = await controller().loadAndPlay(nullSong());
    expect(ok, isFalse);
    expect(loadedId(), isNull);
    expect(player.loadedUrls, isEmpty);
    expect(error(), 'This song has no audio available.');
  });

  test('song with null fields but a url still plays', () async {
    final ok = await controller().loadAndPlay(playableNullSong());
    expect(ok, isTrue);
    expect(loadedId(), 1);
  });

  test('setUrl failure does not throw and gives a friendly message', () async {
    player.setUrlError = StateError('Source error 404 internal detail');
    final ok = await controller().loadAndPlay(fullSong());
    expect(ok, isFalse);
    expect(loadedId(), isNull);
    expect(error(), isNotNull);
    expect(error(), isNot(contains('internal detail')));
    expect(error(), isNot(contains('StateError')));
  });

  test('timeout is reported as a readable message', () async {
    player.setUrlError = TimeoutException('slow');
    await controller().loadAndPlay(fullSong());
    expect(error(), contains('too long'));
  });

  test('AppException messages are passed through', () async {
    player.setUrlError = const PlaybackException('Custom problem');
    await controller().loadAndPlay(fullSong());
    expect(error(), 'Custom problem');
  });

  test('calling loadAndPlay repeatedly for the same song loads once', () async {
    final gate = Completer<Duration?>();
    player.setUrlGate = gate;
    final song = fullSong(id: 8);

    final a = controller().loadAndPlay(song);
    final b = controller().loadAndPlay(song);
    final c = controller().loadAndPlay(song);
    gate.complete(const Duration(seconds: 10));
    await Future.wait([a, b, c]);

    expect(player.loadedUrls, hasLength(1));
    expect(loadedId(), 8);
  });

  test('loading the same song after success is a no-op', () async {
    await controller().loadAndPlay(fullSong(id: 2));
    await controller().loadAndPlay(fullSong(id: 2));
    expect(player.loadedUrls, hasLength(1));
  });

  test('a newer song wins over a slower older load', () async {
    final slow = Completer<Duration?>();
    player.setUrlGate = slow;
    final first = controller().loadAndPlay(fullSong(id: 1));
    await Future<void>.delayed(Duration.zero);

    player.setUrlGate = null; // second load completes immediately
    await controller().loadAndPlay(fullSong(id: 2));
    slow.complete(const Duration(seconds: 5));
    await first;

    expect(loadedId(), 2);
  });

  test('play/pause after a failed load retries the last song', () async {
    player.setUrlError = StateError('offline');
    await controller().loadAndPlay(fullSong(id: 3));
    expect(loadedId(), isNull);

    player.setUrlError = null;
    await controller().togglePlayPause();
    expect(loadedId(), 3);
  });

  test(
    'toggle with nothing requested does nothing and does not throw',
    () async {
      await controller().togglePlayPause();
      expect(loadedId(), isNull);
    },
  );

  test('errors during playback reach the user as a message', () async {
    controller(); // creates it & subscribes
    player.emitPlaybackError(StateError('stream died'));
    await Future<void>.delayed(Duration.zero);
    expect(error(), isNotNull);
    expect(error(), isNot(contains('stream died')));
  });

  test('stop clears state and reports progress once', () async {
    await controller().loadAndPlay(fullSong(id: 4));
    await Future<void>.delayed(Duration.zero);
    await controller().stopAndReportProgress();
    expect(loadedId(), isNull);
    expect(player.stopCalls, 1);
    expect(repo.progressIds, [4]);
  });

  test('stop when nothing is playing is safe', () async {
    await controller().stopAndReportProgress();
    expect(loadedId(), isNull);
  });

  test('replay and seek never throw', () async {
    await controller().loadAndPlay(fullSong());
    await controller().seek(const Duration(seconds: 3));
    await controller().replay();
  });

  test('song model helpers used by the player', () {
    expect(SongModel.fromJson(nullSongJson()).isPlayable, isFalse);
    expect(fullSong().isPlayable, isTrue);
  });
}
