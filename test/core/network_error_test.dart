import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muzik/core/error/api_exception.dart';
import 'package:muzik/core/error/error_message.dart';
import 'package:muzik/core/network/api_client.dart';
import 'package:muzik/features/albums/data/repositories/album_repository.dart';
import 'package:muzik/features/home/data/repositories/home_repository.dart';
import 'package:muzik/features/song/data/repositories/song_repository.dart';

import '../helpers/fakes.dart';
import '../helpers/test_data.dart';

http.Response jsonRes(Object body, [int code = 200]) => http.Response(
  jsonEncode(body),
  code,
  headers: {'content-type': 'application/json'},
);

void useClient(MockClientHandler handler) {
  ApiClient.client = MockClient(handler);
}

void main() {
  final originalClient = ApiClient.client;
  tearDown(() => ApiClient.client = originalClient);

  group('unwrapData / unwrapMap', () {
    test('returns data on success', () {
      expect(
        unwrapData(
          jsonRes({
            'success': true,
            'data': {'a': 1},
          }),
        ),
        {'a': 1},
      );
    });

    test('success:false uses server message', () {
      expect(
        () => unwrapData(jsonRes({'success': false, 'message': 'Nope'}, 422)),
        throwsA(
          isA<ApiException>().having((e) => e.message, 'message', 'Nope'),
        ),
      );
    });

    test('success:false without message gets a friendly default', () {
      expect(
        () => unwrapData(jsonRes({'success': false}, 500)),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('server'),
          ),
        ),
      );
    });

    test('non-string message / non-map errors are ignored safely', () {
      try {
        unwrapData(
          jsonRes({'success': false, 'message': 123, 'errors': 'x'}, 400),
        );
        fail('should throw');
      } on ApiException catch (e) {
        expect(e.fieldErrors, isNull);
        expect(e.message, isNotEmpty);
      }
    });

    test('field errors are exposed', () {
      try {
        unwrapData(
          jsonRes({
            'success': false,
            'message': 'Invalid',
            'errors': {
              'email': ['Required'],
            },
          }, 422),
        );
        fail('should throw');
      } on ApiException catch (e) {
        expect(e.firstErrorFor('email'), 'Required');
        expect(e.firstErrorFor('other'), isNull);
      }
    });

    test('HTML / garbage body -> ApiException, not FormatException', () {
      expect(
        () => unwrapData(http.Response('<html>502</html>', 502)),
        throwsA(isA<ApiException>()),
      );
      expect(
        () => unwrapData(http.Response('', 200)),
        throwsA(isA<ApiException>()),
      );
    });

    test('401 maps to a session message', () {
      expect(
        () => unwrapData(http.Response('', 401)),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('session'),
          ),
        ),
      );
    });

    test(
      'unwrapMap on null data -> ApiException (no "Null is not a subtype")',
      () {
        expect(
          () => unwrapMap(jsonRes({'success': true, 'data': null})),
          throwsA(isA<ApiException>()),
        );
        expect(
          () => unwrapMap(
            jsonRes({
              'success': true,
              'data': [1, 2],
            }),
          ),
          throwsA(isA<ApiException>()),
        );
      },
    );
  });

  group('friendlyError', () {
    test('never leaks raw Dart type errors', () {
      Object? captured;
      try {
        final dynamic x = null;
        // ignore: unused_local_variable
        final String s = x as String;
      } catch (e) {
        captured = e;
      }
      final msg = friendlyError(captured);
      expect(msg.toLowerCase(), isNot(contains('subtype')));
      expect(msg.toLowerCase(), isNot(contains('null')));
      expect(msg, isNotEmpty);
    });

    test('keeps readable messages', () {
      expect(
        friendlyError(const ApiException('Nope', statusCode: 400)),
        'Nope',
      );
      expect(friendlyError(const PlaybackException('Bad audio')), 'Bad audio');
      expect(friendlyError(TimeoutException('x')), contains('timed out'));
      expect(friendlyError(const FormatException('x')), contains('unexpected'));
      expect(friendlyError(null), isNotEmpty);
      expect(
        friendlyError(StateError('internal')),
        isNot(contains('internal')),
      );
      expect(friendlyError(RangeError('x')), isNot(contains('RangeError')));
    });
  });

  group('ApiClient', () {
    test('connection failure -> friendly "no internet" ApiException', () async {
      useClient((_) async => throw http.ClientException('Failed host lookup'));
      expect(
        () => ApiClient.get(Uri.parse('https://x.test/a')),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('internet'),
          ),
        ),
      );
    });

    test('unknown failure -> ApiException', () async {
      useClient((_) async => throw StateError('boom'));
      expect(
        () => ApiClient.get(Uri.parse('https://x.test/a')),
        throwsA(isA<ApiException>()),
      );
    });
  });

  group('SongRepository', () {
    final repo = SongRepository(FakeSecureStorage());

    test('fetchSongById with null-heavy song works', () async {
      useClient(
        (_) async => jsonRes({'success': true, 'data': nullSongJson()}),
      );
      final song = await repo.fetchSongById(1);
      expect(song.id, 1);
      expect(song.title, 'Untitled');
    });

    test('fetchSongById unwraps {track: {...}}', () async {
      useClient(
        (_) async => jsonRes({
          'success': true,
          'data': {'track': fullSongJson(id: 9)},
        }),
      );
      expect((await repo.fetchSongById(9)).id, 9);
    });

    test('data:null -> friendly ApiException', () async {
      useClient((_) async => jsonRes({'success': true, 'data': null}));
      expect(() => repo.fetchSongById(1), throwsA(isA<ApiException>()));
    });

    test('trending with tracks:null -> empty page', () async {
      useClient(
        (_) async => jsonRes({
          'success': true,
          'data': {'tracks': null, 'pagination': null},
        }),
      );
      final page = await repo.fetchTrendingSong();
      expect(page.tracks, isEmpty);
    });

    test('server error is surfaced as ApiException', () async {
      useClient((_) async => http.Response('oops', 500));
      expect(() => repo.fetchLatestSong(), throwsA(isA<ApiException>()));
    });

    test('favorite ids without a session -> empty list, no request', () async {
      var called = false;
      useClient((_) async {
        called = true;
        return jsonRes({'success': true, 'data': {}});
      });
      expect(await repo.fetchUserFavoriteSongIds(), isEmpty);
      expect(called, isFalse);
    });

    test('addSongToFavorites throws when the server rejects it', () async {
      useClient(
        (_) async => jsonRes({'success': false, 'message': 'Login first'}, 401),
      );
      expect(
        () => repo.addSongToFavorites(1),
        throwsA(
          isA<ApiException>().having((e) => e.message, 'm', 'Login first'),
        ),
      );
    });

    test('recordPlay never throws, even when offline', () async {
      useClient((_) async => throw http.ClientException('offline'));
      await repo.recordPlay(1); // must complete normally
    });
  });

  group('HomeRepository', () {
    final repo = HomeRepository(FakeSecureStorage());

    test('home with null sections', () async {
      useClient(
        (_) async => jsonRes({
          'success': true,
          'data': {'trending': null, 'popular': null},
        }),
      );
      final home = await repo.getHome();
      expect(home.trending, isEmpty);
    });

    test('home failure carries the server message', () async {
      useClient(
        (_) async => jsonRes({'success': false, 'message': 'Down'}, 503),
      );
      expect(
        () => repo.getHome(),
        throwsA(isA<ApiException>().having((e) => e.message, 'm', 'Down')),
      );
    });
  });

  group('AlbumRepository', () {
    final repo = AlbumRepository();

    test('album by id with null metadata and tracks', () async {
      useClient(
        (_) async => jsonRes({
          'success': true,
          'data': {
            'album': {'id': 4, 'title': null, 'metadata': null},
            'tracks': null,
          },
        }),
      );
      final album = await repo.fetchAlbumById(4);
      expect(album.id, 4);
      expect(album.songs, isNull);
    });

    test('album with tracks', () async {
      useClient(
        (_) async => jsonRes({
          'success': true,
          'data': {
            'id': 4,
            'title': 'A',
            'tracks': [fullSongJson(id: 1), nullSongJson(id: 2)],
          },
        }),
      );
      final album = await repo.fetchAlbumById(4);
      expect(album.songs, hasLength(2));
    });
  });
}
