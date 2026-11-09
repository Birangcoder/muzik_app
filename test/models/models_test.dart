import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:muzik/core/utils/json_utils.dart';
import 'package:muzik/features/albums/data/models/album_model.dart';
import 'package:muzik/features/albums/data/models/album_page_model.dart';
import 'package:muzik/features/auth/data/models/login_response.dart';
import 'package:muzik/features/auth/data/models/user_model.dart';
import 'package:muzik/features/home/data/models/home_model.dart';
import 'package:muzik/features/song/data/models/song_model.dart';
import 'package:muzik/shared/models/pagination_model.dart';

import '../helpers/test_data.dart';

void main() {
  group('Json helpers', () {
    test('never throw on null / wrong types', () {
      expect(Json.str(null), '');
      expect(Json.str(5), '5');
      expect(Json.str([]), '');
      expect(Json.intOf(null), 0);
      expect(Json.intOf('42'), 42);
      expect(Json.intOf('12.0'), 12);
      expect(Json.intOf(3.9), 3);
      expect(Json.boolOf(null), false);
      expect(Json.boolOf('true'), true);
      expect(Json.boolOf(1), true);
      expect(Json.dateOrNull('not a date'), isNull);
      expect(Json.dateOrNull(null), isNull);
      expect(Json.map(null), isEmpty);
      expect(Json.map('x'), isEmpty);
      expect(Json.list<int>(null, (m) => 1), isEmpty);
      expect(Json.list<int>('x', (m) => 1), isEmpty);
    });

    test('requiredInt throws FormatException when missing', () {
      expect(() => Json.requiredInt(null, 'id'), throwsFormatException);
      expect(Json.requiredInt('9', 'id'), 9);
    });

    test('list skips malformed items instead of failing', () {
      final result = Json.list<int>([
        {'id': 1},
        'garbage',
        null,
        {'id': null},
        {'id': 2},
      ], (m) => Json.requiredInt(m['id'], 'id'));
      expect(result, [1, 2]);
    });
  });

  group('SongModel', () {
    test('parses a complete song', () {
      final s = SongModel.fromJson(fullSongJson());
      expect(s.id, 1);
      expect(s.title, 'Song 1');
      expect(s.media.audioUrl, 'https://example.com/1.mp3');
      expect(s.metaData.releaseDate, DateTime(2024, 5, 1));
      expect(s.artistNames, 'Artist A');
      expect(s.album?.id, 3);
      expect(s.hasAlbum, isTrue);
      expect(s.genres, hasLength(1));
      expect(s.isPlayable, isTrue);
    });

    test('every optional field null -> no crash, sane defaults', () {
      final s = SongModel.fromJson(nullSongJson());
      expect(s.title, 'Untitled');
      expect(s.slug, '');
      expect(s.media.audioUrl, '');
      expect(s.media.coverUrl, '');
      expect(s.media.durationSeconds, 0);
      expect(s.metaData.language, '');
      expect(s.metaData.releaseDate, isNull);
      expect(s.statistics, isNull);
      expect(s.artists, isEmpty);
      expect(s.artistNames, '');
      expect(s.album, isNull);
      expect(s.haveAlbum, isNull);
      expect(s.hasAlbum, isFalse);
      expect(s.genres, isNull);
      expect(s.isPlayable, isFalse);
    });

    test('only an id is enough', () {
      expect(() => SongModel.fromJson({'id': 5}), returnsNormally);
    });

    test('missing id throws a FormatException (not a type error)', () {
      expect(() => SongModel.fromJson({'title': 'x'}), throwsFormatException);
    });

    test('numbers sent as strings and bad dates are tolerated', () {
      final s = SongModel.fromJson({
        'id': '5',
        'media': {'duration_seconds': '120', 'audio_url': ' https://a/b.mp3 '},
        'metadata': {'release_date': 'garbage'},
        'statistics': {'play_count': '10', 'like_count': null},
      });
      expect(s.id, 5);
      expect(s.media.durationSeconds, 120);
      expect(s.media.audioUrl, 'https://a/b.mp3');
      expect(s.metaData.releaseDate, isNull);
      expect(s.statistics?.playCount, 10);
      expect(s.statistics?.likeCount, isNull);
    });

    test('album with null fields does not break the song', () {
      final s = SongModel.fromJson({
        'id': 1,
        'album': {'id': 2, 'title': null, 'release_date': null},
      });
      expect(s.album?.id, 2);
      expect(s.album?.title, '');
      expect(s.album?.releaseDate, isNull);
    });

    test('artist without name gets a fallback', () {
      final s = SongModel.fromJson({
        'id': 1,
        'artists': [
          {'id': 1, 'name': null},
        ],
      });
      expect(s.artistNames, 'Unknown artist');
    });
  });

  group('SongPageModel', () {
    test('null tracks / pagination -> empty page', () {
      final p = SongPageModel.fromJson({'tracks': null, 'pagination': null});
      expect(p.tracks, isEmpty);
      expect(p.pagination.page, 1);
      expect(p.pagination.hasNext, isFalse);
    });

    test('one bad record does not drop the others', () {
      final p = SongPageModel.fromJson({
        'tracks': [
          fullSongJson(id: 1),
          {'title': 'no id'},
          'junk',
          null,
          nullSongJson(id: 2),
        ],
      });
      expect(p.tracks.map((t) => t.id), [1, 2]);
    });

    test('pagination parses', () {
      final p = PaginationModel.fromJson({
        'page': 2,
        'limit': 10,
        'total': 50,
        'total_pages': 5,
        'has_next': true,
        'has_previous': true,
      });
      expect(p.page, 2);
      expect(p.hasNext, isTrue);
      expect(p.totalPages, 5);
    });
  });

  group('HomeModel', () {
    test('empty object -> all sections empty', () {
      final h = HomeModel.fromJson(const {});
      expect(h.trending, isEmpty);
      expect(h.popular, isEmpty);
      expect(h.recommended, isEmpty);
      expect(h.newReleases, isEmpty);
      expect(h.continueListening, isEmpty);
      expect(h.artists, isEmpty);
      expect(h.albums, isEmpty);
    });

    test('null sections and bad items are tolerated', () {
      final h = HomeModel.fromJson({
        'trending': [
          fullSongJson(),
          nullSongJson(id: 2),
          {'x': 1},
        ],
        'popular': null,
        'recommended': null,
        'new_release': null,
        'continue_listening': null,
        'top_artists': [
          {'id': 1, 'name': null, 'image_url': null},
          {'name': 'no id'},
        ],
        'top_albums': [
          {'id': 1, 'title': null, 'cover_url': null, 'metadata': null},
        ],
      });
      expect(h.trending, hasLength(2));
      expect(h.artists, hasLength(1));
      expect(h.artists.first.imageUrl, isNull);
      expect(h.albums, hasLength(1));
      expect(h.albums.first.coverUrl, '');
      expect(h.albums.first.metadata.totalTracks, 0);
    });
  });

  group('Album models', () {
    test('album with only id', () {
      final a = AlbumModel.fromJson({'id': 1});
      expect(a.title, 'Untitled album');
      expect(a.coverUrl, '');
      expect(a.metaData, isNull);
      expect(a.songs, isNull);
      expect(a.artistNames, '');
    });

    test('album tracks parse and skip bad ones', () {
      final a = AlbumModel.fromJson({
        'id': 1,
        'metadata': {'release_date': null, 'description': null},
        'tracks': [
          fullSongJson(),
          {'bad': true},
        ],
      });
      expect(a.songs, hasLength(1));
      expect(a.metaData?.releaseDate, isNull);
      expect(a.metaData?.description, '');
    });

    test('album page with null everything', () {
      final p = AlbumPageModel.fromJson({'albums': null, 'pagination': null});
      expect(p.albums, isEmpty);
      expect(p.pagination.page, 1);
    });
  });

  group('Auth models', () {
    String jwt(Map<String, dynamic> payload) {
      String enc(String s) =>
          base64Url.encode(utf8.encode(s)).replaceAll('=', '');
      return '${enc('{"alg":"none"}')}.${enc(jsonEncode(payload))}.sig';
    }

    test('login response without token -> FormatException', () {
      expect(
        () => LoginResponse.fromJson({'token': null}),
        throwsFormatException,
      );
      expect(() => LoginResponse.fromJson(const {}), throwsFormatException);
    });

    test('token with exp', () {
      final r = LoginResponse.fromJson({
        'token': jwt({'exp': 4102444800}),
      });
      expect(r.isExpired, isFalse);
    });

    test('token without exp does not crash', () {
      final r = LoginResponse.fromJson({
        'token': jwt({'sub': '1'}),
      });
      expect(r.isExpired, isFalse);
    });

    test('corrupted stored session throws FormatException', () {
      expect(
        () => LoginResponse.fromStorageJson({'access_token': null}),
        throwsFormatException,
      );
    });

    test('user with null name/email', () {
      final u = UserModel.fromJson({'id': 1, 'name': null, 'email': null});
      expect(u.name, 'User');
      expect(u.email, '');
      expect(u.avatarUrl, isNull);
    });

    test('user without id -> FormatException', () {
      expect(() => UserModel.fromJson({'name': 'x'}), throwsFormatException);
    });
  });
}
