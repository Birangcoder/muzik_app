import '../../core/utils/json_utils.dart';

class ArtistsModelRef {
  final int id;
  final String name;
  final String slug;
  final String? imageUrl;
  final bool? verified;
  final String? role;

  ArtistsModelRef({
    required this.id,
    required this.name,
    required this.slug,
    this.imageUrl,
    this.verified,
    this.role,
  });

  factory ArtistsModelRef.fromJson(Map<String, dynamic> json) {
    return ArtistsModelRef(
      id: Json.requiredInt(json['id'], 'artist.id'),
      name: Json.str(json['name'], fallback: 'Unknown artist'),
      slug: Json.str(json['slug']),
      imageUrl: Json.strOrNull(json['image_url']),
      verified: Json.boolOrNull(json['verified']),
      role: Json.strOrNull(json['role']),
    );
  }
}
