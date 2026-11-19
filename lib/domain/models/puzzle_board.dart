import 'arrow_entity.dart';
import 'grid_position.dart';

/// Represents the puzzle board state containing active arrows and obstacles
class PuzzleBoard {
  final int width;
  final int height;
  final Map<GridPosition, ArrowEntity> _arrows;
  final Set<GridPosition> obstacles;

  PuzzleBoard({
    required this.width,
    required this.height,
    Map<GridPosition, ArrowEntity>? arrows,
    Set<GridPosition>? obstacles,
  })  : _arrows = arrows != null ? Map.from(arrows) : {},
        obstacles = obstacles != null ? Set.from(obstacles) : {};

  List<ArrowEntity> get activeArrows => _arrows.values.where((a) => a.state != ArrowState.cleared).toList();

  int get remainingCount => activeArrows.length;

  bool get isCleared => remainingCount == 0;

  ArrowEntity? getArrowAt(GridPosition pos) {
    final arrow = _arrows[pos];
    if (arrow != null && arrow.state != ArrowState.cleared) {
      return arrow;
    }
    return null;
  }

  ArrowEntity? getArrowById(String id) {
    for (final arrow in _arrows.values) {
      if (arrow.id == id && arrow.state != ArrowState.cleared) {
        return arrow;
      }
    }
    return null;
  }

  bool isObstacleAt(GridPosition pos) => obstacles.contains(pos);

  bool isCellOccupied(GridPosition pos) {
    return isObstacleAt(pos) || getArrowAt(pos) != null;
  }

  void addArrow(ArrowEntity arrow) {
    _arrows[arrow.position] = arrow;
  }

  void updateArrow(ArrowEntity arrow) {
    _arrows[arrow.position] = arrow;
  }

  void removeArrow(String id) {
    GridPosition? targetPos;
    for (final entry in _arrows.entries) {
      if (entry.value.id == id) {
        targetPos = entry.key;
        break;
      }
    }
    if (targetPos != null) {
      _arrows[targetPos] = _arrows[targetPos]!.copyWith(state: ArrowState.cleared);
    }
  }

  PuzzleBoard clone() {
    final clonedArrows = <GridPosition, ArrowEntity>{};
    for (final entry in _arrows.entries) {
      clonedArrows[entry.key] = entry.value.copyWith();
    }
    return PuzzleBoard(
      width: width,
      height: height,
      arrows: clonedArrows,
      obstacles: Set.from(obstacles),
    );
  }
}
