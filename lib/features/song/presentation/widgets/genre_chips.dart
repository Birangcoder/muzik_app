import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/reference_models.dart';

class GenreChips extends StatelessWidget {
  final List<GenresRef> genres;

  const GenreChips({super.key, required this.genres});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: genres
          .map(
            (g) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.surface2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.stroke),
              ),
              child: Text(
                g.title,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: colors.text2),
              ),
            ),
          )
          .toList(),
    );
  }
}
