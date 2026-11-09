import '../../../../core/constants/api_config.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json_utils.dart';
import '../../../song/data/models/song_model.dart';
import '../models/album_model.dart';
import '../models/album_page_model.dart';

class AlbumRepository {
  AlbumRepository();

  Uri _paged(String base, int page, int limit, [Map<String, String>? extra]) =>
      Uri.parse(base).replace(
        queryParameters: {
          ...?extra,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

  Future<AlbumPageModel> fetchAllAlbums({int page = 1, int limit = 20}) async {
    final response = await ApiClient.get(_paged(ApiConfig.albums, page, limit));
    return AlbumPageModel.fromJson(unwrapMap(response));
  }

  Future<AlbumModel> fetchAlbumById(int id) async {
    final response = await ApiClient.get(Uri.parse(ApiConfig.album(id)));
    final data = unwrapMap(response);

    final albumJson = Json.mapOrNull(data['album']) ?? data;
    final tracks = data['tracks'];

    return AlbumModel.fromJson(
      albumJson,
      tracksJson: tracks is List ? tracks : null,
    );
  }

  Future<SongPageModel> fetchAlbumTracks(
    int id, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiClient.get(
      _paged(ApiConfig.albumTracks(id), page, limit),
    );
    return SongPageModel.fromJson(unwrapMap(response));
  }

  Future<AlbumPageModel> searchAlbums(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiClient.get(
      _paged(ApiConfig.albumSearch, page, limit, {'q': query}),
    );
    return AlbumPageModel.fromJson(unwrapMap(response));
  }
}
