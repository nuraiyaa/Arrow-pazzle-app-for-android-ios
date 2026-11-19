import 'dart:collection';
import '../models/arrow_entity.dart';
import '../models/puzzle_board.dart';
import 'puzzle_solver.dart';
import 'raycast_collision_detector.dart';

enum TapOutcome {
  arrowEscaped,
  collisionError,
  levelWon,
  outOfHearts,
}

class TapResult {
  final TapOutcome outcome;
  final ArrowEntity? targetArrow;
  final ArrowEntity? blockingArrow;
  final int remainingHearts;
  final int remainingArrows;

  const TapResult({
    required this.outcome,
    this.targetArrow,
    this.blockingArrow,
    required this.remainingHearts,
    required this.remainingArrows,
  });
}

/// Pure Dart Game Session Controller (UI-Agnostic, 100% Testable)
class GameSession {
  final PuzzleBoard board;
  int hearts;
  final int maxHearts;
  int movesCount;
  int hintsUsed;
  final Queue<ArrowEntity> _undoStack = Queue<ArrowEntity>();

  String? lastCollidingArrowId;
  String? activeHintArrowId;

  GameSession({
    required this.board,
    this.hearts = 3,
    this.maxHearts = 3,
  })  : movesCount = 0,
        hintsUsed = 0;

  bool get isWon => board.isCleared;
  bool get isGameOver => hearts <= 0 && !isWon;
  bool get canUndo => _undoStack.isNotEmpty;

  TapResult tapArrow(String arrowId) {
    if (isGameOver || isWon) {
      return TapResult(
        outcome: isWon ? TapOutcome.levelWon : TapOutcome.outOfHearts,
        remainingHearts: hearts,
        remainingArrows: board.remainingCount,
      );
    }

    final arrow = board.getArrowById(arrowId);
    if (arrow == null) {
      return TapResult(
        outcome: TapOutcome.collisionError,
        remainingHearts: hearts,
        remainingArrows: board.remainingCount,
      );
    }

    movesCount++;
    activeHintArrowId = null; // Clear active hint on move

    // Raycast validation
    final collision = RaycastCollisionDetector.validatePath(board, arrow);

    if (collision.isClear) {
      // 1. Success: Arrow escapes freely
      _undoStack.addLast(arrow);
      board.removeArrow(arrowId);
      lastCollidingArrowId = null;

      if (board.isCleared) {
        return TapResult(
          outcome: TapOutcome.levelWon,
          targetArrow: arrow,
          remainingHearts: hearts,
          remainingArrows: 0,
        );
      }

      return TapResult(
        outcome: TapOutcome.arrowEscaped,
        targetArrow: arrow,
        remainingHearts: hearts,
        remainingArrows: board.remainingCount,
      );
    } else {
      // 2. Collision: Arrow blocked by another arrow or obstacle
      hearts--;
      lastCollidingArrowId = arrowId;

      if (hearts <= 0) {
        return TapResult(
          outcome: TapOutcome.outOfHearts,
          targetArrow: arrow,
          blockingArrow: collision.blockingArrow,
          remainingHearts: 0,
          remainingArrows: board.remainingCount,
        );
      }

      return TapResult(
        outcome: TapOutcome.collisionError,
        targetArrow: arrow,
        blockingArrow: collision.blockingArrow,
        remainingHearts: hearts,
        remainingArrows: board.remainingCount,
      );
    }
  }

  bool undo() {
    if (!canUndo) return false;
    final lastCleared = _undoStack.removeLast();
    board.addArrow(lastCleared.copyWith(state: ArrowState.idle));
    return true;
  }

  String? requestHint() {
    final escapable = PuzzleSolver.getImmediatelyEscapableArrows(board);
    if (escapable.isNotEmpty) {
      activeHintArrowId = escapable.first.id;
      hintsUsed++;
      return activeHintArrowId;
    }
    return null;
  }
}
