import '../../../../core/utils/json_utils.dart';

/// Matches the user object returned by /auth/register, /auth/login, and
/// GET /profile (the latter being the fullest version — register/login
/// responses may only include a subset, e.g. just id/name/email).
///
/// Fields match the profile update payload documented in the API:
/// name, avatar_url, country, birth_date, gender, bio.
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? country;
  final DateTime? birthDate;
  final String? gender;
  final String? bio;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.country,
    this.birthDate,
    this.gender,
    this.bio,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: Json.requiredInt(json['id'], 'user.id'),
      name: Json.str(json['name'], fallback: 'User'),
      email: Json.str(json['email']),
      avatarUrl: Json.strOrNull(json['avatar_url']),
      country: Json.strOrNull(json['country']),
      birthDate: Json.dateOrNull(json['birth_date']),
      gender: Json.strOrNull(json['gender']),
      bio: Json.strOrNull(json['bio']),
      createdAt: Json.dateOrNull(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
    if (country != null) 'country': country,
    if (birthDate != null)
      'birth_date': birthDate!.toIso8601String().split('T').first,
    if (gender != null) 'gender': gender,
    if (bio != null) 'bio': bio,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };

  /// For PUT /profile — only the fields the API actually accepts as
  /// updatable, per section 17 of the README.
  Map<String, dynamic> toUpdatePayload() => {
    'name': name,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
    if (country != null) 'country': country,
    if (birthDate != null)
      'birth_date': birthDate!.toIso8601String().split('T').first,
    if (gender != null) 'gender': gender,
    if (bio != null) 'bio': bio,
  };
}
