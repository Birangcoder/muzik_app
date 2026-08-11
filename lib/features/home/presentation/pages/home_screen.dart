import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/appRouteName.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../shared/models/album_model.dart';
import '../../../../shared/models/artists_model.dart';
import '../../../../shared/models/songs_model.dart';
import '../../../auth/presentation/provider/current_user_provider.dart';
import '../../data/mock_home_data.dart';
import '../providers/home_provider.dart';
import '../widgets/genre_tile.dart';
import '../widgets/home_section.dart';
import '../widgets/square_card.dart';
import '../widgets/round_card.dart';
import '../widgets/searchBar.dart';
import '../widgets/trending_card.dart';

String _greetingForHour(int hour) {
  if (hour < 12) return "good morning";
  if (hour < 18) return "good afternoon";
  return "good evening";
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
          constraints: BoxConstraints(maxWidth: Responsive.contentMaxWidth),
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
                              color: textTheme.bodyMedium?.color?.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                          Text(
                            user?.name ?? "Guest",
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
                loading: () => const CircularProgressIndicator(),

                error: (error, stack) {
                  return Text(error.toString());
                },

                data: (home) {
                  return Column(
                    children: [
                      HomeSection<SongModel>(
                        title: "trending",
                        height: Responsive.trendingRailHeight(context),
                        items: home.trending,
                        itemBuilder: (context, track, i) => TrendingCard(
                          rank: i + 1,
                          title: track.title,
                          artist: track.artists
                              .map((artist) => artist.name)
                              .join(', '),
                          gradient: gradients[i % gradients.length],
                        ),
                      ),

                      HomeSection<SongModel>(
                        title: "new releases",
                        height: Responsive.mediaRailHeight(context),
                        items: home.newReleases,
                        itemBuilder: (context, song, i) => SquareCard(
                          title: song.title,
                          artist: song.artists
                              .map((artist) => artist.name)
                              .join(', '),
                          coverImg: song.media.coverUrl,
                        ),
                      ),

                      HomeSection<ArtistsModel>(
                        title: "popular artists",
                        height: Responsive.mediaRailHeight(context),
                        items: home.artists,
                        itemBuilder: (context, artist, i) => RoundCard(
                          name: artist.name,
                          coverImg: artist.imageUrl!,
                        ),
                      ),

                      HomeSection<SongModel>(
                        title: "popular songs",
                        height: Responsive.mediaRailHeight(context),
                        items: home.popular,
                        itemBuilder: (context, song, i) => SquareCard(
                          title: song.title,
                          artist: song.artists
                              .map((artist) => artist.name)
                              .join(', '),
                          coverImg: song.media.coverUrl,
                        ),
                      ),

                      //1281 ms
                      HomeSection<AlbumModel>(
                        title: "popular album",
                        height: Responsive.mediaRailHeight(context),
                        items: home.albums,
                        itemBuilder: (context, album, i) => SquareCard(
                          title: album.title,
                          artist:
                              album.artist
                                  ?.map((artist) => artist.name)
                                  .join(', ') ??
                              '',
                          coverImg: album.coverUrl,
                        ),
                      ),

                      HomeSection<SongModel>(
                        title: "recommended for you",
                        height: Responsive.mediaRailHeight(context),
                        items: home.recommended,
                        itemBuilder: (context, song, i) {
                          if (home.recommended.isNotEmpty) {
                            return SquareCard(
                              title: song.title,
                              artist: song.artists
                                  .map((artist) => artist.name)
                                  .join(', '),
                              coverImg: song.media.coverUrl,
                            );
                          } else {
                            return Column(
                              children: [
                                Text('Start listening to discover'),
                                Text('music picked for you.'),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  );
                },
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(hPad, 32, hPad, 12),
                child: Text("genres", style: textTheme.titleLarge),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Responsive.gridColumns(context),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.4,
                  ),
                  itemCount: genres.length,
                  itemBuilder: (context, i) => GenreTile(
                    label: genres[i],
                    gradient: gradients[i % gradients.length],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
