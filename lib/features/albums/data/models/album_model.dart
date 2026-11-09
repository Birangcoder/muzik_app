import '../../../../core/utils/json_utils.dart';
import '../../../../shared/models/artist_model_ref.dart';
import '../../../song/data/models/song_model.dart';

class AlbumModel {
  final int id;
  final String title;
  final String slug;
  final String coverUrl;
  final List<ArtistsModelRef>? artists;
  final AlbumMetadata? metaData;
  final List<SongModel>? songs;

  AlbumModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.coverUrl,
    this.artists,
    this.metaData,
    this.songs,
  });

  String get artistNames => (artists ?? const []).map((a) => a.name).join(', ');

  factory AlbumModel.fromJson(
    Map<String, dynamic> json, {
    List<dynamic>? tracksJson,
  }) {
    final rawTracks =
        tracksJson ?? (json['tracks'] is List ? json['tracks'] : null);
    return AlbumModel(
      id: Json.requiredInt(json['id'], 'album.id'),
      title: Json.str(json['title'], fallback: 'Untitled album'),
      slug: Json.str(json['slug']),
      coverUrl: Json.str(json['cover_url']),
      metaData: Json.mapOrNull(json['metadata']) != null
          ? AlbumMetadata.fromJson(Json.map(json['metadata']))
          : null,
      artists: Json.list(json['artists'], ArtistsModelRef.fromJson),
      songs: rawTracks == null
          ? null
          : Json.list(rawTracks, SongModel.fromJson),
    );
  }
}

class AlbumMetadata {
  final String description;
  final DateTime? releaseDate;
  final String albumType;
  final String label;
  final int totalTracks;

  AlbumMetadata({
    required this.description,
    required this.albumType,
    required this.releaseDate,
    required this.label,
    required this.totalTracks,
  });

  factory AlbumMetadata.fromJson(Map<String, dynamic> json) {
    return AlbumMetadata(
      description: Json.str(json['description']),
      albumType: Json.str(json['album_type']),
      label: Json.str(json['label']),
      totalTracks: Json.intOf(json['total_tracks']),
      releaseDate: Json.dateOrNull(json['release_date']),
    );
  }
}
