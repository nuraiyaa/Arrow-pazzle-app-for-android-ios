import '../models/arrow_entity.dart';
import '../models/puzzle_board.dart';
import 'raycast_collision_detector.dart';

class SolverResult {
  final bool isSolvable;
  final List<String> solutionOrder; // Arrow IDs in order of escape
  final int totalDeadEndsFound;
  final double averageBranchingFactor;

  const SolverResult({
    required this.isSolvable,
    required this.solutionOrder,
    this.totalDeadEndsFound = 0,
    this.averageBranchingFactor = 1.0,
  });
}

/// Automated Solver & Solvability Verifier
class PuzzleSolver {
  PuzzleSolver._();

  /// Returns all arrows currently capable of escaping immediately
  static List<ArrowEntity> getImmediatelyEscapableArrows(PuzzleBoard board) {
    final escapable = <ArrowEntity>[];
    for (final arrow in board.activeArrows) {
      final result = RaycastCollisionDetector.validatePath(board, arrow);
      if (result.isClear) {
        escapable.add(arrow);
      }
    }
    return escapable;
  }

  /// Solves the puzzle using depth-first search with backtracking
  static SolverResult solve(PuzzleBoard initialBoard, {int maxDepth = 100}) {
    final solution = <String>[];
    int deadEnds = 0;
    int totalBranches = 0;
    int decisionSteps = 0;

    bool dfs(PuzzleBoard currentBoard, int depth) {
      if (currentBoard.isCleared) {
        return true;
      }
      if (depth >= maxDepth) return false;

      final escapable = getImmediatelyEscapableArrows(currentBoard);
      totalBranches += escapable.length;
      decisionSteps++;

      if (escapable.isEmpty) {
        deadEnds++;
        return false;
      }

      for (final arrow in escapable) {
        solution.add(arrow.id);
        final nextBoard = currentBoard.clone();
        nextBoard.removeArrow(arrow.id);

        if (dfs(nextBoard, depth + 1)) {
          return true;
        }

        // Backtrack
        solution.removeLast();
      }

      return false;
    }

    final isSolvable = dfs(initialBoard.clone(), 0);
    final avgBranching = decisionSteps > 0 ? (totalBranches / decisionSteps) : 1.0;

    return SolverResult(
      isSolvable: isSolvable,
      solutionOrder: isSolvable ? List.unmodifiable(solution) : const [],
      totalDeadEndsFound: deadEnds,
      averageBranchingFactor: avgBranching,
    );
  }
}
