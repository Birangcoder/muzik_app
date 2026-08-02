import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/appRouteName.dart';
import '../core/router/go_router_refresh_notifier.dart';
import '../features/auth/data/model/auth_state.dart';
import '../features/auth/presentation/pages/login_screen.dart';
import '../features/auth/presentation/provider/authProvider.dart';
import '../features/home/presentation/pages/home_screen.dart';
import '../features/library/presentation/pages/library_screen.dart';
import '../features/mainScreen/presentation/page/mainScreen.dart';
import '../features/profile/presentation/pages/profile_screen.dart';
import '../features/search/presentation/pages/search_screen.dart';
import '../features/splash/presentation/page/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(goRouterRefreshProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final path = state.matchedLocation;
      final isLoginPage = path == '/login';
      final isSplashPage = path == '/splash';

      return switch (authState) {
        // Still figuring out if a session exists -> hold on splash, don't redirect yet
        AuthInitial() || AuthLoading() => isSplashPage ? null : '/splash',

        // Confirmed logged in -> bounce away from splash/login into the app
        AuthAuthenticated() => (isSplashPage || isLoginPage) ? '/' : null,

        // Confirmed logged out / errored -> force to login unless already there
        AuthUnauthenticated() || AuthError() => isLoginPage ? null : '/login',
      };
    },
    routes: [
      GoRoute(path: '/login', name: RouteName.login, builder: (_, _) => LoginScreen()),
      GoRoute(path: '/splash', name: RouteName.splash, builder: (_, _) => SplashScreen()),
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
