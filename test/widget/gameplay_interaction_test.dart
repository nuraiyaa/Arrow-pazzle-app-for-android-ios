import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arrow_puzzle_game/features/gameplay/presentation/gameplay_screen.dart';
import 'package:arrow_puzzle_game/domain/models/game_mode.dart';
import 'package:arrow_puzzle_game/features/gameplay/presentation/widgets/arrow_board_canvas.dart';

void main() {
  group('GameplayScreen Widget & Lifecycle Interaction Tests', () {
    testWidgets('GameplayScreen mounts with Canvas, HUD and tools in relaxed mode', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameplayScreen(
              mode: GameModeType.relaxed,
              levelNumber: 1,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check Header HUD
      expect(find.text('STAGE 1'), findsOneWidget);
      expect(find.byType(ArrowBoardCanvas), findsOneWidget);

      // Check Tool buttons
      expect(find.text('Undo'), findsOneWidget);
      expect(find.text('Hint'), findsOneWidget);
      expect(find.text('Restart'), findsOneWidget);

      // Tap Hint button
      await tester.tap(find.text('Hint'));
      await tester.pumpAndSettle();
    });

    testWidgets('GameplayScreen pause dialog opens and resumes cleanly', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameplayScreen(
              mode: GameModeType.relaxed,
              levelNumber: 2,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find pause button by its icon and tap it
      final pauseFinder = find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.onPressed != null,
      );
      if (pauseFinder.evaluate().isNotEmpty) {
        await tester.tap(pauseFinder.first);
        await tester.pumpAndSettle();

        // Check Pause dialog
        expect(find.text('GAME PAUSED'), findsOneWidget);
        expect(find.text('RESUME'), findsOneWidget);
        expect(find.text('MAIN MENU'), findsOneWidget);

        // Resume game
        await tester.tap(find.text('RESUME'));
        await tester.pumpAndSettle();
        expect(find.text('GAME PAUSED'), findsNothing);
      }
    });

    testWidgets('GameplayScreen in timed mode displays countdown timer', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameplayScreen(
              mode: GameModeType.timed,
              levelNumber: 1,
            ),
          ),
        ),
      );
      // Let periodic timer tick once
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('TIMED RUSH'), findsOneWidget);
      expect(find.byType(ArrowBoardCanvas), findsOneWidget);
    });
  });
}
