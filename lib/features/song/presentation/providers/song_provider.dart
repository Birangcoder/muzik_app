import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../../auth/presentation/providers/secure_storage_provider.dart';
import '../../data/models/song_model.dart';
import '../../data/repositories/song_repository.dart';

final songApiServiceProvider = Provider<SongRepository>((ref) {
  return SongRepository(ref.watch(secureStorageServiceProvider));
});

// Fetches ONE song by id — this is what SongPage will watch.
final songProvider = FutureProvider.family<SongModel, int>((ref, id) async {
  final api = ref.watch(songApiServiceProvider);
  return api.fetchSongById(id);
}, retry: (retryCount, error) => null);

final songListProvider = FutureProvider<List<SongModel>>((ref) async {
  final api = ref.watch(songApiServiceProvider);
  return api.fetchAllSong();
});

/// Re-fetched automatically when the user logs in / out.
final userFavoritesProvider = FutureProvider<List<int>>((ref) async {
  ref.watch(currentUserProvider);
  final api = ref.watch(songApiServiceProvider);
  return api.fetchUserFavoriteSongIds();
});
