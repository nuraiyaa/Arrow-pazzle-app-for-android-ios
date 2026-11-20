import 'game_mode.dart';

/// Level configuration specification
class LevelConfig {
  final int levelNumber;
  final GameModeType mode;
  final DifficultyTier difficulty;
  final int gridWidth;
  final int gridHeight;
  final int arrowCount;
  final int obstacleCount;
  final int? timeLimitSeconds;
  final int targetMoves;

  const LevelConfig({
    required this.levelNumber,
    required this.mode,
    required this.difficulty,
    required this.gridWidth,
    required this.gridHeight,
    required this.arrowCount,
    this.obstacleCount = 0,
    this.timeLimitSeconds,
    required this.targetMoves,
  });

  /// Deterministically creates level config based on levelNumber and mode
  factory LevelConfig.forLevel({
    required int levelNumber,
    GameModeType mode = GameModeType.relaxed,
    DifficultyTier difficulty = DifficultyTier.hard,
  }) {
    switch (mode) {
      case GameModeType.relaxed:
        final width = difficulty.boardWidth;
        final height = difficulty.boardHeight;
        // Arrow count scales smoothly with level progression
        final arrowCount = (difficulty.baseArrowCount + (levelNumber % 10) * 0.5).toInt().clamp(8, width * height - 4);
        return LevelConfig(
          levelNumber: levelNumber,
          mode: mode,
          difficulty: difficulty,
          gridWidth: width,
          gridHeight: height,
          arrowCount: arrowCount,
          obstacleCount: 0,
          targetMoves: arrowCount,
        );

      case GameModeType.challenge:
        // Challenge mode features larger boards and obstacles
        const width = 7;
        const height = 7;
        final obstacles = (2 + (levelNumber % 3)).clamp(1, 4);
        final arrowCount = (26 + (levelNumber % 5) * 2).clamp(16, 40);
        return LevelConfig(
          levelNumber: levelNumber,
          mode: mode,
          difficulty: DifficultyTier.master,
          gridWidth: width,
          gridHeight: height,
          arrowCount: arrowCount,
          obstacleCount: obstacles,
          targetMoves: arrowCount + 3,
        );

      case GameModeType.timed:
        // Timed blitz mode: 6x6 board, 60s countdown
        const width = 6;
        const height = 6;
        const arrowCount = 20;
        return const LevelConfig(
          levelNumber: 1,
          mode: GameModeType.timed,
          difficulty: DifficultyTier.hard,
          gridWidth: width,
          gridHeight: height,
          arrowCount: arrowCount,
          obstacleCount: 0,
          timeLimitSeconds: 60,
          targetMoves: arrowCount,
        );
    }
  }
}
