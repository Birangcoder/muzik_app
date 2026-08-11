class AlbumRef {
  final int id;
  final String title;
  final String slug;
  final String coverUrl;
  final DateTime releaseDate;
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
      id: json["id"] as int,
      title: json["title"] as String,
      slug: json["slug"] as String,
      coverUrl: json["cover_url"] as String,
      releaseDate: DateTime.tryParse(json["release_date"] as String)!,
      albumType: json["album_type"] as String,
      label: json["label"] as String,
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
      id: json["id"] as int,
      title: json["name"] as String,
      slug: json["slug"] as String,
    );
  }
}
