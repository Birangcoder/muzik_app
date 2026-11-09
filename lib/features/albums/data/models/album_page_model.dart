import '../../../../core/utils/json_utils.dart';
import '../../../../shared/models/pagination_model.dart';
import 'album_model.dart';

class AlbumPageModel {
  final List<AlbumModel> albums;
  final PaginationModel pagination;

  AlbumPageModel({required this.albums, required this.pagination});

  factory AlbumPageModel.fromJson(Map<String, dynamic> json) {
    return AlbumPageModel(
      albums: Json.list(
        json['albums'] is List ? json['albums'] : json['data'],
        AlbumModel.fromJson,
      ),
      pagination: PaginationModel.fromJson(Json.map(json['pagination'])),
    );
  }
}
