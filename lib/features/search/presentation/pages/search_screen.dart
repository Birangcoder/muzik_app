import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}
class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  String _selected = 'All';
  static const _genres = [
    ('Pop', Icons.auto_awesome_rounded, Color(0xFF7045E8)),
    ('Punjabi', Icons.music_note_rounded, Color(0xFF2563EB)),
    ('Bollywood', Icons.movie_rounded, Color(0xFF0D9488)),
    ('Romance', Icons.favorite_rounded, Color(0xFFDB3D9B)),
    ('Hip-hop', Icons.graphic_eq_rounded, Color(0xFF2563EB)),
    ('Indie', Icons.headphones_rounded, Color(0xFF0D9488)),
    ('Devotional', Icons.spa_rounded, Color(0xFF8B5CF6)),
    ('Workout', Icons.fitness_center_rounded, Color(0xFFE87935)),
  ];
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final filtered = _genres.where((g) => (_selected == 'All' || g.$1 == _selected) &&
      (_query.isEmpty || g.$1.toLowerCase().contains(_query.toLowerCase()))).toList();
    return ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 28), children: [
      Text('Search', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 18),
      TextField(
        controller: _controller,
        onChanged: (v) => setState(() => _query = v),
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Songs, artists, albums...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _query.isEmpty ? null : IconButton(
            tooltip: 'Clear search', onPressed: () { _controller.clear(); setState(() => _query = ''); },
            icon: const Icon(Icons.close_rounded)),
          filled: true, fillColor: c.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c.purple)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c.purple, width: 1.5)),
        ),
      ),
      const SizedBox(height: 22),
      Text('Browse categories', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: ['All', ..._genres.map((e) => e.$1)].map((label) =>
        ChoiceChip(label: Text(label), selected: _selected == label,
          onSelected: (_) => setState(() => _selected = label),
          selectedColor: c.purple, backgroundColor: c.surface,
          labelStyle: TextStyle(color: _selected == label ? Colors.white : c.text2, fontWeight: FontWeight.w600),
          side: BorderSide(color: _selected == label ? c.purple : c.stroke))).toList()),
      const SizedBox(height: 18),
      if (filtered.isEmpty)
        Padding(padding: const EdgeInsets.only(top: 40), child: Center(child: Column(children: [
          Icon(Icons.search_off_rounded, size: 42, color: c.text3),
          const SizedBox(height: 10), Text('No categories found', style: TextStyle(color: c.text2)),
        ])))
      else GridView.builder(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        itemCount: filtered.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.75),
        itemBuilder: (context, i) {
          final item = filtered[i];
          return Material(
            color: item.$3, borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () { setState(() { _selected = item.$1; _query = ''; _controller.clear(); }); },
              child: Stack(children: [
                Positioned(right: -10, bottom: -18, child: Icon(item.$2, size: 88, color: Colors.white.withValues(alpha: .16))),
                Padding(padding: const EdgeInsets.all(15), child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(item.$1, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                )),
              ]),
            ),
          );
        },
      ),
    ]);
  }
}
