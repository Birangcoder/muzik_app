// lib/features/song/presentation/widgets/cover_art.dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CoverArt extends StatelessWidget {
  final String url;
  const CoverArt({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maxSide = MediaQuery.of(context).size.width.clamp(0, 480);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxSide.toDouble()),
        child: AspectRatio(
          aspectRatio: 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.stroke),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isLight ? 0.12 : 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return ColoredBox(
                    color: colors.surface2,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.text3,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => ColoredBox(
                  color: colors.surface2,
                  child: Icon(Icons.music_note_rounded,
                      size: 60, color: colors.text3),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}