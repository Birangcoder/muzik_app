class UserModel {
  final String id;
  final String name;
  final String dispname;
  final String lang;
  final DateTime creationDate;
  final String image;

  const UserModel({
    required this.id,
    required this.name,
    required this.dispname,
    required this.lang,
    required this.creationDate,
    required this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      dispname: json['dispname'],
      lang: json['lang'],
      creationDate: DateTime.parse(json['creationdate']),
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dispname': dispname,
    'lang': lang,
    'creationdate': creationDate.toIso8601String().split('T').first,
    'image': image,
  };
}
