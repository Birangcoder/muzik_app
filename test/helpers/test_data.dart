import 'package:muzik/features/song/data/models/song_model.dart';

/// A complete, well-formed song as the API returns it.
Map<String, dynamic> fullSongJson({int id = 1}) => {
  'id': id,
  'title': 'Song $id',
  'slug': 'song-$id',
  'haveAlbum': true,
  'media': {
    'audio_url': 'https://example.com/$id.mp3',
    'cover_url': '',
    'duration_seconds': 200,
  },
  'metadata': {'language': 'Hindi', 'release_date': '2024-05-01'},
  'statistics': {'play_count': 1200, 'like_count': 30, 'download_count': 4},
  'artists': [
    {'id': 7, 'name': 'Artist A', 'slug': 'artist-a', 'verified': true},
  ],
  'album': {
    'id': 3,
    'title': 'Album',
    'slug': 'album',
    'cover_url': '',
    'release_date': '2024-05-01',
    'album_type': 'album',
    'label': 'Label',
  },
  'genres': [
    {'id': 1, 'name': 'Pop', 'slug': 'pop'},
  ],
};

/// Worst case: every optional field is null (this used to crash with
/// "type 'Null' is not a subtype of type 'String'").
Map<String, dynamic> nullSongJson({int id = 1}) => {
  'id': id,
  'title': null,
  'slug': null,
  'haveAlbum': null,
  'media': null,
  'metadata': null,
  'statistics': null,
  'artists': null,
  'album': null,
  'genres': null,
};

/// Nulls everywhere except the audio url, so it can actually be played.
Map<String, dynamic> playableNullSongJson({int id = 1}) => {
  ...nullSongJson(id: id),
  'media': {
    'audio_url': 'https://example.com/$id.mp3',
    'cover_url': null,
    'duration_seconds': null,
  },
};

SongModel fullSong({int id = 1}) => SongModel.fromJson(fullSongJson(id: id));
SongModel nullSong({int id = 1}) => SongModel.fromJson(nullSongJson(id: id));
SongModel playableNullSong({int id = 1}) =>
    SongModel.fromJson(playableNullSongJson(id: id));

/// A genuine `type 'Null' is not a subtype of type 'String'` error object.
Object makeTypeError() {
  try {
    final dynamic x = null;
    // ignore: unused_local_variable
    final String s = x as String;
  } catch (e) {
    return e;
  }
  return StateError('unreachable');
}
