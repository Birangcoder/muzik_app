import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/appRouteName.dart';
import '../core/router/go_router_refresh_notifier.dart';
import '../features/auth/data/model/auth_state.dart';
import '../features/auth/presentation/pages/login_screen.dart';
import '../features/auth/presentation/pages/register_screen.dart';
import '../features/auth/presentation/provider/authProvider.dart';
import '../features/home/presentation/pages/home_screen.dart';
import '../features/library/presentation/pages/library_screen.dart';
import '../features/mainScreen/presentation/page/mainScreen.dart';
import '../features/profile/presentation/pages/profile_screen.dart';
import '../features/search/presentation/pages/search_screen.dart';
import '../features/song/presentation/pages/song.dart';
import '../features/song/presentation/pages/trending_page.dart';
import '../features/splash/presentation/page/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(goRouterRefreshProvider);

  return GoRouter(
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
    routes: [
      GoRoute(
        path: '/login',
        name: RouteName.login,
        builder: (_, _) => LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: RouteName.register,
        builder: (_, _) => SignupScreen(),
      ),
      GoRoute(
        path: '/songs',
        name: RouteName.songs,
        builder: (_, _) => const HomeScreen(),
        // song route removed from here — moved into the ShellRoute below
      ),
      GoRoute(
        path: '/trending',
        name: RouteName.trending,
        builder: (_, _) => const TrendingPage(),
      ),
      GoRoute(
        path: '/splash',
        name: RouteName.splash,
        builder: (_, _) => SplashScreen(),
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
            routes: [
              GoRoute(
                path: 'song/:id', // full path becomes /song/:id
                name: RouteName.song,
                builder: (context, state) {
                  final int id = int.parse(state.pathParameters['id']!);
                  return SongPage(songId: id);
                },
              ),
            ],
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
