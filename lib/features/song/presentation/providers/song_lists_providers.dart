import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/songs_model.dart';
import '../../data/models/track_state.dart';
import '../../data/repository/song_repository.dart';
import 'song_provider.dart'; // wherever songApiServiceProvider / repository providers live
import 'track_notifier.dart';

// ---------- Trending ----------
class TrendingNotifier extends TrackNotifier {
  late final SongRepository _repository = ref.read(songApiServiceProvider);

  @override
  Future<SongPageModel> fetchPage({required int page, required int limit}) {
    return _repository.fetchTrendingSong(page: page, limit: limit);
  }
}

final trendingProvider = NotifierProvider<TrendingNotifier, TrackState>(
  TrendingNotifier.new,
);

// ---------- Favorites ----------
class FavoriteNotifier extends TrackNotifier {
  late final SongRepository _repository = ref.read(songApiServiceProvider);

  @override
  Future<SongPageModel> fetchPage({required int page, required int limit}) {
    return _repository.fetchFavoriteSong(page: page, limit: limit);
  }
}

final favoriteProvider = NotifierProvider<FavoriteNotifier, TrackState>(
  FavoriteNotifier.new,
);

// ---------- Continue Listening ----------
class HistoryNotifier extends TrackNotifier {
  late final SongRepository _repository = ref.read(songApiServiceProvider);

  @override
  Future<SongPageModel> fetchPage({required int page, required int limit}) {
    return _repository.fetchHistory(page: page, limit: limit);
  }
}

final historyProvider = NotifierProvider<HistoryNotifier, TrackState>(
  HistoryNotifier.new,
);

// ---------- Recommended ----------
class RecommendedNotifier extends TrackNotifier {
  late final SongRepository _repository = ref.read(songApiServiceProvider);

  @override
  Future<SongPageModel> fetchPage({required int page, required int limit}) {
    return _repository.fetchRecommendedSong(page: page, limit: limit);
  }
}

final recommendedProvider = NotifierProvider<RecommendedNotifier, TrackState>(
  RecommendedNotifier.new,
);

// ---------- New Release ----------
class NewReleaseNotifier extends TrackNotifier {
  late final SongRepository _repository = ref.read(songApiServiceProvider);

  @override
  Future<SongPageModel> fetchPage({required int page, required int limit}) {
    return _repository.fetchLatestSong(page: page, limit: limit);
  }
}

final newReleaseProvider = NotifierProvider<NewReleaseNotifier, TrackState>(
  NewReleaseNotifier.new,
);
