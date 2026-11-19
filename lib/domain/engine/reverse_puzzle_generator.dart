import 'dart:math';
import '../models/arrow_direction.dart';
import '../models/arrow_entity.dart';
import '../models/grid_position.dart';
import '../models/puzzle_board.dart';
import 'puzzle_solver.dart';
import 'raycast_collision_detector.dart';

class PuzzleGenerationConfig {
  final int width;
  final int height;
  final int arrowCount;
  final int obstacleCount;
  final int? seed;

  const PuzzleGenerationConfig({
    required this.width,
    required this.height,
    required this.arrowCount,
    this.obstacleCount = 0,
    this.seed,
  });

  factory PuzzleGenerationConfig.easy() {
    return const PuzzleGenerationConfig(width: 5, height: 5, arrowCount: 12);
  }

  factory PuzzleGenerationConfig.medium() {
    return const PuzzleGenerationConfig(width: 6, height: 6, arrowCount: 22);
  }

  factory PuzzleGenerationConfig.hard() {
    return const PuzzleGenerationConfig(width: 7, height: 7, arrowCount: 32, obstacleCount: 2);
  }

  factory PuzzleGenerationConfig.master() {
    return const PuzzleGenerationConfig(width: 8, height: 8, arrowCount: 44, obstacleCount: 4);
  }
}

/// Guaranteed 100% Solvable Reverse-Play Puzzle Generator
class ReversePuzzleGenerator {
  ReversePuzzleGenerator._();

  static PuzzleBoard generate(PuzzleGenerationConfig config) {
    final random = config.seed != null ? Random(config.seed) : Random();

    for (int attempt = 0; attempt < 50; attempt++) {
      final board = PuzzleBoard(width: config.width, height: config.height);

      // 1. Place optional obstacles randomly first
      final placedObstacles = <GridPosition>{};
      int obstaclesToPlace = config.obstacleCount;
      while (obstaclesToPlace > 0) {
        final x = random.nextInt(config.width);
        final y = random.nextInt(config.height);
        final pos = GridPosition(x, y);
        if (!placedObstacles.contains(pos)) {
          placedObstacles.add(pos);
          board.obstacles.add(pos);
          obstaclesToPlace--;
        }
      }

      // 2. Reverse insertion of arrows
      int arrowsPlaced = 0;
      int failsafeAttempts = 0;

      while (arrowsPlaced < config.arrowCount && failsafeAttempts < 500) {
        failsafeAttempts++;

        // Pick an unoccupied cell
        final x = random.nextInt(config.width);
        final y = random.nextInt(config.height);
        final pos = GridPosition(x, y);

        if (board.isCellOccupied(pos)) continue;

        // Find directions that are currently clear to boundary
        final validDirections = <ArrowDirection>[];
        for (final dir in ArrowDirection.values) {
          final tempArrow = ArrowEntity(
            id: 'temp',
            position: pos,
            direction: dir,
          );
          final rayResult = RaycastCollisionDetector.validatePath(board, tempArrow);
          if (rayResult.isClear) {
            validDirections.add(dir);
          }
        }

        if (validDirections.isNotEmpty) {
          // Choose one valid direction
          final chosenDir = validDirections[random.nextInt(validDirections.length)];
          final arrowId = 'arrow_${pos.x}_${pos.y}_$arrowsPlaced';
          final newArrow = ArrowEntity(
            id: arrowId,
            position: pos,
            direction: chosenDir,
          );
          board.addArrow(newArrow);
          arrowsPlaced++;
        }
      }

      // 3. Double-verify solvability with automated solver
      final solverResult = PuzzleSolver.solve(board);
      if (solverResult.isSolvable && board.remainingCount >= (config.arrowCount * 0.8).toInt()) {
        return board;
      }
    }

    // Fallback: If heavy density retry reached, return an unconditionally verified minimal solvable board
    return _buildDeterministicFallbackBoard(config);
  }

  static PuzzleBoard _buildDeterministicFallbackBoard(PuzzleGenerationConfig config) {
    final board = PuzzleBoard(width: config.width, height: config.height);
    // Perimeter-facing arrows are unconditionally clear
    int count = 0;
    for (int x = 0; x < config.width; x++) {
      if (count >= config.arrowCount) break;
      board.addArrow(ArrowEntity(id: 'fb_top_$x', position: GridPosition(x, 0), direction: ArrowDirection.up));
      count++;
      if (count >= config.arrowCount) break;
      board.addArrow(ArrowEntity(id: 'fb_bot_$x', position: GridPosition(x, config.height - 1), direction: ArrowDirection.down));
      count++;
    }
    return board;
  }
}
