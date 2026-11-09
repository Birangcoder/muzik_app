import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muzik/core/router/route_names.dart';
import '../../../../core/error/error_message.dart';

import '../../../../shared/widgets/square_card.dart';
import '../../data/models/album_model.dart';
import '../providers/album_provider.dart';

class AlbumsList extends ConsumerWidget {
  const AlbumsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(albumListProvider);
    final provider = albumListProvider;

    return PaginatedAlbumGridView(
      title: 'Albums',
      albums: state.albums,
      isLoading: state.isLoading,
      isLoadingMore: state.isLoadingMore,
      hasNext: state.hasNext,
      error: state.error,
      onRefresh: () => ref.read(provider.notifier).refresh(),
      onLoadMore: () => ref.read(provider.notifier).loadMore(),
    );
  }
}

class PaginatedAlbumGridView extends StatefulWidget {
  final String title;
  final List<AlbumModel> albums;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasNext;
  final Object? error;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  const PaginatedAlbumGridView({
    super.key,
    required this.title,
    required this.albums,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasNext,
    required this.error,
    required this.onRefresh,
    required this.onLoadMore,
  });

  @override
  State<PaginatedAlbumGridView> createState() => _PaginatedAlbumGridViewState();
}

class _PaginatedAlbumGridViewState extends State<PaginatedAlbumGridView> {
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
    if (widget.isLoading && widget.albums.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 16,
          childAspectRatio: 0.68,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const _AlbumCardSkeleton(),
      );
    }

    if (widget.error != null && widget.albums.isEmpty) {
      return _ErrorState(
        onRetry: widget.onRefresh,
        titile: widget.title,
        message: friendlyError(widget.error),
      );
    }

    if (widget.albums.isEmpty) {
      return _EmptyState(onRefresh: widget.onRefresh, title: widget.title);
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 5,
          crossAxisSpacing: 16,
          childAspectRatio: 0.68,
        ),
        itemCount: widget.albums.length + (widget.hasNext ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= widget.albums.length) {
            return _Footer(
              isLoadingMore: widget.isLoadingMore,
              hasNext: widget.hasNext,
            );
          }

          final album = widget.albums[index];
          final artistNames =
              album.artists?.map((a) => a.name).join(', ') ?? '';

          return SquareCard(
            title: album.title,
            artist: artistNames,
            coverImg: album.coverUrl,
            onTap: () => context.goNamed(
              RouteName.album,
              pathParameters: {'id': album.id.toString()},
            ),
          );
        },
      ),
    );
  }
}

/// Footer shown at the end of the grid — spinner while loading more,
/// end-of-list message when there's nothing left, nothing otherwise.
/// Spans both grid columns so it doesn't look like a half-empty tile.
class _Footer extends StatelessWidget {
  final bool isLoadingMore;
  final bool hasNext;

  const _Footer({required this.isLoadingMore, required this.hasNext});

  @override
  Widget build(BuildContext context) {
    if (isLoadingMore) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.2),
        ),
      );
    }

    if (!hasNext) {
      return Center(
        child: Text(
          "That's all",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

/// Simple skeleton placeholder for an album grid tile.
class _AlbumCardSkeleton extends StatelessWidget {
  const _AlbumCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: base,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 14,
          width: double.infinity,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 12,
          width: 100,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  final String titile;
  final String message;

  const _ErrorState({
    required this.onRetry,
    required this.titile,
    required this.message,
  });

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
              "Couldn't load $titile",
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              message,
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
  final String title;

  const _EmptyState({required this.onRefresh, required this.title});

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
                      'No $title right now',
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
