import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arrow_puzzle_game/main.dart';
import 'package:arrow_puzzle_game/features/settings/presentation/settings_screen.dart';
import 'package:arrow_puzzle_game/features/collections/presentation/collections_screen.dart';
import 'package:arrow_puzzle_game/features/leaderboard/presentation/leaderboard_screen.dart';
import 'package:arrow_puzzle_game/features/modes/presentation/game_modes_screen.dart';
import 'package:arrow_puzzle_game/features/levels/presentation/level_selection_screen.dart';

void main() {
  group('Widget Navigation & Screen Integrity Tests', () {
    testWidgets('HomeScreen renders HUD, branding, and navigation elements', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: ArrowPuzzleApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Check title and key UI elements
      expect(find.text('ARROW ESCAPE'), findsOneWidget);
      expect(find.text('PLAY'), findsOneWidget);
      expect(find.text('MODES'), findsOneWidget);
      expect(find.text('Daily Reward Active'), findsOneWidget);
    });

    testWidgets('SettingsScreen mounts, renders options, and allows toggles', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SETTINGS'), findsOneWidget);
      expect(find.text('Music'), findsOneWidget);
      expect(find.text('Sound Effects (SFX)'), findsOneWidget);
      expect(find.text('Haptic Feedback (Vibration)'), findsOneWidget);
      expect(find.text('Cloud Progress Sync'), findsOneWidget);
      expect(find.text('Sync Now'), findsOneWidget);

      // Verify switches exist and are interactive
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(3));

      await tester.tap(switches.first);
      await tester.pumpAndSettle();
    });

    testWidgets('CollectionsScreen mounts and renders arrow skin choices', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CollectionsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('COLLECTIONS'), findsOneWidget);
      expect(find.text('CURRENTLY EQUIPPED'), findsOneWidget);
      expect(find.text('Classic Obsidian'), findsWidgets);
      expect(find.text('Cyber Neon'), findsOneWidget);
      expect(find.text('Golden Royal'), findsOneWidget);
    });

    testWidgets('LeaderboardScreen mounts and renders league tabs', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LeaderboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('LEADERBOARD'), findsOneWidget);
      expect(find.text('Weekly League'), findsOneWidget);
      expect(find.text('All-Time Stars'), findsOneWidget);

      // Switch to All-Time Stars tab
      await tester.tap(find.text('All-Time Stars'));
      await tester.pumpAndSettle();
    });

    testWidgets('GameModesScreen mounts and renders all 3 gameplay modes', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GameModesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('GAME MODES'), findsOneWidget);
      expect(find.text('Relaxed Mode'), findsOneWidget);
      expect(find.text('Challenge Mode'), findsOneWidget);
      expect(find.text('Timed Rush'), findsOneWidget);
    });

    testWidgets('LevelSelectionScreen mounts and renders stages and star chest', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LevelSelectionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CHAPTER 1 & 2'), findsOneWidget);
      expect(find.text('Stages 1 - 40'), findsOneWidget);
      expect(find.text('Chapter Star Chest'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // Stage 1 button
    });
  });
}
