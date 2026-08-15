import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_config.dart';
import '../../../../core/constants/api_exception.dart';
import '../../../auth/data/repository/secure_storage_service.dart';
import '../models/songs_model.dart';

class SongRepository {
  final SecureStorageService _storage;

  SongRepository(this._storage);

  Future<List<SongModel>> fetchAllSong() async {
    final response = await http.get(Uri.parse(ApiConfig.songs));

    final data = unwrapData(response) as Map<String, dynamic>;
    final list = data['tracks'] as List;

    return list.map((e) => SongModel.fromJson(e)).toList();
  }

  Future<SongModel> fetchSongById(int id) async {
    final response = await http.get(Uri.parse(ApiConfig.song(id)));

    final data = unwrapData(response) as Map<String, dynamic>;
    return SongModel.fromJson(data);
  }

  /// POST /songs/:id/play — the side-effecting call.
  /// Bumps play_count, adds history, adds view — all handled server-side.
  // song_repository.dart

  Future<void> recordPlay(int id) async {
    final sentAt = DateTime.now();
    debugPrint('[$sentAt] recordPlay STARTING for song $id');

    final session = await _storage.readTokens();

    final response = await http.post(
      Uri.parse(ApiConfig.songPlay(id)),
      headers: {
        'Content-Type': 'application/json',
        if (session != null && session.accessToken.isNotEmpty)
          'Authorization': 'Bearer ${session.accessToken}',
      },
    );

    final completedAt = DateTime.now();
    debugPrint(
      '[$completedAt] recordPlay COMPLETED for song $id (${response.statusCode}) — took ${completedAt.difference(sentAt).inMilliseconds}ms',
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('Failed to record play for song $id (${response.statusCode})');
    }
  }

  /// POST /songs/:id/progress — fired on song end or when leaving the page.
  Future<void> recordProgress(
    int id, {
    required int playDuration,
    required bool completed,
  }) async {
    final sentAt = DateTime.now();
    debugPrint(
      '[$sentAt] recordProgress STARTING: id=$id, playDuration=$playDuration, completed=$completed',
    );

    final session = await _storage.readTokens();

    final response = await http.post(
      Uri.parse(ApiConfig.songProgress(id)),
      headers: {
        'Content-Type': 'application/json',
        if (session != null && session.accessToken.isNotEmpty)
          'Authorization': 'Bearer ${session.accessToken}',
      },
      body: jsonEncode({'play_duration': playDuration, 'completed': completed}),
    );

    final completedAt = DateTime.now();
    debugPrint(
      '[$completedAt] recordProgress COMPLETED (${response.statusCode}) — took ${completedAt.difference(sentAt).inMilliseconds}ms: ${response.body}',
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint(
        'Failed to record progress for song $id (${response.statusCode})',
      );
    }
  }
}
