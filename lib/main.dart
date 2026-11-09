import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/routes.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_error_view.dart';
import 'features/player/presentation/providers/audio_player_provider.dart';
import 'features/player/presentation/widgets/floating_mini_player.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Framework errors (build/layout/paint): log, never crash the app.
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  // Uncaught async errors: log and swallow instead of killing the app.
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
    return true;
  };

  // A widget that throws while building shows a small message, not a
  // red/grey error screen with technical text.
  ErrorWidget.builder = (details) => const AppErrorWidget();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  runApp(
    ProviderScope(retry: (retryCount, error) => null, child: const MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Show playback problems as a friendly SnackBar on any screen.
    ref.listen<String?>(playbackErrorProvider, (_, message) {
      if (message == null) return;
      scaffoldMessengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      ref.read(playbackErrorProvider.notifier).state = null;
    });

    return MaterialApp.router(
      title: 'muzik',
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) =>
                  Stack(children: [?child, const FloatingMiniPlayer()]),
            ),
          ],
        );
      },
    );
  }
}
