import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:muzik/core/theme/app_theme.dart';
import 'package:muzik/features/auth/data/models/login_response.dart';
import 'package:muzik/features/auth/data/models/user_model.dart';
import 'package:muzik/features/auth/data/repositories/secure_storage_service.dart';
import 'package:muzik/features/auth/presentation/providers/secure_storage_provider.dart';
import 'package:muzik/features/home/data/models/home_model.dart';
import 'package:muzik/features/home/data/repositories/home_repository.dart';
import 'package:muzik/features/home/presentation/providers/home_provider.dart';
import 'package:muzik/features/player/presentation/providers/audio_player_provider.dart';
import 'package:muzik/features/song/data/models/song_model.dart';
import 'package:muzik/features/song/data/repositories/song_repository.dart';
import 'package:muzik/features/song/presentation/providers/song_provider.dart';

/// Call in setUpAll of every widget test: stops google_fonts hitting the net.
void configureTestEnvironment() {
  GoogleFonts.config.allowRuntimeFetching = false;
}

/// ---------- Secure storage (no platform channel) ----------
class FakeSecureStorage extends SecureStorageService {
  @override
  Future<LoginResponse?> readTokens() async => null;

  @override
  Future<UserModel?> readUser() async => null;

  @override
  Future<void> saveTokens(LoginResponse tokens) async {}

  @override
  Future<void> saveUser(UserModel user) async {}

  @override
  Future<void> clearTokens() async {}
}

/// ---------- Song repository ----------
class FakeSongRepository extends SongRepository {
  FakeSongRepository({
    this.song,
    this.songError,
    this.favoriteIds = const [],
    this.addFavoriteError,
  }) : super(FakeSecureStorage());

  SongModel? song;
  Object? songError;
  List<int> favoriteIds;
  Object? addFavoriteError;

  int fetchSongCalls = 0;
  final List<int> playedIds = [];
  final List<int> progressIds = [];

  @override
  Future<SongModel> fetchSongById(int id) async {
    fetchSongCalls++;
    if (songError != null) throw songError!;
    return song!;
  }

  @override
  Future<List<int>> fetchUserFavoriteSongIds() async => favoriteIds;

  @override
  Future<void> addSongToFavorites(int id) async {
    if (addFavoriteError != null) throw addFavoriteError!;
  }

  @override
  Future<void> removeSongFromFavorites(int id) async {}

  @override
  Future<void> recordPlay(int id) async => playedIds.add(id);

  @override
  Future<void> recordProgress(
    int id, {
    required int playDuration,
    required bool completed,
  }) async => progressIds.add(id);
}

/// ---------- Home repository ----------
class FakeHomeRepository extends HomeRepository {
  FakeHomeRepository({this.home, this.error}) : super(FakeSecureStorage());

  HomeModel? home;
  Object? error;
  int calls = 0;

  @override
  Future<HomeModel> getHome() async {
    calls++;
    if (error != null) throw error!;
    return home ?? HomeModel.fromJson(const {});
  }
}

/// ---------- just_audio without platform channels ----------
class FakeAudioPlayer implements AudioPlayer {
  final _playerState = StreamController<PlayerState>.broadcast();
  final _playbackEvents = StreamController<PlaybackEvent>.broadcast();
  final _position = StreamController<Duration>.broadcast();
  final _duration = StreamController<Duration?>.broadcast();

  final List<String> loadedUrls = [];
  Object? setUrlError;
  Completer<Duration?>? setUrlGate;
  int playCalls = 0;
  int stopCalls = 0;
  bool isPlaying = false;

  void emitPlaybackError(Object error) => _playbackEvents.addError(error);

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = invocation.memberName;
    if (name == #playerStateStream) return _playerState.stream;
    if (name == #playbackEventStream) return _playbackEvents.stream;
    if (name == #positionStream) return _position.stream;
    if (name == #durationStream) return _duration.stream;
    if (name == #position) return Duration.zero;
    if (name == #duration) return null;
    if (name == #processingState) return ProcessingState.idle;
    if (name == #playing) return isPlaying;
    if (name == #setUrl) {
      loadedUrls.add(invocation.positionalArguments.first as String);
      if (setUrlGate != null) return setUrlGate!.future;
      if (setUrlError != null) return Future<Duration?>.error(setUrlError!);
      return Future<Duration?>.value(const Duration(seconds: 100));
    }
    if (name == #play) {
      playCalls++;
      isPlaying = true;
      return Future<void>.value();
    }
    if (name == #pause) {
      isPlaying = false;
      return Future<void>.value();
    }
    if (name == #stop) {
      stopCalls++;
      isPlaying = false;
      return Future<void>.value();
    }
    if (name == #seek) return Future<void>.value();
    if (name == #dispose) return _closeStreams();
    return null;
  }

  Future<void> _closeStreams() async {
    await _playerState.close();
    await _playbackEvents.close();
    await _position.close();
    await _duration.close();
  }
}

/// Providers every widget test needs, all backed by fakes.
List<Override> baseOverrides({
  FakeAudioPlayer? player,
  FakeSongRepository? songs,
  FakeHomeRepository? home,
}) => [
  secureStorageServiceProvider.overrideWithValue(FakeSecureStorage()),
  audioPlayerProvider.overrideWithValue(player ?? FakeAudioPlayer()),
  songApiServiceProvider.overrideWithValue(songs ?? FakeSongRepository()),
  homeRepositoryProvider.overrideWithValue(home ?? FakeHomeRepository()),
];

Widget wrap(Widget child, {List<Override> overrides = const []}) {
  return ProviderScope(
    retry: (retryCount, error) => null,
    overrides: overrides,
    child: MaterialApp(theme: AppTheme.light, home: child),
  );
}

/// Big test surface. flutter_test renders text with the very wide "Ahem"
/// font, so a normal phone width would give false overflow errors.
void useLargeScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400, 2800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}
