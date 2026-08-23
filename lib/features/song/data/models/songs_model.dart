import 'package:muzik/shared/models/artists_model.dart';
import 'package:muzik/shared/models/reference_models.dart';

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
      audioUrl: json["audio_url"] as String,
      coverUrl: json["cover_url"] as String,
      durationSeconds: json["duration_seconds"] as int,
    );
  }
}

class MetadataModel {
  final String language;
  final DateTime releaseDate;

  MetadataModel({required this.language, required this.releaseDate});

  factory MetadataModel.fromJson(Map<String, dynamic> json) {
    return MetadataModel(
      language: json["language"] as String,
      releaseDate: DateTime.tryParse(json['release_date'] as String)!,
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
      playCount: json["play_count"] != null ? json["play_count"] as int : null,
      likeCount: json["like_count"] != null ? json["like_count"] as int : null,
      downloadCount: json["download_count"] != null
          ? json["download_count"] as int
          : null,
    );
  }
}

class SongModel {
  final int id;
  final String title;
  final String slug;
  final MediaModel media;
  final MetadataModel metaData;
  final StatisticsModel? statistics;
  final List<ArtistsModel> artists;
  final AlbumRef? album;
  final List<GenresRef>? genres;

  SongModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.media,
    required this.metaData,
    this.statistics,
    required this.artists,
    this.album,
    this.genres,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      media: MediaModel.fromJson(json['media'] as Map<String, dynamic>),
      metaData: MetadataModel.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
      statistics: json['statistics'] != null
          ? StatisticsModel.fromJson(json['statistics'] as Map<String, dynamic>)
          : null,
      artists: (json['artists'] as List)
          .map((a) => ArtistsModel.fromJson(a as Map<String, dynamic>))
          .toList(),
      album: json['album'] != null
          ? AlbumRef.fromJson(json['album'] as Map<String, dynamic>)
          : null,
      genres: json['genres'] != null
          ? (json['genres'] as List)
                .map((g) => GenresRef.fromJson(g as Map<String, dynamic>))
                .toList()
          : null,
    );
  }
}
