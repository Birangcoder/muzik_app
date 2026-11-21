import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzik/features/library/presentation/pages/library_screen.dart';
import 'package:muzik/features/profile/presentation/pages/profile_screen.dart';
import 'package:muzik/features/search/presentation/pages/search_screen.dart';

import '../helpers/fakes.dart';

void main() {
  setUpAll(configureTestEnvironment);

  testWidgets('search screen renders title, input and categories', (
    tester,
  ) async {
    useLargeScreen(tester);
    await tester.pumpWidget(wrap(const SearchScreen()));
    expect(find.text('Search'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Browse categories'), findsOneWidget);
    expect(find.text('Pop'), findsWidgets);
  });

  testWidgets('search filters categories by query and clear restores them', (
    tester,
  ) async {
    useLargeScreen(tester);
    await tester.pumpWidget(wrap(const SearchScreen()));

    await tester.enterText(find.byType(TextField), 'Punjabi');
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(GridView),
        matching: find.text('Punjabi'),
      ),
      findsOneWidget,
    );

    expect(
      find.descendant(
        of: find.byType(GridView),
        matching: find.text('Bollywood'),
      ),
      findsNothing,
    );

    await tester.tap(find.byTooltip('Clear search'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(GridView),
        matching: find.text('Bollywood'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('library displays collections and filter chips', (tester) async {
    useLargeScreen(tester);
    await tester.pumpWidget(wrap(const LibraryScreen()));
    expect(find.text('Your library'), findsOneWidget);
    expect(find.text('Liked songs'), findsOneWidget);
    expect(find.text('Downloads'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Playlists'));
    await tester.pumpAndSettle();
    expect(find.text('My playlist'), findsOneWidget);
    expect(find.text('Downloads'), findsNothing);
  });

  testWidgets('profile shows account, preferences and sign out action', (
    tester,
  ) async {
    useLargeScreen(tester);
    await tester.pumpWidget(wrap(const ProfileScreen()));
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Edit profile'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
  });
}
