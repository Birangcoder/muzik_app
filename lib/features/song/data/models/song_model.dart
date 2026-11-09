import '../../../../core/utils/json_utils.dart';
import '../../../../shared/models/artist_model_ref.dart';
import '../../../../shared/models/pagination_model.dart';
import '../../../../shared/models/reference_models.dart';

class MediaModel {
  final String audioUrl;
  final String coverUrl;
  final int durationSeconds;

  MediaModel({
    required this.audioUrl,
    required this.coverUrl,
    required this.durationSeconds,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      audioUrl: Json.str(json['audio_url']).trim(),
      coverUrl: Json.str(json['cover_url']).trim(),
      durationSeconds: Json.intOf(json['duration_seconds']),
    );
  }
}

class MetadataModel {
  final String language;
  final DateTime? releaseDate;

  MetadataModel({required this.language, this.releaseDate});

  factory MetadataModel.fromJson(Map<String, dynamic> json) {
    return MetadataModel(
      language: Json.str(json['language']),
      releaseDate: Json.dateOrNull(json['release_date']),
    );
  }
}

class StatisticsModel {
  final int? playCount;
  final int? likeCount;
  final int? downloadCount;

  StatisticsModel({
    required this.playCount,
    required this.likeCount,
    required this.downloadCount,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      playCount: Json.intOrNull(json['play_count']),
      likeCount: Json.intOrNull(json['like_count']),
      downloadCount: Json.intOrNull(json['download_count']),
    );
  }
}

class SongModel {
  final int id;
  final String title;
  final String slug;
  final bool? haveAlbum;
  final MediaModel media;
  final MetadataModel metaData;
  final StatisticsModel? statistics;
  final List<ArtistsModelRef> artists;
  final AlbumRef? album;
  final List<GenresRef>? genres;

  SongModel({
    required this.id,
    required this.title,
    required this.slug,
    this.haveAlbum,
    required this.media,
    required this.metaData,
    this.statistics,
    this.artists = const [],
    this.album,
    this.genres,
  });

  /// "Artist A, Artist B" — empty string when unknown. Never null.
  String get artistNames => artists.map((a) => a.name).join(', ');

  bool get isPlayable => media.audioUrl.isNotEmpty;

  bool get hasAlbum => album != null && (haveAlbum ?? true);

  factory SongModel.fromJson(Map<String, dynamic> json) {
    final albumJson = Json.mapOrNull(json['album']);
    return SongModel(
      id: Json.requiredInt(json['id'], 'song.id'),
      title: Json.str(json['title'], fallback: 'Untitled'),
      slug: Json.str(json['slug']),
      haveAlbum: Json.boolOrNull(json['haveAlbum'] ?? json['have_album']),
      media: MediaModel.fromJson(Json.map(json['media'])),
      metaData: MetadataModel.fromJson(Json.map(json['metadata'])),
      statistics: Json.mapOrNull(json['statistics']) != null
          ? StatisticsModel.fromJson(Json.map(json['statistics']))
          : null,
      artists: Json.list(json['artists'], ArtistsModelRef.fromJson),
      album: (albumJson != null && albumJson['id'] != null)
          ? _tryAlbum(albumJson)
          : null,
      genres: json['genres'] is List
          ? Json.list(json['genres'], GenresRef.fromJson)
          : null,
    );
  }

  static AlbumRef? _tryAlbum(Map<String, dynamic> j) {
    try {
      return AlbumRef.fromJson(j);
    } catch (_) {
      return null;
    }
  }
}

class SongPageModel {
  final List<SongModel> tracks;
  final PaginationModel pagination;

  const SongPageModel({required this.tracks, required this.pagination});

  factory SongPageModel.fromJson(Map<String, dynamic> json) {
    return SongPageModel(
      tracks: Json.list(json['tracks'], SongModel.fromJson),
      pagination: PaginationModel.fromJson(Json.map(json['pagination'])),
    );
  }
}
