import 'dart:collection';
import '../models/arrow_entity.dart';
import '../models/level_model.dart';
import '../models/puzzle_board.dart';
import 'puzzle_solver.dart';
import 'raycast_collision_detector.dart';

enum TapOutcome {
  arrowEscaped,
  collisionError,
  levelWon,
  outOfHearts,
  outOfTime,
}

class TapResult {
  final TapOutcome outcome;
  final ArrowEntity? targetArrow;
  final ArrowEntity? blockingArrow;
  final int remainingHearts;
  final int remainingArrows;
  final int scoreGained;
  final int currentCombo;

  const TapResult({
    required this.outcome,
    this.targetArrow,
    this.blockingArrow,
    required this.remainingHearts,
    required this.remainingArrows,
    this.scoreGained = 0,
    this.currentCombo = 0,
  });
}

/// Unified Pure Dart Game Session Controller supporting Relaxed, Challenge, and Timed Modes
class GameSession {
  final PuzzleBoard board;
  final LevelConfig config;
  int hearts;
  final int maxHearts;
  int movesCount;
  int hintsUsed;
  int score;
  int comboStreak;
  double remainingTimeSeconds;

  final Queue<ArrowEntity> _undoStack = Queue<ArrowEntity>();
  String? lastCollidingArrowId;
  String? activeHintArrowId;

  GameSession({
    required this.board,
    required this.config,
    this.hearts = 3,
    this.maxHearts = 3,
  })  : movesCount = 0,
        hintsUsed = 0,
        score = 0,
        comboStreak = 0,
        remainingTimeSeconds = (config.timeLimitSeconds ?? 0).toDouble();

  bool get isTimedMode => config.timeLimitSeconds != null;
  bool get isWon => board.isCleared;
  bool get isOutOfHearts => hearts <= 0 && !isWon;
  bool get isOutOfTime => isTimedMode && remainingTimeSeconds <= 0 && !isWon;
  bool get isGameOver => (isOutOfHearts || isOutOfTime) && !isWon;
  bool get canUndo => _undoStack.isNotEmpty;

  /// Timer tick for Timed Mode (called each frame or second)
  bool tick(double deltaSeconds) {
    if (!isTimedMode || isGameOver || isWon) return false;
    remainingTimeSeconds -= deltaSeconds;
    if (remainingTimeSeconds <= 0) {
      remainingTimeSeconds = 0;
      return true; // Just ran out of time
    }
    return false;
  }

  TapResult tapArrow(String arrowId) {
    if (isGameOver || isWon) {
      return TapResult(
        outcome: isWon
            ? TapOutcome.levelWon
            : isOutOfTime
                ? TapOutcome.outOfTime
                : TapOutcome.outOfHearts,
        remainingHearts: hearts,
        remainingArrows: board.remainingCount,
        scoreGained: 0,
        currentCombo: comboStreak,
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
    activeHintArrowId = null;

    // Raycast validation
    final collision = RaycastCollisionDetector.validatePath(board, arrow);

    if (collision.isClear) {
      // 1. Success: Arrow escapes freely
      _undoStack.addLast(arrow);
      board.removeArrow(arrowId);
      lastCollidingArrowId = null;

      // Update Combo Streak & Scoring
      comboStreak++;
      final comboMultiplier = (1 + (comboStreak - 1) * 0.2).clamp(1.0, 3.0);
      final points = (100 * comboMultiplier).toInt();
      score += points;

      // In timed mode, add bonus time (+1.5 seconds per clear)
      if (isTimedMode) {
        remainingTimeSeconds = (remainingTimeSeconds + 1.5).clamp(0.0, 99.0);
      }

      if (board.isCleared) {
        // Bonus for remaining hearts and moves
        final completionBonus = hearts * 150 + (config.targetMoves >= movesCount ? 300 : 100);
        score += completionBonus;

        return TapResult(
          outcome: TapOutcome.levelWon,
          targetArrow: arrow,
          remainingHearts: hearts,
          remainingArrows: 0,
          scoreGained: points + completionBonus,
          currentCombo: comboStreak,
        );
      }

      return TapResult(
        outcome: TapOutcome.arrowEscaped,
        targetArrow: arrow,
        remainingHearts: hearts,
        remainingArrows: board.remainingCount,
        scoreGained: points,
        currentCombo: comboStreak,
      );
    } else {
      // 2. Collision Error
      comboStreak = 0; // Reset combo
      if (!isTimedMode) {
        hearts--;
      } else {
        // In Timed mode, collision penalizes 3 seconds instead of heart loss
        remainingTimeSeconds = (remainingTimeSeconds - 3.0).clamp(0.0, 99.0);
      }
      lastCollidingArrowId = arrowId;

      if (!isTimedMode && hearts <= 0) {
        return TapResult(
          outcome: TapOutcome.outOfHearts,
          targetArrow: arrow,
          blockingArrow: collision.blockingArrow,
          remainingHearts: 0,
          remainingArrows: board.remainingCount,
        );
      } else if (isTimedMode && remainingTimeSeconds <= 0) {
        return TapResult(
          outcome: TapOutcome.outOfTime,
          targetArrow: arrow,
          blockingArrow: collision.blockingArrow,
          remainingHearts: hearts,
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
    comboStreak = 0;
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

  /// Calculates stars earned (1 to 3 stars)
  int calculateStars() {
    if (!isWon) return 0;
    if (isTimedMode) {
      if (score >= 2500) return 3;
      if (score >= 1500) return 2;
      return 1;
    }

    if (hearts == maxHearts && movesCount <= config.targetMoves) return 3;
    if (hearts >= 2) return 2;
    return 1;
  }
}
