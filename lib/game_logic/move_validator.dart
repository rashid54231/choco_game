import 'package:choco_blast_adventure/game_logic/board.dart';
import 'package:choco_blast_adventure/game_logic/match_detector.dart';
import 'package:choco_blast_adventure/models/tile_model.dart';

/// Result of attempting a player swap.
class SwapAttempt {
  /// True if the swap produces at least one match (or activates a special).
  final bool valid;
  /// The board after the swap (before cascade resolution).
  final Board swappedBoard;
  final int r1, c1, r2, c2;

  const SwapAttempt({
    required this.valid,
    required this.swappedBoard,
    required this.r1,
    required this.c1,
    required this.r2,
    required this.c2,
  });
}

/// Validates moves and locates available moves on a board.
class MoveValidator {
  /// Try swapping (r1,c1) with adjacent (r2,c2). Returns whether it is valid.
  static SwapAttempt trySwap(Board board, int r1, int c1, int r2, int c2) {
    final adjacent = (r1 == r2 && (c1 - c2).abs() == 1) ||
        (c1 == c2 && (r1 - r2).abs() == 1);
    if (!adjacent || !BoardHelper.inBounds(board, r1, c1) || !BoardHelper.inBounds(board, r2, c2)) {
      return SwapAttempt(
        valid: false,
        swappedBoard: board,
        r1: r1, c1: c1, r2: r2, c2: c2,
      );
    }

    final swapped = BoardHelper.swap(board, r1, c1, r2, c2);

    // Special-case: swapping a color bomb with anything is always valid.
    final t1 = board[r1][c1];
    final t2 = board[r2][c2];
    if (t1.special == SpecialKind.colorBomb || t2.special == SpecialKind.colorBomb) {
      return SwapAttempt(valid: true, swappedBoard: swapped, r1: r1, c1: c1, r2: r2, c2: c2);
    }

    // Any other special swapped with a special is valid (combined effect).
    if (t1.isSpecial && t2.isSpecial) {
      return SwapAttempt(valid: true, swappedBoard: swapped, r1: r1, c1: c1, r2: r2, c2: c2);
    }

    final hasMatch = MatchDetector.hasMatches(swapped);
    return SwapAttempt(
      valid: hasMatch,
      swappedBoard: swapped,
      r1: r1, c1: c1, r2: r2, c2: c2,
    );
  }

  /// Returns true if at least one valid move exists on the board.
  static bool hasAnyValidMove(Board board) => findAnyValidMove(board) != null;

  /// Returns the first valid move found, or null if the board is stuck.
  static ({int r1, int c1, int r2, int c2})? findAnyValidMove(Board board) {
    final rows = BoardHelper.rows(board);
    final cols = BoardHelper.cols(board);
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        // only test right and down to avoid duplicates
        if (c + 1 < cols) {
          if (trySwap(board, r, c, r, c + 1).valid) {
            return (r1: r, c1: c, r2: r, c2: c + 1);
          }
        }
        if (r + 1 < rows) {
          if (trySwap(board, r, c, r + 1, c).valid) {
            return (r1: r, c1: c, r2: r + 1, c2: c);
          }
        }
      }
    }
    return null;
  }
}
