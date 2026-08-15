import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/appRouteName.dart';
import 'show_song_options.dart';
import 'song_list_tile.dart';

import '../../../../core/utils/responsive.dart';
import '../../../song/data/models/songs_model.dart';

class SongListSection extends StatelessWidget {
  final String title;
  final List<SongModel> songs;
  final VoidCallback? onSeeAll;
  final VoidCallback? onPlayAll;
  final int songsPerColumn;

  const SongListSection({
    super.key,
    required this.title,
    required this.songs,
    required this.songsPerColumn,
    this.onSeeAll,
    this.onPlayAll,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = Responsive.horizontalPadding(context);

    // Split songs into groups
    final columns = <List<SongModel>>[];

    for (int i = 0; i < songs.length; i += songsPerColumn) {
      columns.add(
        songs.sublist(
          i,
          (i + songsPerColumn > songs.length)
              ? songs.length
              : i + songsPerColumn,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              if (onPlayAll != null)
                OutlinedButton.icon(
                  onPressed: onPlayAll,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                  label: const Text('Play All', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: 4 * 80 + 3 * 18,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: hPad),
            itemCount: columns.length,
            separatorBuilder: (_, _) => const SizedBox(width: 32),
            itemBuilder: (context, columnIndex) {
              final column = columns[columnIndex];

              return SizedBox(
                width: 320,
                child: Column(
                  children: [
                    for (int i = 0; i < column.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: i == column.length - 1 ? 0 : 18,
                        ),
                        child: SizedBox(
                          height: 80,
                          child: SongListTile(
                            song: column[i],
                            onTap: () => context.goNamed(
                              RouteName.song,
                              pathParameters: {"id": column[i].id.toString()},
                            ),
                            onMore: () {
                              showSongOptions(context, column[i]);
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
