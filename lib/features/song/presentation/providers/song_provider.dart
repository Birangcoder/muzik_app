import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/secure_storage_provider.dart';
import '../../data/repository/song_repository.dart';
import '../../data/models/songs_model.dart';

final songApiServiceProvider = Provider<SongRepository>((ref) {
  return SongRepository(ref.watch(secureStorageServiceProvider));
});

// Fetches ONE song by id — this is what SongPage will watch.
final songProvider = FutureProvider.family<SongModel, int>((ref, id) async {
  final api = ref.watch(songApiServiceProvider);
  return api.fetchSongById(id);
});

// Optional: full list, e.g. for a home/list page.
final songListProvider = FutureProvider<List<SongModel>>((ref) async {
  final api = ref.watch(songApiServiceProvider);
  return api.fetchAllSong();
});

final userFavoritesProvider = FutureProvider<List<int>>((ref) async {
  final api = ref.watch(songApiServiceProvider);
  return api.fetchUserFavoriteSongIds();
});