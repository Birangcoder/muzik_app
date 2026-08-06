/// Matches the shape of the `users` table / API responses from
/// register.php, login.php, and me.php.
///
/// Changes from the original:
/// - `dispname` and `lang` removed — our `users` table has no display-name
///   or language columns. Add them as real columns + API fields if you need
///   them; don't fake them client-side.
/// - `image` renamed to `avatarUrl`, matching the API's `avatar_url` field.
/// - `isPremium` added (maps to the `is_premium` column).
/// - `createdAt` is now nullable: register.php/login.php don't return it
///   today (only id/name/email/is_premium). It'll only be populated once
///   you're pulling the user from a `me.php`-style endpoint that selects
///   the full row. Same applies to `avatarUrl`.
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isPremium;
  final DateTime? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isPremium = false,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?,
      // mysqli/PHP may serialize a TINYINT(1) as 0/1 or as a bool
      // depending on how it was cast server-side — handle both.
      isPremium: json['is_premium'] == true || json['is_premium'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    if (avatarUrl != null) 'avatar_url': avatarUrl,
    'is_premium': isPremium,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
  };
}
