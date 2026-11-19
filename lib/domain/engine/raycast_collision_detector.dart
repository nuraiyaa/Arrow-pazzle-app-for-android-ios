import '../models/arrow_entity.dart';
import '../models/grid_position.dart';
import '../models/puzzle_board.dart';

enum CollisionType {
  none,            // Clear path to boundary
  arrowCollision,  // Blocked by another active arrow
  obstacleCollision // Blocked by immovable obstacle
}

class CollisionResult {
  final CollisionType type;
  final ArrowEntity? blockingArrow;
  final GridPosition? obstaclePosition;
  final List<GridPosition> rayPath;

  const CollisionResult({
    required this.type,
    this.blockingArrow,
    this.obstaclePosition,
    required this.rayPath,
  });

  bool get isClear => type == CollisionType.none;
  bool get isBlocked => !isClear;

  factory CollisionResult.clear(List<GridPosition> rayPath) {
    return CollisionResult(type: CollisionType.none, rayPath: rayPath);
  }

  factory CollisionResult.blockedByArrow(ArrowEntity arrow, List<GridPosition> rayPath) {
    return CollisionResult(
      type: CollisionType.arrowCollision,
      blockingArrow: arrow,
      rayPath: rayPath,
    );
  }

  factory CollisionResult.blockedByObstacle(GridPosition obstacle, List<GridPosition> rayPath) {
    return CollisionResult(
      type: CollisionType.obstacleCollision,
      obstaclePosition: obstacle,
      rayPath: rayPath,
    );
  }
}

/// Hardware-efficient Raycast Collision Detector
class RaycastCollisionDetector {
  RaycastCollisionDetector._();

  /// Casts a ray from the arrow's position in its pointing direction towards the board boundary.
  static CollisionResult validatePath(PuzzleBoard board, ArrowEntity arrow) {
    final rayPath = <GridPosition>[];
    final dir = arrow.direction;
    var current = arrow.position.translate(dir.dx, dir.dy);

    while (current.isWithinBounds(board.width, board.height)) {
      rayPath.add(current);

      // 1. Check obstacle
      if (board.isObstacleAt(current)) {
        return CollisionResult.blockedByObstacle(current, rayPath);
      }

      // 2. Check active arrow collision
      final blockingArrow = board.getArrowAt(current);
      if (blockingArrow != null && blockingArrow.id != arrow.id) {
        return CollisionResult.blockedByArrow(blockingArrow, rayPath);
      }

      // Move forward along the ray
      current = current.translate(dir.dx, dir.dy);
    }

    // Ray reached outside board boundaries with no obstructions
    return CollisionResult.clear(rayPath);
  }
}
