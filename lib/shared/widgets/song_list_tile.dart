import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/helper/imageSize.dart';
import '../../features/song/data/models/songs_model.dart';

class SongListTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  // Optional overrides — every screen gets the same look by default,
  // but any screen can opt out of specific pieces.
  final bool showMoreButton;
  final bool dense; // smaller variant, e.g. for a horizontal "recently played" row
  final Widget? trailing; // replace the more-button with something else (e.g. a play count, a checkmark for multi-select)

  const SongListTile({
    super.key,
    required this.song,
    this.onTap,
    this.onMore,
    this.showMoreButton = true,
    this.dense = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final size = dense ? 56.0 : 80.0;
    final titleSize = dense ? 15.0 : 18.0;
    final subtitleSize = dense ? 13.0 : 15.0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: size,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: CloudinaryImage.resize(song.media.coverUrl, width: (size * 2)),
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    song.artists.map((a) => a.name).join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: subtitleSize, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (showMoreButton)
              IconButton(onPressed: onMore, icon: const Icon(Icons.more_vert)),
          ],
        ),
      ),
    );
  }
}