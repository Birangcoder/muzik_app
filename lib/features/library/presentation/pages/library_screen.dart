import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _filter = 'All';
  static const _items = [
    ('Liked songs', '125 songs', Icons.favorite_rounded, Color(0xFFE94F9B)),
    (
      'Recently played',
      'Your listening history',
      Icons.history_rounded,
      Color(0xFF7045E8),
    ),
    (
      'Downloads',
      'Available offline',
      Icons.download_rounded,
      Color(0xFF0D9488),
    ),
    (
      'My playlist',
      'A collection made for you',
      Icons.queue_music_rounded,
      Color(0xFF2563EB),
    ),
    ('Chill vibes', '18 songs', Icons.nights_stay_rounded, Color(0xFF8B5CF6)),
  ];
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final visible = _filter == 'All'
        ? _items
        : _items
              .where(
                (e) => _filter == 'Playlists'
                    ? e.$1.toLowerCase().contains('playlist') ||
                          e.$1 == 'Chill vibes'
                    : e.$1 == 'Liked songs' || e.$1 == 'Downloads',
              )
              .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Your library',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              tooltip: 'Sort library',
              icon: const Icon(Icons.tune_rounded),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          children: ['All', 'Playlists', 'Downloaded']
              .map(
                (v) => ChoiceChip(
                  label: Text(v),
                  selected: _filter == v,
                  onSelected: (_) => setState(() => _filter = v),
                  selectedColor: c.purple,
                  labelStyle: TextStyle(
                    color: _filter == v ? Colors.white : c.text2,
                  ),
                  side: BorderSide(color: _filter == v ? c.purple : c.stroke),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 14),
        ...visible.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: c.surface,
              borderRadius: BorderRadius.circular(15),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.$4,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.$3, color: Colors.white),
                ),
                title: Text(
                  item.$1,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  item.$2,
                  style: TextStyle(color: c.text3, fontSize: 12),
                ),
                trailing: Icon(Icons.more_vert_rounded, color: c.text3),
                onTap: () {},
              ),
            ),
          ),
        ),
        if (visible.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(36),
              child: Text('Nothing here yet', style: TextStyle(color: c.text2)),
            ),
          ),
      ],
    );
  }
}
