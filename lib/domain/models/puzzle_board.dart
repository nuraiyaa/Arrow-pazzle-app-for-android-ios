import 'arrow_entity.dart';
import 'grid_position.dart';

/// Represents the puzzle board state containing active arrows and obstacles
class PuzzleBoard {
  final int width;
  final int height;
  final Map<String, ArrowEntity> _arrows;
  final Set<GridPosition> obstacles;

  PuzzleBoard({
    required this.width,
    required this.height,
    Map<dynamic, ArrowEntity>? arrows,
    Set<GridPosition>? obstacles,
  })  : _arrows = {},
        obstacles = obstacles != null ? Set.from(obstacles) : {} {
    if (arrows != null) {
      for (final entry in arrows.entries) {
        _arrows[entry.value.id] = entry.value;
      }
    }
  }

  List<ArrowEntity> get activeArrows =>
      _arrows.values.where((a) => a.state != ArrowState.cleared).toList();

  int get remainingCount => activeArrows.length;

  bool get isCleared => remainingCount == 0;

  ArrowEntity? getArrowAt(GridPosition pos) {
    for (final arrow in activeArrows) {
      if (arrow.occupiedPositions.contains(pos)) {
        return arrow;
      }
    }
    return null;
  }

  ArrowEntity? getArrowById(String id) {
    final arrow = _arrows[id];
    if (arrow != null && arrow.state != ArrowState.cleared) {
      return arrow;
    }
    return null;
  }

  bool isObstacleAt(GridPosition pos) => obstacles.contains(pos);

  bool isCellOccupied(GridPosition pos) {
    return isObstacleAt(pos) || getArrowAt(pos) != null;
  }

  void addArrow(ArrowEntity arrow) {
    _arrows[arrow.id] = arrow;
  }

  void updateArrow(ArrowEntity arrow) {
    _arrows[arrow.id] = arrow;
  }

  void removeArrow(String id) {
    final arrow = _arrows[id];
    if (arrow != null) {
      _arrows[id] = arrow.copyWith(state: ArrowState.cleared);
    }
  }

  PuzzleBoard clone() {
    final clonedArrows = <String, ArrowEntity>{};
    for (final entry in _arrows.entries) {
      clonedArrows[entry.key] = entry.value;
    }
    return PuzzleBoard(
      width: width,
      height: height,
      arrows: clonedArrows,
      obstacles: Set.from(obstacles),
    );
  }
}
