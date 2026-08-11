import 'package:muzik/core/constants/api_exception.dart';

import '../core/constants/api_config.dart';
import '../shared/models/songs_model.dart';
import 'package:http/http.dart' as http;

class SongRepository {
  Future<List<SongModel>> fetchAllSong() async {
    final response = await http.get(Uri.parse(ApiConfig.songs));

    final data = unwrapData(response) as Map<String, dynamic>;
    final list = data['tracks'] as List;

    return list.map((e) => SongModel.fromJson(e)).toList();
  }
}
