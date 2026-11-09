import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/album_provider.dart';

/// Like / download / more / repeat buttons and the big play button.
/// Play opens the first track of the album.
class AlbumActionRow extends ConsumerWidget {
  final int albumId;
  const AlbumActionRow({super.key, required this.albumId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final tracks = ref.watch(albumTracksProvider(albumId)).tracks;
    final canPlay = tracks.isNotEmpty;

    return Row(
      children: [
        const _SquareButton(Icons.favorite_border),
        const _SquareButton(Icons.file_download_outlined),
        const _SquareButton(Icons.more_horiz),
        const Spacer(),
        const _SquareButton(Icons.repeat),
        Opacity(
          opacity: canPlay ? 1 : 0.4,
          child: GestureDetector(
            onTap: canPlay
                ? () => context.pushNamed(
                    RouteName.song,
                    pathParameters: {'id': tracks.first.id.toString()},
                  )
                : null,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.purple.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SquareButton extends StatelessWidget {
  final IconData icon;
  const _SquareButton(this.icon);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: colors.surface2,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {},
          child: SizedBox(
            width: 50,
            height: 50,
            child: Icon(icon, size: 20, color: colors.text2),
          ),
        ),
      ),
    );
  }
}
