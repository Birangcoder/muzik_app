import 'songs_model.dart';

class TrackState {
  final List<SongModel> tracks;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final int page;
  final Object? error;

  const TrackState({
    this.tracks = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasNext = true,
    this.page = 0,
    this.error,
  });

  TrackState copyWith({
    List<SongModel>? tracks,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasNext,
    int? page,
    Object? error,
  }) {
    return TrackState(
      tracks: tracks ?? this.tracks,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasNext: hasNext ?? this.hasNext,
      page: page ?? this.page,
      error: error,
    );
  }
}