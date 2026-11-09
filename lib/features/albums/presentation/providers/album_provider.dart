import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../song/data/models/song_model.dart';
import '../../../song/data/models/track_state.dart';
import '../../data/models/album_list_state.dart';
import '../../data/models/album_model.dart';
import '../../data/models/album_page_model.dart';
import '../../data/repositories/album_repository.dart';
import 'album_list_notifier.dart';

final albumApiServiceProvider = Provider<AlbumRepository>((ref) {
  return AlbumRepository();
});

// Fetches ONE album by id — for AlbumPage.
final albumProvider = FutureProvider.family<AlbumModel, int>((ref, id) async {
  final api = ref.watch(albumApiServiceProvider);
  return api.fetchAlbumById(id);
});

// ---------- Albums list (GET /albums) ----------
class AlbumsNotifier extends AlbumListNotifier {
  late final AlbumRepository _repository = ref.read(albumApiServiceProvider);

  @override
  Future<AlbumPageModel> fetchPage({required int page, required int limit}) {
    return _repository.fetchAllAlbums(page: page, limit: limit);
  }
}

final albumListProvider = NotifierProvider<AlbumsNotifier, AlbumListState>(
  AlbumsNotifier.new,
);

// ---------- Album tracks (GET /albums/:id/tracks), one instance per album id ----------
class AlbumTracksNotifier extends Notifier<TrackState> {
  final int albumId;

  AlbumTracksNotifier(this.albumId);

  late final AlbumRepository _repository = ref.read(albumApiServiceProvider);
  static const int limit = 20;

  @override
  TrackState build() {
    Future.microtask(loadInitial);
    return const TrackState(isLoading: true);
  }

  Future<SongPageModel> fetchPage({required int page, required int limit}) {
    return _repository.fetchAlbumTracks(albumId, page: page, limit: limit);
  }

  Future<void> loadInitial() async {
    try {
      state = const TrackState(isLoading: true);
      final response = await fetchPage(page: 1, limit: limit);
      if (!ref.mounted) return;
      state = TrackState(
        tracks: response.tracks,
        page: response.pagination.page,
        hasNext: response.pagination.hasNext,
      );
    } catch (e) {
      if (ref.mounted) state = TrackState(error: e);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading || !state.hasNext) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.page + 1;
      final response = await fetchPage(page: nextPage, limit: limit);
      if (!ref.mounted) return;
      state = state.copyWith(
        tracks: [...state.tracks, ...response.tracks],
        page: response.pagination.page,
        hasNext: response.pagination.hasNext,
        isLoadingMore: false,
      );
    } catch (e) {
      if (ref.mounted) state = state.copyWith(isLoadingMore: false, error: e);
    }
  }

  Future<void> refresh() => loadInitial();
}

final albumTracksProvider =
    NotifierProvider.family<AlbumTracksNotifier, TrackState, int>(
      (albumId) => AlbumTracksNotifier(albumId),
    );

// ---------- Album search (GET /albums/search?q=) ----------
class AlbumSearchNotifier extends AlbumListNotifier {
  late final AlbumRepository _repository = ref.read(albumApiServiceProvider);
  String query = '';

  @override
  AlbumListState build() => const AlbumListState(); // no auto-fetch on build

  @override
  Future<AlbumPageModel> fetchPage({required int page, required int limit}) {
    return _repository.searchAlbums(query, page: page, limit: limit);
  }

  Future<void> search(String q) async {
    query = q;
    if (q.trim().isEmpty) {
      state = const AlbumListState();
      return;
    }
    await loadInitial();
  }
}

final albumSearchProvider =
    NotifierProvider<AlbumSearchNotifier, AlbumListState>(
      AlbumSearchNotifier.new,
    );
