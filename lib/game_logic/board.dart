import 'package:choco_blast_adventure/models/tile_model.dart';

/// A 2D board of tiles. Indexed [row][col]. Rows increase downward.
typedef Board = List<List<Tile>>;

/// Helpers for building/manipulating a [Board].
class BoardHelper {
  /// Build an empty board (all [Tile.empty]) of the given size.
  static Board emptyBoard(int rows, int cols) {
    return List.generate(rows, (_) => List.generate(cols, (_) => const Tile.empty()));
  }

  static int rows(Board board) => board.length;
  static int cols(Board board) => board.isEmpty ? 0 : board.first.length;

  static bool inBounds(Board board, int r, int c) {
    return r >= 0 && r < rows(board) && c >= 0 && c < cols(board);
  }

  static Tile at(Board board, int r, int c) => board[r][c];

  /// Swap two cells in place and return a new board copy.
  static Board swap(Board board, int r1, int c1, int r2, int c2) {
    final copy = clone(board);
    final tmp = copy[r1][c1];
    copy[r1][c1] = copy[r2][c2];
    copy[r2][c2] = tmp;
    return copy;
  }

  static Board clone(Board board) {
    return board.map((row) => row.map((t) => t).toList()).toList();
  }

  static void printBoard(Board board) {
    for (final row in board) {
      // ignore: avoid_print
      print(row.map((t) => t.type?.name ?? '..').join(' '));
    }
  }
}
