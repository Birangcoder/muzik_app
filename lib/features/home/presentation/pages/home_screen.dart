import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/error_message.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/models/album_model_ref.dart';
import '../../../../shared/models/artist_model_ref.dart';
import '../../../../shared/widgets/round_card.dart';
import '../../../../shared/widgets/square_card.dart';
import '../../../auth/presentation/providers/current_user_provider.dart';
import '../../../song/data/models/song_model.dart';
import '../../../song/presentation/providers/song_lists_providers.dart';
import '../providers/home_provider.dart';
import '../widgets/home_section.dart';
import '../widgets/search_bar.dart';
import '../widgets/song_list_section.dart';
import '../widgets/trending_card.dart';

String _greetingForHour(int hour) {
  if (hour < 12) return 'good morning';
  if (hour < 18) return 'good afternoon';
  return 'good evening';
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final homeAsync = ref.watch(homeProvider);
    final gradients = AppGradients.fallbackTiles;
    final hPad = Responsive.horizontalPadding(context);
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Responsive.contentMaxWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0), // was 20
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greetingForHour(DateTime.now().hour),
                            style: textTheme.labelLarge?.copyWith(
                              color: textTheme.bodyMedium?.color?.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          Text(
                            user?.name ?? 'Guest',
                            style: textTheme.displayMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: gradients.first,
                      ),
                      child: IconButton(
                        onPressed: () {
                          context.goNamed(RouteName.profile);
                        },
                        icon: const Icon(Icons.person),
                        color: Colors.white,
                        iconSize: 20,
                      ),
                    ),
                  ],
                ),
              ),

              AppSearchBar(padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16)),

              homeAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),

                error: (error, stack) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off_outlined, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            "Couldn't load your music",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            friendlyError(error),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => ref.invalidate(homeProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                },

                data: (home) {
                  return Column(
                    children: [
                      HomeSection<SongModel>(
                        title: 'trending',
                        height: Responsive.trendingRailHeight(context),
                        items: home.trending,
                        onSeeAll: () => context.pushNamed(
                          RouteName.trackList,
                          extra: {
                            'provider': trendingProvider,
                            'title': 'Trending',
                          },
                        ),
                        itemBuilder: (context, track, i) => TrendingCard(
                          rank: i + 1,
                          title: track.title,
                          artist: track.artistNames,
                          gradient: gradients[i % gradients.length],
                          onTap: () => context.goNamed(
                            RouteName.song,
                            pathParameters: {'id': track.id.toString()},
                          ),
                        ),
                      ),

                      HomeSection<SongModel>(
                        title: 'new releases',
                        height: Responsive.mediaRailHeight(context),
                        items: home.newReleases,
                        onSeeAll: () => context.pushNamed(
                          RouteName.trackList,
                          extra: {
                            'provider': newReleaseProvider,
                            'title': 'New Release',
                          },
                        ),
                        itemBuilder: (context, song, i) => SquareCard(
                          title: song.title,
                          artist: song.artistNames,
                          coverImg: song.media.coverUrl,
                          onTap: () => context.goNamed(
                            RouteName.song,
                            pathParameters: {'id': song.id.toString()},
                          ),
                          width: Responsive.mediaCardSize(context),
                        ),
                      ),

                      HomeSection<ArtistsModelRef>(
                        title: 'popular artists',
                        height: Responsive.mediaRailHeight(context),
                        items: home.artists,
                        onSeeAll: () {},
                        itemBuilder: (context, artist, i) => RoundCard(
                          name: artist.name,
                          coverImg: artist.imageUrl ?? '',
                        ),
                      ),

                      SongListSection(
                        title: 'popular songs',
                        songs: home.popular,
                        onPlayAll: () {
                          // play all trending songs
                        },
                        songsPerColumn: 4,
                      ),

                      HomeSection<AlbumModelRef>(
                        title: 'popular album',
                        height: Responsive.mediaRailHeight(context),
                        items: home.albums,
                        onSeeAll: () => context.pushNamed(RouteName.albumList),
                        itemBuilder: (context, album, i) => SquareCard(
                          title: album.title,
                          artist:
                              album.artist?.map((a) => a.name).join(', ') ?? '',
                          coverImg: album.coverUrl,
                          width: Responsive.mediaCardSize(context),
                          onTap: () => context.pushNamed(
                            RouteName.album,
                            pathParameters: {'id': album.id.toString()},
                          ),
                        ),
                      ),

                      HomeSection<SongModel>(
                        title: 'recommended for you',
                        height: Responsive.mediaRailHeight(context),
                        items: home.recommended,
                        onSeeAll: () => context.pushNamed(
                          RouteName.trackList,
                          extra: {
                            'provider': recommendedProvider,
                            'title': 'Recommended',
                          },
                        ),
                        emptyWidget: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start listening to discover'),
                            Text('music picked for you.'),
                          ],
                        ),
                        itemBuilder: (context, song, i) {
                          return SquareCard(
                            title: song.title,
                            artist: song.artistNames,
                            coverImg: song.media.coverUrl,
                            onTap: () => context.goNamed(
                              RouteName.song,
                              pathParameters: {'id': song.id.toString()},
                            ),
                            width: Responsive.mediaCardSize(context),
                          );
                        },
                      ),

                      HomeSection<SongModel>(
                        title: 'continue listening',
                        height: Responsive.mediaRailHeight(context),
                        items: home.continueListening,
                        onSeeAll: () => context.pushNamed(
                          RouteName.trackList,
                          extra: {
                            'provider': historyProvider,
                            'title': 'History',
                          },
                        ),
                        emptyWidget: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text('Start listening ')],
                        ),
                        itemBuilder: (context, song, i) {
                          return SquareCard(
                            title: song.title,
                            artist: song.artistNames,
                            coverImg: song.media.coverUrl,
                            onTap: () => context.goNamed(
                              RouteName.song,
                              pathParameters: {'id': song.id.toString()},
                            ),
                            width: Responsive.mediaCardSize(context),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
