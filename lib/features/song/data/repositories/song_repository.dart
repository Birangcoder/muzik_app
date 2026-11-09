import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_config.dart';
import '../../../../core/error/api_exception.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/json_utils.dart';
import '../../../auth/data/repositories/secure_storage_service.dart';
import '../models/song_model.dart';

class SongRepository {
  final SecureStorageService _storage;

  SongRepository(this._storage);

  Future<Map<String, String>> _headers({bool json = false}) async {
    String? token;
    try {
      token = (await _storage.readTokens())?.accessToken;
    } catch (_) {}
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Uri _paged(String base, int page, int limit) => Uri.parse(base).replace(
    queryParameters: {'page': page.toString(), 'limit': limit.toString()},
  );

  Future<List<SongModel>> fetchAllSong() async {
    final response = await ApiClient.get(Uri.parse(ApiConfig.songs));
    final data = unwrapMap(response);
    return Json.list(data['tracks'], SongModel.fromJson);
  }

  Future<SongPageModel> fetchTrendingSong({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiClient.get(
      _paged(ApiConfig.trending, page, limit),
    );
    return SongPageModel.fromJson(unwrapMap(response));
  }

  Future<SongPageModel> fetchLatestSong({int page = 1, int limit = 20}) async {
    final response = await ApiClient.get(
      _paged(ApiConfig.latestSong, page, limit),
    );
    return SongPageModel.fromJson(unwrapMap(response));
  }

  Future<SongPageModel> fetchRecommendedSong({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiClient.get(
      _paged(ApiConfig.recommendedSong, page, limit),
      headers: await _headers(json: true),
    );
    return SongPageModel.fromJson(unwrapMap(response));
  }

  Future<SongPageModel> fetchHistory({int page = 1, int limit = 20}) async {
    final response = await ApiClient.get(
      _paged(ApiConfig.history, page, limit),
      headers: await _headers(json: true),
    );
    return SongPageModel.fromJson(unwrapMap(response));
  }

  Future<SongModel> fetchSongById(int id) async {
    final response = await ApiClient.get(Uri.parse(ApiConfig.song(id)));
    final data = unwrapMap(response);
    // Some APIs wrap the song as {"track": {...}} / {"song": {...}}.
    final inner = Json.mapOrNull(data['track'] ?? data['song']) ?? data;
    return SongModel.fromJson(inner);
  }

  Future<SongPageModel> fetchFavoriteSong({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiClient.get(
      _paged(ApiConfig.songFavorite, page, limit),
      headers: await _headers(json: true),
    );
    return SongPageModel.fromJson(unwrapMap(response));
  }

  /// IDs of every favourite song (walks all pages, so favourites beyond the
  /// first page are still recognised as liked).
  Future<List<int>> fetchUserFavoriteSongIds() async {
    final headers = await _headers(json: true);
    if (!headers.containsKey('Authorization')) return <int>[];

    final ids = <int>[];
    var page = 1;
    while (page <= 50) {
      final response = await ApiClient.get(
        _paged(ApiConfig.songFavorite, page, 100),
        headers: headers,
      );
      final result = SongPageModel.fromJson(unwrapMap(response));
      ids.addAll(result.tracks.map((s) => s.id));
      if (!result.pagination.hasNext || result.tracks.isEmpty) break;
      page++;
    }
    return ids;
  }

  Future<void> addSongToFavorites(int id) async {
    final response = await ApiClient.post(
      Uri.parse(ApiConfig.songFavorite),
      headers: await _headers(json: true),
      body: jsonEncode({'song_id': id}),
    );
    unwrapData(response); // throws a friendly ApiException on failure
  }

  Future<void> removeSongFromFavorites(int id) async {
    final response = await ApiClient.delete(
      Uri.parse(ApiConfig.songRemoveFavorite(id)),
      headers: await _headers(json: true),
    );
    unwrapData(response);
  }

  /// POST /songs/:id/play — best effort analytics call; never throws.
  Future<void> recordPlay(int id) async {
    try {
      final response = await ApiClient.post(
        Uri.parse(ApiConfig.songPlay(id)),
        headers: await _headers(json: true),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        debugPrint(
          'Failed to record play for song $id (${response.statusCode})',
        );
      }
    } catch (e) {
      debugPrint('recordPlay failed: $e');
    }
  }

  /// POST /songs/:id/progress — returns normally only on success so the
  /// caller can retry later when it fails.
  Future<void> recordProgress(
    int id, {
    required int playDuration,
    required bool completed,
  }) async {
    final response = await ApiClient.post(
      Uri.parse(ApiConfig.songProgress(id)),
      headers: await _headers(json: true),
      body: jsonEncode({'play_duration': playDuration, 'completed': completed}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw ApiException(
        'Failed to record progress',
        statusCode: response.statusCode,
      );
    }
  }
}
