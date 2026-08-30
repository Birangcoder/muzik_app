import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/appRouteName.dart';
import '../../features/home/presentation/widgets/show_song_options.dart';
import 'song_list_tile.dart';

import '../../features/song/data/models/songs_model.dart';

class PaginatedSongListView extends StatefulWidget {
  final String title;
  final List<SongModel> tracks;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final Object? error;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  const PaginatedSongListView({
    super.key,
    required this.title,
    required this.tracks,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasNext,
    required this.error,
    required this.onRefresh,
    required this.onLoadMore,
  });

  @override
  State<PaginatedSongListView> createState() => _PaginatedSongListViewState();
}

class _PaginatedSongListViewState extends State<PaginatedSongListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      widget.onLoadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), scrolledUnderElevation: 0),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (widget.isLoading && widget.tracks.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: 8,
        itemBuilder: (context, index) => const _SongTileSkeleton(),
      );
    }

    if (widget.error != null && widget.tracks.isEmpty) {
      return _ErrorState(onRetry: widget.onRefresh, titile: widget.title);
    }

    if (widget.tracks.isEmpty) {
      return _EmptyState(onRefresh: widget.onRefresh);
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: widget.tracks.length + 1,
        itemBuilder: (context, index) {
          if (index == widget.tracks.length) {
            return _Footer(
              isLoadingMore: widget.isLoadingMore,
              hasNext: widget.hasNext,
            );
          }
          final song = widget.tracks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SongListTile(
              song: song,
              onTap: () => context.goNamed(
                RouteName.song,
                pathParameters: {"id": song.id.toString()},
              ),
              onMore: () {
                showSongOptions(context, song);
              },
            ),
          );
        },
      ),
    );
  }
}

/// Footer shown at the bottom of the list — spinner while loading,
/// end-of-list message when there's nothing left, nothing otherwise.
class _Footer extends StatelessWidget {
  final bool isLoadingMore;
  final bool hasNext;

  const _Footer({required this.isLoadingMore, required this.hasNext});

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        ),
      );
    }

    if (!hasNext) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            "You're all caught up",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      );
    }

    return const SizedBox(height: 16);
  }
}

/// Simple shimmer-free skeleton placeholder for a song tile.
class _SongTileSkeleton extends StatelessWidget {
  const _SongTileSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 120,
                  decoration: BoxDecoration(
                    color: base,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  final String titile;

  const _ErrorState({required this.onRetry, required this.titile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              "Couldn't load $titile songs",
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              "Check your connection and try again",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.music_off_rounded,
                      size: 48,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No trending songs right now',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
