import 'arrow_direction.dart';
import 'grid_position.dart';

enum ArrowState {
  idle,
  hinted,
  colliding, // Error feedback (shake)
  escaping,  // Smoothly sliding off canvas
  cleared,   // Fully removed
}

/// Represents an arrow tile entity on the puzzle board
class ArrowEntity {
  final String id;
  final GridPosition position;
  final ArrowDirection direction;
  final ArrowState state;

  /// Animation progress from 0.0 to 1.0 (used during escaping or collision shake)
  final double animationProgress;

  const ArrowEntity({
    required this.id,
    required this.position,
    required this.direction,
    this.state = ArrowState.idle,
    this.animationProgress = 0.0,
  });

  ArrowEntity copyWith({
    String? id,
    GridPosition? position,
    ArrowDirection? direction,
    ArrowState? state,
    double? animationProgress,
  }) {
    return ArrowEntity(
      id: id ?? this.id,
      position: position ?? this.position,
      direction: direction ?? this.direction,
      state: state ?? this.state,
      animationProgress: animationProgress ?? this.animationProgress,
    );
  }

  @override
  String toString() => 'Arrow(id: $id, pos: $position, dir: ${direction.name}, state: ${state.name})';
}
