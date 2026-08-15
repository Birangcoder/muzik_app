import 'package:flutter/material.dart';

import '../../../song/data/models/songs_model.dart';

class SongOptionsSheet extends StatelessWidget {
  const SongOptionsSheet({super.key, required this.song});

  final SongModel song;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Play now'),
              onTap: () {
                Navigator.pop(context);
                // play song
              },
            ),

            ListTile(
              leading: const Icon(Icons.queue_music),
              title: const Text('Add to queue'),
              onTap: () {
                Navigator.pop(context);
                // add to queue
              },
            ),

            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text('Add to favourites'),
              onTap: () {
                Navigator.pop(context);
                // add favourite
              },
            ),

            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Add to playlist'),
              onTap: () {
                Navigator.pop(context);
                // show playlist selection
              },
            ),

            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Download'),
              onTap: () {
                Navigator.pop(context);
                // download
              },
            ),

            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Go to artist'),
              onTap: () {
                Navigator.pop(context);
                // navigate to artist
              },
            ),

            ListTile(
              leading: const Icon(Icons.album_outlined),
              title: const Text('Go to album'),
              onTap: () {
                Navigator.pop(context);
                // navigate to album
              },
            ),

            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // share song
              },
            ),
          ],
        ),
      ),
    );
  }
}
