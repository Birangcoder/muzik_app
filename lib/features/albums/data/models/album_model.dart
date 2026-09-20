import '../../../../shared/models/artist_model_ref.dart';
import '../../../song/data/models/song_model.dart';

class AlbumModel {
  final int id;
  final String title;
  final String slug;
  final String coverUrl;
  final List<ArtistsModelRef>? artists;
  final MetadataModel? metaData;
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

  factory AlbumModel.fromJson(Map<String, dynamic> json, {List<dynamic>? tracksJson}) {
    return AlbumModel(
      id: json["id"] as int,
      title: json["title"] as String,
      slug: json["slug"] as String,
      coverUrl: json["cover_url"] as String,
      metaData: json['metadata'] != null
          ? MetadataModel.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
      artists: json['artists'] != null
          ? (json['artists'] as List)
                .map((a) => ArtistsModelRef.fromJson(a as Map<String, dynamic>))
                .toList()
          : null,
      songs: (tracksJson ?? json['tracks'] as List?)
          ?.map((a) => SongModel.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MetadataModel {
  final String description;
  final DateTime releaseDate;
  final String albumType;
  final String label;
  final int totalTracks;

  MetadataModel({
    required this.description,
    required this.albumType,
    required this.releaseDate,
    required this.label,
    required this.totalTracks,
  });

  factory MetadataModel.fromJson(Map<String, dynamic> json) {
    return MetadataModel(
      description: json["description"] as String,
      albumType: json["album_type"] as String,
      label: json["label"] as String,
      totalTracks: json["total_tracks"] as int,
      releaseDate: DateTime.tryParse(json['release_date'] as String)!,
    );
  }
}
