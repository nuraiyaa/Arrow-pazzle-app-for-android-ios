import 'package:go_router/go_router.dart';
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
      builder: (context, state) => const GameplayScreen(),
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
