import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_gradients.dart';
import '../../../../core/utils/responsive.dart';
import '../../../auth/presentation/provider/current_user_provider.dart';
import '../../data/model/album_model.dart';
import '../../data/model/artist_model.dart';
import '../../data/mock_home_data.dart';
import '../../data/model/track_model.dart';
import '../widgets/genre_tile.dart';
import '../widgets/home_section.dart';
import '../widgets/new_release_card.dart';
import '../widgets/popular_artist_card.dart';
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
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              AppSearchBar(padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16)),

              HomeSection<TrackModel>(
                title: "trending",
                height: Responsive.trendingRailHeight(context),
                items: trendingTracks,
                itemBuilder: (context, track, i) => TrendingCard(
                  rank: i + 1,
                  title: track.name,
                  artist: track.artistName,
                  gradient: gradients[i % gradients.length],
                ),
              ),

              HomeSection<AlbumModel>(
                title: "new releases",
                height: Responsive.mediaRailHeight(context),
                items: newReleases,
                itemBuilder: (context, album, i) => NewReleaseCard(
                  title: album.name,
                  artist: album.artistName,
                  gradient: gradients[i % gradients.length],
                ),
              ),

              HomeSection<ArtistModel>(
                title: "popular artists",
                height: Responsive.mediaRailHeight(context),
                items: artists,
                itemBuilder: (context, artist, i) => PopularArtistCard(
                  name: artist.name,
                  trackCount: artist.trackCount,
                  gradient: gradients[i % gradients.length],
                ),
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
