import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../providers/audio_player_provider.dart';
import '../../../../providers/player_ui_provider.dart';
import '../providers/song_provider.dart';
import '../widgets/now_playing_body.dart';
import '../widgets/song_page_states.dart';

class SongPage extends ConsumerStatefulWidget {
  final int songId;

  const SongPage({super.key, required this.songId});

  @override
  ConsumerState<SongPage> createState() => _SongPageState();
}

class _SongPageState extends ConsumerState<SongPage> {
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(isPlayerMinimizedProvider.notifier).state = false;
    });
  }

  void _popOrGoHome() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  Future<void> _handleExit() async {
    if (_isExiting) return;
    _isExiting = true;
    await ref.read(audioControllerProvider.notifier).stopAndReportProgress();
    if (mounted) _popOrGoHome();
  }

  void _handleMinimize() {
    if (_isExiting) return;
    _isExiting = true;
    ref.read(isPlayerMinimizedProvider.notifier).state = true;
    if (mounted) _popOrGoHome();
  }

  @override
  void dispose() {
    if (!_isExiting) {
      ref.read(audioControllerProvider.notifier).stopAndReportProgress();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songAsync = ref.watch(songProvider(widget.songId));
    final colors = context.colors;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleExit();
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: colors.text),
            tooltip: 'Stop and close',
            onPressed: _handleExit,
          ),
          title: Text(
            'NOW PLAYING',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colors.text2,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                Icons.picture_in_picture_alt_rounded,
                color: colors.text,
              ),
              tooltip: 'Minimize',
              onPressed: _handleMinimize,
            ),
          ],
        ),
        body: songAsync.when(
          loading: () => const SongPageLoading(),
          error: (err, _) => SongPageError(message: '$err'),
          data: (song) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(audioControllerProvider.notifier).loadAndPlay(song);
            });
            return NowPlayingBody(song: song);
          },
        ),
      ),
    );
  }
}
