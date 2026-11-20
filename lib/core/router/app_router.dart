import 'package:go_router/go_router.dart';
import '../../domain/models/game_mode.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/gameplay/presentation/gameplay_screen.dart';
import '../../features/modes/presentation/game_modes_screen.dart';
import '../../features/levels/presentation/level_selection_screen.dart';
import '../../features/collections/presentation/collections_screen.dart';
import '../../features/leaderboard/presentation/leaderboard_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/gameplay',
      builder: (context, state) {
        final modeParam = state.uri.queryParameters['mode'];
        final levelParam = state.uri.queryParameters['level'];
        final diffParam = state.uri.queryParameters['diff'];

        GameModeType mode = GameModeType.relaxed;
        if (modeParam == 'challenge') mode = GameModeType.challenge;
        if (modeParam == 'timed') mode = GameModeType.timed;

        DifficultyTier diff = DifficultyTier.hard;
        if (diffParam == 'easy') diff = DifficultyTier.easy;
        if (diffParam == 'master') diff = DifficultyTier.master;

        final levelNumber = int.tryParse(levelParam ?? '') ?? 1;

        return GameplayScreen(
          mode: mode,
          levelNumber: levelNumber,
          difficulty: diff,
        );
      },
    ),
    GoRoute(
      path: '/modes',
      builder: (context, state) => const GameModesScreen(),
    ),
    GoRoute(
      path: '/levels',
      builder: (context, state) => const LevelSelectionScreen(),
    ),
    GoRoute(
      path: '/collections',
      builder: (context, state) => const CollectionsScreen(),
    ),
    GoRoute(
      path: '/leaderboard',
      builder: (context, state) => const LeaderboardScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
