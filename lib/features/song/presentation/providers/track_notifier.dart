import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/songs_model.dart';
import '../../data/models/track_state.dart';

abstract class TrackNotifier extends Notifier<TrackState> {
  static const int limit = 20;

  /// The only thing each concrete list needs to implement — the actual
  /// network call for one page. Everything else (loading flags, pagination
  /// bookkeeping, appending, error handling) is shared here.
  Future<SongPageModel> fetchPage({required int page, required int limit});

  @override
  TrackState build() {
    Future.microtask(loadInitial);
    return const TrackState(isLoading: true);
  }

  Future<void> loadInitial() async {
    try {
      state = const TrackState(isLoading: true);
      final response = await fetchPage(page: 1, limit: limit);
      state = TrackState(
        tracks: response.tracks,
        page: response.pagination.page,
        hasNext: response.pagination.hasNext,
      );
    } catch (e) {
      state = TrackState(error: e);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading || !state.hasNext) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.page + 1;
      final response = await fetchPage(page: nextPage, limit: limit);
      state = state.copyWith(
        tracks: [...state.tracks, ...response.tracks],
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