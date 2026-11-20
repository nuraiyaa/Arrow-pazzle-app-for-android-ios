import 'arrow_direction.dart';
import 'grid_position.dart';

enum ArrowState {
  idle,
  hinted,
  colliding, // Error feedback (shake and bounce)
  escaping,  // Smoothly sliding off canvas
  cleared,   // Fully removed
}

/// Represents an arrow tile entity on the puzzle board.
/// Supports both straight multi-unit arrows and bent polyline paths (as seen in Golden Mind Arrows).
class ArrowEntity {
  final String id;
  /// The head position of the arrow
  final GridPosition position;
  /// Direction the head points (movement vector)
  final ArrowDirection direction;
  /// Ordered points from TAIL to HEAD
  final List<GridPosition> pathPoints;
  final ArrowState state;
  /// Animation progress from 0.0 to 1.0 (used during escaping or collision shake)
  final double animationProgress;

  const ArrowEntity({
    required this.id,
    required this.position,
    required this.direction,
    this.pathPoints = const [],
    this.state = ArrowState.idle,
    this.animationProgress = 0.0,
  });

  /// All discrete grid positions occupied by this arrow
  Set<GridPosition> get occupiedPositions {
    if (pathPoints.isEmpty) return {position};
    final occupied = <GridPosition>{};
    for (int i = 0; i < pathPoints.length - 1; i++) {
      final p1 = pathPoints[i];
      final p2 = pathPoints[i + 1];
      final dx = (p2.x - p1.x).sign;
      final dy = (p2.y - p1.y).sign;
      int curX = p1.x;
      int curY = p1.y;
      occupied.add(GridPosition(curX, curY));
      while (curX != p2.x || curY != p2.y) {
        curX += dx;
        curY += dy;
        occupied.add(GridPosition(curX, curY));
      }
    }
    occupied.add(position);
    return occupied;
  }

  /// Ordered points list guaranteed to contain at least the head
  List<GridPosition> get effectivePoints {
    if (pathPoints.isNotEmpty) return pathPoints;
    // Default straight length-2 arrow if no points provided
    final tail = position.translate(-direction.dx, -direction.dy);
    return [tail, position];
  }

  ArrowEntity copyWith({
    String? id,
    GridPosition? position,
    ArrowDirection? direction,
    List<GridPosition>? pathPoints,
    ArrowState? state,
    double? animationProgress,
  }) {
    return ArrowEntity(
      id: id ?? this.id,
      position: position ?? this.position,
      direction: direction ?? this.direction,
      pathPoints: pathPoints ?? this.pathPoints,
      state: state ?? this.state,
      animationProgress: animationProgress ?? this.animationProgress,
    );
  }

  @override
  String toString() => 'Arrow(id: $id, head: $position, dir: ${direction.name}, state: ${state.name})';
}
