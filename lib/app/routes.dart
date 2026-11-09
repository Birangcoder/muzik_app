import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/router/go_router_refresh_notifier.dart';
import '../core/router/route_names.dart';
import '../core/widgets/app_error_view.dart';
import '../features/albums/presentation/pages/album_details.dart';
import '../features/albums/presentation/pages/albums_list.dart';
import '../features/auth/data/models/auth_state.dart';
import '../features/auth/presentation/pages/login_screen.dart';
import '../features/auth/presentation/pages/register_screen.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/home/presentation/pages/home_screen.dart';
import '../features/library/presentation/pages/library_screen.dart';
import '../features/main_screen/presentation/pages/main_screen.dart';
import '../features/profile/presentation/pages/profile_screen.dart';
import '../features/search/presentation/pages/search_screen.dart';
import '../features/song/data/models/track_state.dart';
import '../features/song/presentation/pages/song_page.dart';
import '../features/song/presentation/pages/track_list_page.dart';
import '../features/song/presentation/providers/track_notifier.dart';
import '../features/splash/presentation/pages/splash_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.read(goRouterRefreshProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final path = state.matchedLocation;
      final isAuthPage = path == '/login' || path == '/register';
      final isSplashPage = path == '/splash';

      return switch (authState) {
        AuthInitial() || AuthLoading() => isSplashPage ? null : '/splash',

        AuthAuthenticated() => (isSplashPage || isAuthPage) ? '/' : null,

        AuthUnauthenticated() || AuthError() => isAuthPage ? null : '/login',
      };
    },
    errorBuilder: (_, _) => const RouteErrorPage(),
    routes: [
      GoRoute(
        path: '/login',
        name: RouteName.login,
        builder: (_, _) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: RouteName.register,
        builder: (_, _) => const SignupScreen(),
      ),
      GoRoute(
        path: '/songs',
        name: RouteName.songs,
        builder: (_, _) => const HomeScreen(),
      ),
      GoRoute(
        path: '/albums',
        name: RouteName.albumList,
        builder: (_, _) => const AlbumsList(),
      ),
      GoRoute(
        path: '/albums/:id',
        name: RouteName.album,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) return const RouteErrorPage();
          return AlbumScreen(id: id);
        },
      ),
      GoRoute(
        path: '/trackList',
        name: RouteName.trackList,
        builder: (context, state) {
          final extra = state.extra;
          final map = extra is Map ? extra : const {};
          final provider = map['provider'];
          if (provider is! NotifierProvider<TrackNotifier, TrackState>) {
            return const RouteErrorPage();
          }
          final title = map['title'];
          return TrackListPage(
            provider: provider,
            title: title is String && title.isNotEmpty ? title : 'Track List',
          );
        },
      ),
      GoRoute(
        path: '/song/:id',
        name: RouteName.song,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) return const RouteErrorPage();
          return SongPage(songId: id);
        },
      ),
      GoRoute(
        path: '/splash',
        name: RouteName.splash,
        builder: (_, _) => const SplashScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          int index = 0;
          switch (state.uri.path) {
            case '/':
              index = 0;
              break;
            case '/search':
              index = 1;
              break;
            case '/library':
              index = 2;
              break;
            case '/profile':
              index = 3;
              break;
          }

          return MainScreen(index: index, child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: RouteName.home,
            builder: (_, _) => const HomeScreen(),
          ),

          GoRoute(
            path: '/search',
            name: RouteName.search,
            builder: (_, _) => const SearchScreen(),
          ),

          GoRoute(
            path: '/library',
            name: RouteName.library,
            builder: (_, _) => const LibraryScreen(),
          ),

          GoRoute(
            path: '/profile',
            name: RouteName.profile,
            builder: (_, _) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Shown for unknown URLs / bad route arguments instead of crashing.
class RouteErrorPage extends StatelessWidget {
  const RouteErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: AppErrorView(
        title: 'Page not found',
        message: "We couldn't open that page.",
        retryLabel: 'Go home',
        onRetry: () => context.go('/'),
      ),
    );
  }
}
