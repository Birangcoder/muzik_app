import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/PaginatedSongListView.dart';
import '../../data/repository/trending_repository.dart';

class TrendingPage extends ConsumerWidget {
  const TrendingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trendingProvider);

    return PaginatedSongListView(
      title: 'Trending',
      tracks: state.tracks,
      isLoading: state.isLoading,
      isLoadingMore: state.isLoadingMore,
      hasNext: state.hasNext,
      error: state.error,
      onRefresh: () => ref.read(trendingProvider.notifier).refresh(),
      onLoadMore: () => ref.read(trendingProvider.notifier).loadMore(),
    );
  }
}
