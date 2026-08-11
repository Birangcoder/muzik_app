import 'artists_model.dart';

class AlbumModel {
  final int id;
  final String title;
  final String slug;
  final String coverUrl;
  final MetadataModel metadata;
  final List<ArtistsModel>? artist;

  AlbumModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.coverUrl,
    required this.metadata,
    this.artist,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      coverUrl: json['cover_url'] as String,
      metadata: MetadataModel.fromJson(
        json['metadata'] as Map<String, dynamic>,
      ),
      artist: json['artists'] != null
          ? (json['artists'] as List)
                .map((a) => ArtistsModel.fromJson(a as Map<String, dynamic>))
                .toList()
          : null,
    );
  }
}

class MetadataModel {
  final String? description;
  final DateTime releaseDate;
  final String albumType;
  final String? label;
  final String? copyright;
  final int totalTracks;

  MetadataModel({
    this.description,
    required this.releaseDate,
    required this.albumType,
    this.label,
    this.copyright,
    required this.totalTracks,
  });

  factory MetadataModel.fromJson(Map<String, dynamic> json) {
    return MetadataModel(
      description: json['description'] != null
          ? json['description'] as String
          : null,
      releaseDate: DateTime.tryParse(json['release_date'] as String)!,
      albumType: json['album_type'] as String,
      label: json['label'] != null ? json['label'] as String : null,
      copyright: json['copyright'] != null ? json['copyright'] as String : null,
      totalTracks: json['total_tracks'] as int,
    );
  }
}
