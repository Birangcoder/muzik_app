import 'album_model.dart';

class AlbumListState {
  final List<AlbumModel> albums;
  final int page;
  final bool hasNext;
  final bool isLoading;
  final bool isLoadingMore;
  final Object? error;

  const AlbumListState({
    this.albums = const [],
    this.page = 0,
    this.hasNext = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  AlbumListState copyWith({
    List<AlbumModel>? albums,
    int? page,
    bool? hasNext,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error,
  }) {
    return AlbumListState(
      albums: albums ?? this.albums,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
    );
  }
}
