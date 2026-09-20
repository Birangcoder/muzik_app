import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/album_list_state.dart';
import '../../data/models/album_page_model.dart';

abstract class AlbumListNotifier extends Notifier<AlbumListState> {
  static const int limit = 20;

  /// The only thing each concrete list needs to implement — the actual
  /// network call for one page.
  Future<AlbumPageModel> fetchPage({required int page, required int limit});

  @override
  AlbumListState build() {
    Future.microtask(loadInitial);
    return const AlbumListState(isLoading: true);
  }

  Future<void> loadInitial() async {
    try {
      state = const AlbumListState(isLoading: true);
      final response = await fetchPage(page: 1, limit: limit);
      state = AlbumListState(
        albums: response.albums,
        page: response.pagination.page,
        hasNext: response.pagination.hasNext,
      );
    } catch (e) {
      state = AlbumListState(error: e);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading || !state.hasNext) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.page + 1;
      final response = await fetchPage(page: nextPage, limit: limit);
      state = state.copyWith(
        albums: [...state.albums, ...response.albums],
        page: response.pagination.page,
        hasNext: response.pagination.hasNext,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e);
    }
  }

  Future<void> refresh() => loadInitial();
}
