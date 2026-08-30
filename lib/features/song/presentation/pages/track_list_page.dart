import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/PaginatedSongListView.dart';
// import '../../data/repository/trending_repository.dart';

class TrackListPage extends ConsumerWidget {
  final provider;
  final title;
  const TrackListPage({super.key, required this.provider, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(provider);

    return PaginatedSongListView(
      title: title,
      tracks: state.tracks,
      isLoading: state.isLoading,
      isLoadingMore: state.isLoadingMore,
      hasNext: state.hasNext,
      error: state.error,
      onRefresh: () => ref.read(provider.notifier).refresh(),
      onLoadMore: () => ref.read(provider.notifier).loadMore(),
    );
  }
}
