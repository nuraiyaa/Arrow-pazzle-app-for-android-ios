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
    return const PuzzleGenerationConfig(width: 6, height: 6, arrowCount: 10);
  }

  factory PuzzleGenerationConfig.medium() {
    return const PuzzleGenerationConfig(width: 7, height: 7, arrowCount: 16);
  }

  factory PuzzleGenerationConfig.hard() {
    return const PuzzleGenerationConfig(width: 8, height: 8, arrowCount: 22, obstacleCount: 2);
  }

  factory PuzzleGenerationConfig.master() {
    return const PuzzleGenerationConfig(width: 9, height: 9, arrowCount: 28, obstacleCount: 3);
  }
}

/// Guaranteed 100% Solvable Reverse-Play Puzzle Generator supporting Polyline & Maze Arrows
class ReversePuzzleGenerator {
  ReversePuzzleGenerator._();

  static PuzzleBoard generate(PuzzleGenerationConfig config) {
    final random = config.seed != null ? Random(config.seed) : Random();

    for (int attempt = 0; attempt < 50; attempt++) {
      final board = PuzzleBoard(width: config.width, height: config.height);

      // 1. Place optional obstacles
      final placedObstacles = <GridPosition>{};
      int obstaclesToPlace = config.obstacleCount;
      int obsAttempts = 0;
      while (obstaclesToPlace > 0 && obsAttempts < 100) {
        obsAttempts++;
        final x = random.nextInt(config.width);
        final y = random.nextInt(config.height);
        final pos = GridPosition(x, y);
        if (!placedObstacles.contains(pos)) {
          placedObstacles.add(pos);
          board.obstacles.add(pos);
          obstaclesToPlace--;
        }
      }

      // 2. Reverse insertion of polyline arrows
      int arrowsPlaced = 0;
      int failsafeAttempts = 0;

      while (arrowsPlaced < config.arrowCount && failsafeAttempts < 600) {
        failsafeAttempts++;

        final headX = random.nextInt(config.width);
        final headY = random.nextInt(config.height);
        final headPos = GridPosition(headX, headY);

        if (board.isCellOccupied(headPos)) continue;

        // Check which directions have a clear ray from headPos to the boundary
        final validExitDirections = <ArrowDirection>[];
        for (final dir in ArrowDirection.values) {
          final tempArrow = ArrowEntity(
            id: 'temp_head',
            position: headPos,
            direction: dir,
            pathPoints: [headPos],
          );
          final ray = RaycastCollisionDetector.validatePath(board, tempArrow);
          if (ray.isClear) {
            validExitDirections.add(dir);
          }
        }

        if (validExitDirections.isEmpty) continue;

        final headDir = validExitDirections[random.nextInt(validExitDirections.length)];
        final backDir = headDir.opposite;

        // Grow the body backwards from headPos
        final path = _growArrowPath(board, headPos, backDir, random);
        if (path.isNotEmpty) {
          final arrowId = 'arrow_${arrowsPlaced}_${headPos.x}_${headPos.y}';
          final arrow = ArrowEntity(
            id: arrowId,
            position: headPos,
            direction: headDir,
            pathPoints: path, // from tail to head
          );

          board.addArrow(arrow);
          arrowsPlaced++;
        }
      }

      // 3. Double-verify solvability with automated solver
      final solverResult = PuzzleSolver.solve(board);
      final minRequired = (config.arrowCount * 0.75).toInt().clamp(1, config.arrowCount);
      if (solverResult.isSolvable &&
          (board.remainingCount >= minRequired || board.remainingCount >= 8) &&
          board.obstacles.length == config.obstacleCount) {
        return board;
      }
    }

    // Fallback: If retry threshold reached, return guaranteed solvable perimeter board
    return _buildDeterministicFallbackBoard(config);
  }

  /// Grows an arrow body backwards from headPos into available unoccupied cells
  static List<GridPosition> _growArrowPath(
    PuzzleBoard board,
    GridPosition headPos,
    ArrowDirection backDir,
    Random random,
  ) {
    final path = <GridPosition>[headPos];
    var current = headPos;

    // Decide body shape type:
    // 0 = Straight (1 to 2 extra steps)
    // 1 = L-shape (turn once)
    // 2 = U-turn or S-shape (turn twice)
    final shapeType = random.nextInt(3);

    // Initial segment backwards in backDir
    int segment1Length = 1 + random.nextInt(2);
    for (int i = 0; i < segment1Length; i++) {
      final next = current.translate(backDir.dx, backDir.dy);
      if (next.isWithinBounds(board.width, board.height) &&
          !board.isCellOccupied(next) &&
          !path.contains(next)) {
        current = next;
        path.add(current);
      } else {
        break;
      }
    }

    if (shapeType >= 1 && path.length >= 2) {
      // Pick a perpendicular turn direction
      final turnDirs = _getPerpendicularDirections(backDir);
      turnDirs.shuffle(random);

      ArrowDirection? chosenTurnDir;
      for (final tDir in turnDirs) {
        final testPos = current.translate(tDir.dx, tDir.dy);
        if (testPos.isWithinBounds(board.width, board.height) &&
            !board.isCellOccupied(testPos) &&
            !path.contains(testPos)) {
          chosenTurnDir = tDir;
          break;
        }
      }

      if (chosenTurnDir != null) {
        int segment2Length = 1 + random.nextInt(2);
        for (int i = 0; i < segment2Length; i++) {
          final next = current.translate(chosenTurnDir.dx, chosenTurnDir.dy);
          if (next.isWithinBounds(board.width, board.height) &&
              !board.isCellOccupied(next) &&
              !path.contains(next)) {
            current = next;
            path.add(current);
          } else {
            break;
          }
        }

        // Optional second turn for U-turn / winding shapes
        if (shapeType == 2 && path.length >= 3) {
          final secondTurnDirs = _getPerpendicularDirections(chosenTurnDir);
          secondTurnDirs.shuffle(random);
          for (final sDir in secondTurnDirs) {
            final next = current.translate(sDir.dx, sDir.dy);
            if (next.isWithinBounds(board.width, board.height) &&
                !board.isCellOccupied(next) &&
                !path.contains(next)) {
              current = next;
              path.add(current);
              break;
            }
          }
        }
      }
    }

    // Path was built from head backwards to tail; reverse so it is TAIL -> HEAD
    return path.reversed.toList();
  }

  static List<ArrowDirection> _getPerpendicularDirections(ArrowDirection dir) {
    if (dir == ArrowDirection.up || dir == ArrowDirection.down) {
      return [ArrowDirection.left, ArrowDirection.right];
    } else {
      return [ArrowDirection.up, ArrowDirection.down];
    }
  }

  static PuzzleBoard _buildDeterministicFallbackBoard(PuzzleGenerationConfig config) {
    final board = PuzzleBoard(width: config.width, height: config.height);

    // Place configured obstacles safely
    for (int i = 0; i < config.obstacleCount; i++) {
      board.obstacles.add(GridPosition(i + 1, config.height ~/ 2));
    }

    int count = 0;
    for (int x = 0; x < config.width; x++) {
      if (count >= config.arrowCount) break;
      final head = GridPosition(x, 0);
      final tail = GridPosition(x, 1);
      if (board.isObstacleAt(head) || board.isObstacleAt(tail)) continue;
      board.addArrow(
        ArrowEntity(
          id: 'fb_top_$x',
          position: head,
          direction: ArrowDirection.up,
          pathPoints: [tail, head],
        ),
      );
      count++;
    }

    for (int x = 0; x < config.width; x++) {
      if (count >= config.arrowCount) break;
      final head = GridPosition(x, config.height - 1);
      final tail = GridPosition(x, config.height - 2);
      if (board.isObstacleAt(head) || board.isObstacleAt(tail)) continue;
      board.addArrow(
        ArrowEntity(
          id: 'fb_bot_$x',
          position: head,
          direction: ArrowDirection.down,
          pathPoints: [tail, head],
        ),
      );
      count++;
    }

    return board;
  }
}
