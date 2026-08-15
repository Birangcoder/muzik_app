import 'package:flutter/material.dart';
import 'song_option_sheet.dart';

import '../../../song/data/models/songs_model.dart';

void showSongOptions(BuildContext context, SongModel song) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) {
      return SongOptionsSheet(song: song);
    },
  );
}
