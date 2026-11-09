import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muzik/main.dart';

import 'helpers/fakes.dart';

/// Whole-app smoke test: boots MyApp with every platform dependency faked,
/// goes splash -> login (no saved session) and must not throw.
void main() {
  setUpAll(configureTestEnvironment);

  testWidgets('app starts and reaches the login screen without errors', (
    tester,
  ) async {
    useLargeScreen(tester);
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: baseOverrides(),
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.textContaining('is not a subtype'), findsNothing);
  });
}
