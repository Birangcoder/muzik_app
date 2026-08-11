class ArtistsModel {
  final int id;
  final String name;
  final String slug;
  final String? imageUrl;
  final bool? verified;
  final String? role;

  ArtistsModel({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
    this.verified,
    this.role,
  });

  factory ArtistsModel.fromJson(Map<String, dynamic> json) {
    return ArtistsModel(
      id: json["id"] as int,
      name: json["name"] as String,
      slug: json["slug"] as String,
      imageUrl: json["image_url"] != null ? json["image_url"] as String : null,
      verified: json["verified"] != null ? json["verified"] as bool : null,
      role: json["role"] as String?
    );
  }
}
