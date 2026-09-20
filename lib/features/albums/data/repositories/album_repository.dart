import 'package:http/http.dart' as http;

import '../../../../core/constants/api_config.dart';
import '../../../../core/error/api_exception.dart';
import '../../../song/data/models/song_model.dart';
import '../models/album_model.dart';
import '../models/album_page_model.dart';

class AlbumRepository {
  AlbumRepository();

  Future<AlbumPageModel> fetchAllAlbums({int page = 1, int limit = 20}) async {
    final uri = Uri.parse(ApiConfig.albums).replace(
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );

    final response = await http.get(uri);

    final data = unwrapData(response) as Map<String, dynamic>;

    return AlbumPageModel.fromJson(data);
  }

  Future<AlbumModel> fetchAlbumById(int id) async {
    final response = await http.get(Uri.parse(ApiConfig.album(id)));

    final data = unwrapData(response) as Map<String, dynamic>;

    final albumJson = data['album'] as Map<String, dynamic>? ?? data;
    final tracksJson = data['tracks'] as List?;

    return AlbumModel.fromJson(albumJson, tracksJson: tracksJson);
  }

  Future<SongPageModel> fetchAlbumTracks(
    int id, {
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse(ApiConfig.albumTracks(id)).replace(
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
    );

    final response = await http.get(uri);

    final data = unwrapData(response) as Map<String, dynamic>;

    return SongPageModel.fromJson(data);
  }

  Future<AlbumPageModel> searchAlbums(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    final uri = Uri.parse(ApiConfig.albumSearch).replace(
      queryParameters: {
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
      },
    );

    final response = await http.get(uri);

    final data = unwrapData(response) as Map<String, dynamic>;

    return AlbumPageModel.fromJson(data);
  }
}
