import 'package:choco_blast_adventure/core/constants/tile_constants.dart';
import 'package:choco_blast_adventure/game_logic/board.dart';
import 'package:choco_blast_adventure/models/tile_model.dart';

/// A cell coordinate on the board.
class Cell {
  final int r;
  final int c;
  const Cell(this.r, this.c);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Cell && other.r == r && other.c == c;
  @override
  int get hashCode => r * 1000 + c;

  @override
  String toString() => '($r,$c)';
}

/// Describes a special tile that should be created at a cell.
class SpecialCreation {
  final Cell cell;
  final SpecialKind kind;
  final StripedOrientation? orientation;
  final TileType type;

  const SpecialCreation({
    required this.cell,
    required this.kind,
    this.orientation,
    required this.type,
  });
}

/// Outcome of scanning a board for matches.
class MatchResult {
  /// Every cell that is part of any 3+ match.
  final Set<Cell> matchedCells;

  /// Special tiles that should be spawned (these cells are NOT cleared;
  /// instead they transform into the special tile).
  final List<SpecialCreation> specials;

  const MatchResult({required this.matchedCells, required this.specials});

  bool get hasMatches => matchedCells.isNotEmpty;

  /// Cells to actually clear, excluding those that become specials.
  Set<Cell> get clearCells {
    final specialCells = specials.map((s) => s.cell).toSet();
    return matchedCells.difference(specialCells);
  }
}

/// Detects horizontal/vertical runs of 3+ same-type tiles.
class MatchDetector {
  /// Find all current matches on the board.
  static MatchResult findMatches(Board board) {
    final rows = BoardHelper.rows(board);
    final cols = BoardHelper.cols(board);

    // Per-cell run lengths (horizontal and vertical).
    final hLen = List.generate(rows, (_) => List.filled(cols, 0));
    final vLen = List.generate(rows, (_) => List.filled(cols, 0));

    // Horizontal runs
    for (int r = 0; r < rows; r++) {
      int run = 1;
      for (int c = 1; c <= cols; c++) {
        final same = c < cols &&
            !board[r][c].isEmpty &&
            board[r][c].type != null &&
            board[r][c].type == board[r][c - 1].type;
        if (same) {
          run++;
        } else {
          if (run >= 3) {
            for (int k = c - run; k < c; k++) {
              hLen[r][k] = run;
            }
          }
          run = 1;
        }
      }
    }

    // Vertical runs
    for (int c = 0; c < cols; c++) {
      int run = 1;
      for (int r = 1; r <= rows; r++) {
        final same = r < rows &&
            !board[r][c].isEmpty &&
            board[r][c].type != null &&
            board[r][c].type == board[r - 1][c].type;
        if (same) {
          run++;
        } else {
          if (run >= 3) {
            for (int k = r - run; k < r; k++) {
              vLen[k][c] = run;
            }
          }
          run = 1;
        }
      }
    }

    final matched = <Cell>{};
    final specials = <Cell, SpecialCreation>{};

    // Collect matched cells
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (hLen[r][c] >= 3 || vLen[r][c] >= 3) {
          matched.add(Cell(r, c));
        }
      }
    }

    // Decide specials using connected components to ensure only ONE special per match group
    final visited = <Cell>{};
    for (final startCell in matched) {
      if (visited.contains(startCell)) continue;
      
      final type = board[startCell.r][startCell.c].type!;
      final queue = [startCell];
      final group = <Cell>[];
      
      while (queue.isNotEmpty) {
        final curr = queue.removeLast();
        if (visited.contains(curr)) continue;
        visited.add(curr);
        group.add(curr);
        
        final dr = const [0, 1, 0, -1];
        final dc = const [1, 0, -1, 0];
        for (int i = 0; i < 4; i++) {
          final nr = curr.r + dr[i];
          final nc = curr.c + dc[i];
          final nCell = Cell(nr, nc);
          if (matched.contains(nCell) && !visited.contains(nCell) && board[nr][nc].type == type) {
            queue.add(nCell);
          }
        }
      }
      
      // Analyze the connected group
      int maxH = 0;
      int maxV = 0;
      Cell? intersectCell;
      
      for (final cell in group) {
        final h = hLen[cell.r][cell.c];
        final v = vLen[cell.r][cell.c];
        if (h > maxH) maxH = h;
        if (v > maxV) maxV = v;
        if (h >= 3 && v >= 3) intersectCell = cell;
      }
      
      SpecialKind kind = SpecialKind.none;
      StripedOrientation? orientation;
      Cell spawnCell = group.first;
      
      if (maxH >= 5 || maxV >= 5) {
        kind = SpecialKind.colorBomb;
        spawnCell = group.firstWhere((c) => hLen[c.r][c.c] >= 5 || vLen[c.r][c.c] >= 5, orElse: () => group.first);
      } else if (intersectCell != null) {
        kind = SpecialKind.wrapped;
        spawnCell = intersectCell;
      } else if (maxH == 4) {
        kind = SpecialKind.striped;
        orientation = StripedOrientation.horizontal;
        spawnCell = group.firstWhere((c) => hLen[c.r][c.c] == 4, orElse: () => group.first);
      } else if (maxV == 4) {
        kind = SpecialKind.striped;
        orientation = StripedOrientation.vertical;
        spawnCell = group.firstWhere((c) => vLen[c.r][c.c] == 4, orElse: () => group.first);
      }
      
      if (kind != SpecialKind.none) {
        specials[spawnCell] = SpecialCreation(
          cell: spawnCell,
          kind: kind,
          orientation: orientation,
          type: type,
        );
      }
    }

    return MatchResult(matchedCells: matched, specials: specials.values.toList());
  }

  /// Quick boolean: does the board currently have any matches?
  static bool hasMatches(Board board) => findMatches(board).hasMatches;
}
