import '../../../../shared/models/pagination_model.dart';
import 'album_model.dart';

class AlbumPageModel {
  final List<AlbumModel> albums;
  final PaginationModel pagination;

  AlbumPageModel({required this.albums, required this.pagination});

  factory AlbumPageModel.fromJson(Map<String, dynamic> json) {
    return AlbumPageModel(
      albums: (json['albums'] as List? ?? json['data'] as List? ?? [])
          .map((a) => AlbumModel.fromJson(a as Map<String, dynamic>))
          .toList(),
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }
}

