import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class StatsRow extends StatelessWidget {
  final int? playCount;
  final DateTime releaseDate;

  const StatsRow({
    super.key,
    required this.playCount,
    required this.releaseDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (playCount != null) ...[
          _StatChip(
            icon: Icons.headphones_rounded,
            label: '${_formatCount(playCount)} plays',
          ),
          const SizedBox(width: 20),
        ],
        _StatChip(
          icon: Icons.calendar_today_rounded,
          label: _formatReleaseDate(releaseDate),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colors.text3),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: colors.text3),
        ),
      ],
    );
  }
}

String _formatCount(int? n) {
  if (n == null) return '—';
  final s = n.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return buf.toString();
}

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _formatReleaseDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';
