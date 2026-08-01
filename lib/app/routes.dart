import 'package:go_router/go_router.dart';

import '../core/constants/appRouteName.dart';
import '../features/home/presentation/pages/home_screen.dart';
import '../features/library/presentation/pages/library_screen.dart';
import '../features/mainScreen/presentation/page/mainScreen.dart';
import '../features/profile/presentation/pages/profile_screen.dart';
import '../features/search/presentation/pages/search_screen.dart';

final router = GoRouter(
  routes: [
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
