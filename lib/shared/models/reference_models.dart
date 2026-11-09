import '../../core/utils/json_utils.dart';

class AlbumRef {
  final int id;
  final String title;
  final String slug;
  final String coverUrl;
  final DateTime? releaseDate;
  final String albumType;
  final String label;

  AlbumRef({
    required this.id,
    required this.title,
    required this.slug,
    required this.coverUrl,
    required this.releaseDate,
    required this.albumType,
    required this.label,
  });

  factory AlbumRef.fromJson(Map<String, dynamic> json) {
    return AlbumRef(
      id: Json.requiredInt(json['id'], 'album.id'),
      title: Json.str(json['title']),
      slug: Json.str(json['slug']),
      coverUrl: Json.str(json['cover_url']),
      releaseDate: Json.dateOrNull(json['release_date']),
      albumType: Json.str(json['album_type']),
      label: Json.str(json['label']),
    );
  }
}

class GenresRef {
  final int id;
  final String title;
  final String slug;

  GenresRef({required this.id, required this.title, required this.slug});

  factory GenresRef.fromJson(Map<String, dynamic> json) {
    return GenresRef(
      id: Json.requiredInt(json['id'], 'genre.id'),
      title: Json.str(json['name'] ?? json['title']),
      slug: Json.str(json['slug']),
    );
  }
}
