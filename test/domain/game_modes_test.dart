import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_puzzle_game/domain/models/game_mode.dart';
import 'package:arrow_puzzle_game/domain/models/level_model.dart';
import 'package:arrow_puzzle_game/domain/models/arrow_direction.dart';
import 'package:arrow_puzzle_game/domain/models/arrow_entity.dart';
import 'package:arrow_puzzle_game/domain/models/grid_position.dart';
import 'package:arrow_puzzle_game/domain/models/puzzle_board.dart';
import 'package:arrow_puzzle_game/domain/engine/game_session.dart';
import 'package:arrow_puzzle_game/domain/engine/reverse_puzzle_generator.dart';
import 'package:arrow_puzzle_game/data/services/progress_service.dart';

void main() {
  group('Game Modes - Configuration & Level Generation Tests', () {
    test('Relaxed Mode generates appropriate difficulty configurations', () {
      final easyConfig = LevelConfig.forLevel(
        levelNumber: 1,
        mode: GameModeType.relaxed,
        difficulty: DifficultyTier.easy,
      );
      expect(easyConfig.gridWidth, 5);
      expect(easyConfig.obstacleCount, 0);
      expect(easyConfig.timeLimitSeconds, isNull);

      final hardConfig = LevelConfig.forLevel(
        levelNumber: 10,
        mode: GameModeType.relaxed,
        difficulty: DifficultyTier.hard,
      );
      expect(hardConfig.gridWidth, 6);
      expect(hardConfig.timeLimitSeconds, isNull);

      final masterConfig = LevelConfig.forLevel(
        levelNumber: 20,
        mode: GameModeType.relaxed,
        difficulty: DifficultyTier.master,
      );
      expect(masterConfig.gridWidth, 8);
    });

    test('Challenge Mode generates larger boards with obstacles', () {
      final challengeConfig = LevelConfig.forLevel(
        levelNumber: 1,
        mode: GameModeType.challenge,
      );
      expect(challengeConfig.gridWidth, 7);
      expect(challengeConfig.obstacleCount, greaterThan(0));
      expect(challengeConfig.timeLimitSeconds, isNull);

      // Verify that board generator creates a solvable challenge board with obstacles
      final board = ReversePuzzleGenerator.generate(
        PuzzleGenerationConfig(
          width: challengeConfig.gridWidth,
          height: challengeConfig.gridHeight,
          arrowCount: challengeConfig.arrowCount,
          obstacleCount: challengeConfig.obstacleCount,
          seed: 99,
        ),
      );
      expect(board.obstacles.length, challengeConfig.obstacleCount);
      expect(board.remainingCount, greaterThan(0));
    });

    test('Timed Mode generates countdown timer configuration', () {
      final timedConfig = LevelConfig.forLevel(
        levelNumber: 1,
        mode: GameModeType.timed,
      );
      expect(timedConfig.gridWidth, 6);
      expect(timedConfig.timeLimitSeconds, 60);
    });
  });

  group('Game Modes - Timed Mode Session Mechanics Tests', () {
    test('Timed mode counts down and handles out-of-time game over', () {
      final board = PuzzleBoard(width: 4, height: 4);
      board.addArrow(const ArrowEntity(id: 'a1', position: GridPosition(0, 0), direction: ArrowDirection.up));

      final config = const LevelConfig(
        levelNumber: 1,
        mode: GameModeType.timed,
        difficulty: DifficultyTier.hard,
        gridWidth: 4,
        gridHeight: 4,
        arrowCount: 1,
        timeLimitSeconds: 10,
        targetMoves: 1,
      );

      final session = GameSession(board: board, config: config);
      expect(session.isTimedMode, isTrue);
      expect(session.remainingTimeSeconds, 10.0);

      // Tick 5 seconds
      session.tick(5.0);
      expect(session.remainingTimeSeconds, 5.0);
      expect(session.isGameOver, isFalse);

      // Tick remaining 5.5 seconds -> out of time
      final justEnded = session.tick(5.5);
      expect(justEnded, isTrue);
      expect(session.remainingTimeSeconds, 0.0);
      expect(session.isOutOfTime, isTrue);
      expect(session.isGameOver, isTrue);
    });

    test('Timed mode adds +1.5s bonus time, combos, and score on escape', () {
      final board = PuzzleBoard(width: 4, height: 4);
      // a1 and a2 are unblocked
      board.addArrow(const ArrowEntity(id: 'a1', position: GridPosition(0, 0), direction: ArrowDirection.up));
      board.addArrow(const ArrowEntity(id: 'a2', position: GridPosition(1, 1), direction: ArrowDirection.down));

      final config = const LevelConfig(
        levelNumber: 1,
        mode: GameModeType.timed,
        difficulty: DifficultyTier.hard,
        gridWidth: 4,
        gridHeight: 4,
        arrowCount: 2,
        timeLimitSeconds: 20,
        targetMoves: 2,
      );

      final session = GameSession(board: board, config: config);

      // Tap a1: should add 1.5s bonus time and score
      final tap1 = session.tapArrow('a1');
      expect(tap1.outcome, TapOutcome.arrowEscaped);
      expect(session.remainingTimeSeconds, 21.5);
      expect(session.score, greaterThan(0));
      expect(session.comboStreak, 1);

      // Tap a2: combo streak increases, finishes level
      final tap2 = session.tapArrow('a2');
      expect(tap2.outcome, TapOutcome.levelWon);
      expect(session.comboStreak, 2);
      expect(session.isWon, isTrue);
      expect(session.calculateStars(), greaterThanOrEqualTo(1));
    });

    test('Timed mode collision penalizes time instead of heart loss', () {
      final board = PuzzleBoard(width: 4, height: 4);
      // a1 blocked by a2
      board.addArrow(const ArrowEntity(id: 'a1', position: GridPosition(1, 1), direction: ArrowDirection.right));
      board.addArrow(const ArrowEntity(id: 'a2', position: GridPosition(2, 1), direction: ArrowDirection.down));

      final config = const LevelConfig(
        levelNumber: 1,
        mode: GameModeType.timed,
        difficulty: DifficultyTier.hard,
        gridWidth: 4,
        gridHeight: 4,
        arrowCount: 2,
        timeLimitSeconds: 30,
        targetMoves: 2,
      );

      final session = GameSession(board: board, config: config);

      // Initial hearts remain intact
      expect(session.hearts, 3);

      // Tap a1 (collision) -> deducts 3 seconds time, combo resets
      final tap = session.tapArrow('a1');
      expect(tap.outcome, TapOutcome.collisionError);
      expect(session.hearts, 3); // hearts untouched in timed mode
      expect(session.remainingTimeSeconds, 27.0);
      expect(session.comboStreak, 0);
    });
  });

  group('ProgressService - Local Persistence Tests', () {
    test('ProgressService unlocks next level, updates stars and coins', () async {
      final service = ProgressService();
      expect(service.unlockedLevel, 1);
      expect(service.coins, 2450);
      expect(service.totalStars, 0);

      // Complete Level 1 with 3 stars
      await service.recordLevelComplete(levelNumber: 1, stars: 3, coinsEarned: 50);

      expect(service.unlockedLevel, 2);
      expect(service.isLevelUnlocked(2), isTrue);
      expect(service.getStarsForLevel(1), 3);
      expect(service.totalStars, 3);
      expect(service.coins, 2500);

      // Save Timed Mode High Score
      await service.recordTimedScore(3200);
      expect(service.timedHighScore, 3200);

      // Lower score doesn't overwrite high score
      await service.recordTimedScore(1800);
      expect(service.timedHighScore, 3200);
    });
  });
}
