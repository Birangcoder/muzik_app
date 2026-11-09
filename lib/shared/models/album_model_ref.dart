import '../../core/utils/json_utils.dart';
import 'artist_model_ref.dart';

class AlbumModelRef {
  final int id;
  final String title;
  final String slug;
  final String coverUrl;
  final MetadataModel metadata;
  final List<ArtistsModelRef>? artist;

  AlbumModelRef({
    required this.id,
    required this.title,
    required this.slug,
    required this.coverUrl,
    required this.metadata,
    this.artist,
  });

  factory AlbumModelRef.fromJson(Map<String, dynamic> json) {
    return AlbumModelRef(
      id: Json.requiredInt(json['id'], 'album.id'),
      title: Json.str(json['title'], fallback: 'Untitled album'),
      slug: Json.str(json['slug']),
      coverUrl: Json.str(json['cover_url']),
      metadata: MetadataModel.fromJson(Json.map(json['metadata'])),
      artist: Json.list(json['artists'], ArtistsModelRef.fromJson),
    );
  }

  String get artistNames => (artist ?? const []).map((a) => a.name).join(', ');
}

class MetadataModel {
  final String? description;
  final DateTime? releaseDate;
  final String albumType;
  final String? label;
  final String? copyright;
  final int totalTracks;

  MetadataModel({
    this.description,
    this.releaseDate,
    required this.albumType,
    this.label,
    this.copyright,
    required this.totalTracks,
  });

  factory MetadataModel.fromJson(Map<String, dynamic> json) {
    return MetadataModel(
      description: Json.strOrNull(json['description']),
      releaseDate: Json.dateOrNull(json['release_date']),
      albumType: Json.str(json['album_type']),
      label: Json.strOrNull(json['label']),
      copyright: Json.strOrNull(json['copyright']),
      totalTracks: Json.intOf(json['total_tracks']),
    );
  }
}
