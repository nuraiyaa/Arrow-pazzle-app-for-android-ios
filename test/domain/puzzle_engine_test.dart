import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_puzzle_game/domain/models/arrow_direction.dart';
import 'package:arrow_puzzle_game/domain/models/arrow_entity.dart';
import 'package:arrow_puzzle_game/domain/models/grid_position.dart';
import 'package:arrow_puzzle_game/domain/models/puzzle_board.dart';
import 'package:arrow_puzzle_game/domain/engine/raycast_collision_detector.dart';
import 'package:arrow_puzzle_game/domain/engine/puzzle_solver.dart';
import 'package:arrow_puzzle_game/domain/engine/reverse_puzzle_generator.dart';
import 'package:arrow_puzzle_game/domain/engine/game_session.dart';
import 'package:arrow_puzzle_game/domain/models/level_model.dart';

void main() {
  group('Core Engine - ArrowDirection & GridPosition Tests', () {
    test('ArrowDirection returns correct deltas and opposites', () {
      expect(ArrowDirection.up.dx, 0);
      expect(ArrowDirection.up.dy, -1);
      expect(ArrowDirection.up.opposite, ArrowDirection.down);

      expect(ArrowDirection.down.dx, 0);
      expect(ArrowDirection.down.dy, 1);
      expect(ArrowDirection.down.opposite, ArrowDirection.up);

      expect(ArrowDirection.left.dx, -1);
      expect(ArrowDirection.left.dy, 0);
      expect(ArrowDirection.left.opposite, ArrowDirection.right);

      expect(ArrowDirection.right.dx, 1);
      expect(ArrowDirection.right.dy, 0);
      expect(ArrowDirection.right.opposite, ArrowDirection.left);
    });

    test('GridPosition bounds check', () {
      const posInside = GridPosition(2, 3);
      const posOutside = GridPosition(5, 5);
      const posNegative = GridPosition(-1, 0);

      expect(posInside.isWithinBounds(5, 5), isTrue);
      expect(posOutside.isWithinBounds(5, 5), isFalse);
      expect(posNegative.isWithinBounds(5, 5), isFalse);
    });
  });

  group('Core Engine - Raycast Collision Detection Tests', () {
    test('Arrow pointing to boundary without obstacle escapes freely', () {
      final board = PuzzleBoard(width: 5, height: 5);
      // Arrow at (2, 0) pointing UP -> immediate boundary exit
      const arrow = ArrowEntity(
        id: 'arrow_top',
        position: GridPosition(2, 0),
        direction: ArrowDirection.up,
      );
      board.addArrow(arrow);

      final result = RaycastCollisionDetector.validatePath(board, arrow);
      expect(result.isClear, isTrue);
      expect(result.type, CollisionType.none);
    });

    test('Arrow blocked by another active arrow returns collision', () {
      final board = PuzzleBoard(width: 5, height: 5);
      // Arrow A at (2, 2) pointing UP
      const arrowA = ArrowEntity(
        id: 'arrow_a',
        position: GridPosition(2, 2),
        direction: ArrowDirection.up,
      );
      // Arrow B at (2, 1) blocking A's path
      const arrowB = ArrowEntity(
        id: 'arrow_b',
        position: GridPosition(2, 1),
        direction: ArrowDirection.right,
      );
      board.addArrow(arrowA);
      board.addArrow(arrowB);

      final result = RaycastCollisionDetector.validatePath(board, arrowA);
      expect(result.isClear, isFalse);
      expect(result.type, CollisionType.arrowCollision);
      expect(result.blockingArrow?.id, 'arrow_b');
    });

    test('Arrow blocked by obstacle returns obstacle collision', () {
      final board = PuzzleBoard(width: 5, height: 5);
      board.obstacles.add(const GridPosition(2, 1));

      const arrow = ArrowEntity(
        id: 'arrow_blocked_by_rock',
        position: GridPosition(2, 2),
        direction: ArrowDirection.up,
      );
      board.addArrow(arrow);

      final result = RaycastCollisionDetector.validatePath(board, arrow);
      expect(result.isClear, isFalse);
      expect(result.type, CollisionType.obstacleCollision);
      expect(result.obstaclePosition, const GridPosition(2, 1));
    });
  });

  group('Core Engine - Reverse Puzzle Generator & Solvability Tests', () {
    test('Generated puzzles are 100% solvable via PuzzleSolver', () {
      // Test multiple generated puzzles across multiple board configurations
      for (int i = 0; i < 5; i++) {
        final config = PuzzleGenerationConfig(
          width: 5,
          height: 5,
          arrowCount: 10,
          seed: 1000 + i,
        );
        final board = ReversePuzzleGenerator.generate(config);

        expect(board.remainingCount, greaterThanOrEqualTo(8));

        // Solve the generated puzzle
        final solution = PuzzleSolver.solve(board);
        expect(solution.isSolvable, isTrue, reason: 'Generated puzzle seed ${1000 + i} must be 100% solvable!');
        expect(solution.solutionOrder.length, board.remainingCount);
      }
    });

    test('Reverse generator with obstacles creates solvable boards', () {
      final config = PuzzleGenerationConfig(
        width: 6,
        height: 6,
        arrowCount: 15,
        obstacleCount: 2,
        seed: 42,
      );
      final board = ReversePuzzleGenerator.generate(config);
      final solution = PuzzleSolver.solve(board);

      expect(solution.isSolvable, isTrue);
      expect(board.obstacles.length, 2);
    });
  });

  group('Core Engine - GameSession Lifecycle Tests', () {
    test('GameSession handles valid escape, win condition, and undo', () {
      final board = PuzzleBoard(width: 4, height: 4);
      // Arrow 1 at (0, 0) pointing UP (clear)
      const arrow1 = ArrowEntity(id: 'a1', position: GridPosition(0, 0), direction: ArrowDirection.up);
      // Arrow 2 at (1, 1) pointing DOWN (clear)
      const arrow2 = ArrowEntity(id: 'a2', position: GridPosition(1, 1), direction: ArrowDirection.down);
      board.addArrow(arrow1);
      board.addArrow(arrow2);

      final session = GameSession(
        board: board,
        config: LevelConfig.forLevel(levelNumber: 1),
        hearts: 3,
      );

      expect(session.remainingCount, 2);
      expect(session.isWon, isFalse);

      // Tap Arrow 1
      final tap1 = session.tapArrow('a1');
      expect(tap1.outcome, TapOutcome.arrowEscaped);
      expect(session.board.remainingCount, 1);
      expect(session.movesCount, 1);
      expect(session.canUndo, isTrue);

      // Undo Arrow 1
      final undoSuccess = session.undo();
      expect(undoSuccess, isTrue);
      expect(session.board.remainingCount, 2);

      // Tap Arrow 1 again
      session.tapArrow('a1');
      expect(session.board.remainingCount, 1);

      // Tap Arrow 2 -> Win Condition!
      final tap2 = session.tapArrow('a2');
      expect(tap2.outcome, TapOutcome.levelWon);
      expect(session.isWon, isTrue);
      expect(session.board.remainingCount, 0);
    });

    test('GameSession handles collision, heart depletion, and game over', () {
      final board = PuzzleBoard(width: 4, height: 4);
      // a1 points right into a2
      const a1 = ArrowEntity(id: 'a1', position: GridPosition(1, 1), direction: ArrowDirection.right);
      const a2 = ArrowEntity(id: 'a2', position: GridPosition(2, 1), direction: ArrowDirection.down);
      board.addArrow(a1);
      board.addArrow(a2);

      final session = GameSession(
        board: board,
        config: LevelConfig.forLevel(levelNumber: 1),
        hearts: 2,
      );

      // Tap a1 (blocked by a2) -> lose 1 heart
      final tap1 = session.tapArrow('a1');
      expect(tap1.outcome, TapOutcome.collisionError);
      expect(session.hearts, 1);
      expect(session.isGameOver, isFalse);

      // Tap a1 again -> lose last heart -> Game Over!
      final tap2 = session.tapArrow('a1');
      expect(tap2.outcome, TapOutcome.outOfHearts);
      expect(session.hearts, 0);
      expect(session.isGameOver, isTrue);
    });

    test('Hint system highlights valid escapable arrow', () {
      final board = PuzzleBoard(width: 4, height: 4);
      // a1 blocked by a2
      const a1 = ArrowEntity(id: 'a1', position: GridPosition(1, 1), direction: ArrowDirection.right);
      // a2 clear pointing DOWN
      const a2 = ArrowEntity(id: 'a2', position: GridPosition(2, 1), direction: ArrowDirection.down);
      board.addArrow(a1);
      board.addArrow(a2);

      final session = GameSession(
        board: board,
        config: LevelConfig.forLevel(levelNumber: 1),
      );
      final hintArrowId = session.requestHint();

      expect(hintArrowId, 'a2', reason: 'Hint should accurately pick the unblocked arrow a2');
      expect(session.hintsUsed, 1);
      expect(session.activeHintArrowId, 'a2');
    });
  });
}

extension on GameSession {
  int get remainingCount => board.remainingCount;
}
