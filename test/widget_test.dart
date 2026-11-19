import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arrow_puzzle_game/main.dart';
import 'package:arrow_puzzle_game/core/constants/app_strings.dart';

void main() {
  testWidgets('App smoke test - verifies HomeScreen mounts and renders Title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ArrowPuzzleApp(),
      ),
    );

    // Let any async animations settle
    await tester.pump();

    // Expect to find the main title "ARROW ESCAPE"
    expect(find.text(AppStrings.appTitle.toUpperCase()), findsOneWidget);
    // Expect to find the "PLAY" button
    expect(find.text(AppStrings.play), findsOneWidget);
  });
}
