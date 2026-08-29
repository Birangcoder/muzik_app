import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muzik/features/song/data/repository/song_repository.dart';

import '../../presentation/providers/song_provider.dart';
import '../models/songs_model.dart';

class TrendingState {
  final List<SongModel> tracks;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final int page;
  final Object? error;

  const TrendingState({
    this.tracks = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasNext = true,
    this.page = 0,
    this.error,
  });

  TrendingState copyWith({
    List<SongModel>? tracks,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasNext,
    int? page,
    Object? error,
  }) {
    return TrendingState(
      tracks: tracks ?? this.tracks,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasNext: hasNext ?? this.hasNext,
      page: page ?? this.page,
      error: error,
    );
  }
}

final trendingProvider = NotifierProvider<TrendingNotifier, TrendingState>(
  TrendingNotifier.new,
);

class TrendingNotifier extends Notifier<TrendingState> {
  static const int _limit = 20;
  late final SongRepository _repository;

  @override
  TrendingState build() {
    _repository = ref.read(songApiServiceProvider);
    Future.microtask(loadInitial);
    return const TrendingState(isLoading: true);
  }

  Future<void> loadInitial() async {
    try {
      state = const TrendingState(isLoading: true);
      final response = await _repository.fetchTrendingSong(
        page: 1,
        limit: _limit,
      );
      state = TrendingState(
        tracks: response.tracks,
        page: response.pagination.page,
        hasNext: response.pagination.hasNext,
      );
    } catch (e) {
      state = TrendingState(error: e);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading || !state.hasNext) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.page + 1;
      final response = await _repository.fetchTrendingSong(
        page: nextPage,
        limit: _limit,
      );
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

  Future<void> refresh() async {
    await loadInitial();
  }
}
