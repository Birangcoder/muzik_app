import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget option(IconData icon, String title, {String? subtitle, VoidCallback? onTap}) =>
      ListTile(
        leading: Icon(icon, color: c.text2, size: 21),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: subtitle == null ? null : Text(subtitle, style: TextStyle(color: c.text3, fontSize: 11)),
        trailing: Icon(Icons.chevron_right_rounded, color: c.text3),
        onTap: onTap ?? () {},
        dense: true,
      );
    return ListView(padding: const EdgeInsets.fromLTRB(18, 18, 18, 28), children: [
      Row(children: [
        Expanded(child: Text('Profile', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800))),
        IconButton(onPressed: () {}, tooltip: 'More options', icon: const Icon(Icons.more_horiz_rounded)),
      ]),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(
        color: c.surface, borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          Container(width: 58, height: 58, decoration: BoxDecoration(
            shape: BoxShape.circle, gradient: LinearGradient(colors: [c.purple, c.blue])),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 30)),
          const SizedBox(width: 14),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Music lover', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            SizedBox(height: 4), Text('Manage your account', style: TextStyle(fontSize: 12)),
          ])),
          Icon(Icons.edit_outlined, color: c.text2),
        ]),
      ),
      const SizedBox(height: 14),
      Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(
        color: c.surface, borderRadius: BorderRadius.circular(16)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: const [
          _Stat(value: '12', label: 'Playlists'), _Stat(value: '128', label: 'Liked'), _Stat(value: '36', label: 'Artists'),
        ]),
      ),
      const SizedBox(height: 20),
      Text('ACCOUNT', style: TextStyle(color: c.text3, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
      const SizedBox(height: 8),
      Container(decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          option(Icons.person_outline_rounded, 'Edit profile'),
          Divider(height: 1, color: c.stroke),
          option(Icons.notifications_none_rounded, 'Notifications'),
          Divider(height: 1, color: c.stroke),
          option(Icons.lock_outline_rounded, 'Privacy & security'),
        ])),
      const SizedBox(height: 18),
      Text('PREFERENCES', style: TextStyle(color: c.text3, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
      const SizedBox(height: 8),
      Container(decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          option(Icons.palette_outlined, 'Appearance', subtitle: 'Dark theme'),
          Divider(height: 1, color: c.stroke),
          option(Icons.language_rounded, 'Language'),
          Divider(height: 1, color: c.stroke),
          option(Icons.help_outline_rounded, 'Help & support'),
        ])),
      const SizedBox(height: 16),
      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.logout_rounded), label: const Text('Log out'),
        style: OutlinedButton.styleFrom(foregroundColor: c.error, side: BorderSide(color: c.stroke),
          padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
      const SizedBox(height: 16),
      Center(child: Text('muzik • Version 1.0.0', style: TextStyle(color: c.text3, fontSize: 11))),
    ]);
  }
}
class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
    const SizedBox(height: 3), Text(label, style: TextStyle(fontSize: 11, color: context.colors.text3)),
  ]);
}
