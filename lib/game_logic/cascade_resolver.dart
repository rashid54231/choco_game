import 'dart:math';

import 'package:choco_blast_adventure/core/constants/tile_constants.dart';
import 'package:choco_blast_adventure/game_logic/board.dart';
import 'package:choco_blast_adventure/game_logic/match_detector.dart';
import 'package:choco_blast_adventure/models/tile_model.dart';

/// A description of a special tile being activated and the cells it hit.
class SpecialActivation {
  final Cell source;
  final SpecialKind kind;
  final Set<Cell> affected;
  SpecialActivation({required this.source, required this.kind, required this.affected});
}

/// One step of the cascade (a single clear + gravity + refill cycle).
class CascadeStep {
  final int cascadeIndex;
  final Board boardBefore;
  final Set<Cell> clearedCells;
  final List<SpecialActivation> activations;
  final Board boardAfter;

  /// Maps each falling tile's destination cell to how many rows it fell.
  final Map<Cell, int> fallDistances;

  /// Maps each new tile's cell to the row it came from (negative = above board).
  final Map<Cell, int> refillSources;

  const CascadeStep({
    required this.cascadeIndex,
    required this.boardBefore,
    required this.clearedCells,
    required this.activations,
    required this.boardAfter,
    this.fallDistances = const {},
    this.refillSources = const {},
  });

  int get clearedCount => clearedCells.length;
}

/// Full result of resolving a board to a stable state.
class CascadeResolution {
  final Board finalBoard;
  final List<CascadeStep> steps;
  final int totalCleared;
  final Set<TileType> clearedTypes;

  const CascadeResolution({
    required this.finalBoard,
    required this.steps,
    required this.totalCleared,
    required this.clearedTypes,
  });
}

/// Resolves matches repeatedly: clear -> activate specials -> gravity -> refill
/// until the board has no more matches.
class CascadeResolver {
  final Random _random;
  CascadeResolver([int? seed]) : _random = Random(seed);

  Tile _randomTile() => Tile(type: allTileTypes[_random.nextInt(tileTypeCount)]);

  /// Resolve the given board fully. [initialSpecials] lets the caller pre-place
  /// special activations from a player swap (e.g. a swapped-in special tile that
  /// should fire immediately).
  CascadeResolution resolve(Board board, {Set<Cell>? preActivated}) {
    var current = BoardHelper.clone(board);
    final steps = <CascadeStep>[];
    final clearedTypes = <TileType>{};
    int cascadeIndex = 0;

    while (true) {
      final match = MatchDetector.findMatches(current);
      final clearSet = <Cell>{...match.clearCells};

      // Seed activation set with any pre-activated specials (first iteration only).
      final activations = <SpecialActivation>[];
      final queue = <Cell>{};
      if (cascadeIndex == 0 && preActivated != null) {
        queue.addAll(preActivated);
      }

      // Expand: any special tile that is part of the cleared set activates.
      for (final cell in match.clearCells) {
        if (current[cell.r][cell.c].isSpecial) queue.add(cell);
      }

      _expandSpecials(current, queue, clearSet, activations);

      if (clearSet.isEmpty && (cascadeIndex > 0 || preActivated == null)) {
        break;
      }
      if (clearSet.isEmpty) break;

      // Record cleared types (for collect goals).
      for (final cell in clearSet) {
        final t = current[cell.r][cell.c].type;
        if (t != null) clearedTypes.add(t);
      }

      // Snapshot the board just before we mutate it (for animation).
      final boardBefore = BoardHelper.clone(current);

      // Place newly-created specials (these cells keep a tile, not emptied).
      final specialCells = {for (final s in match.specials) s.cell};

      // Remove cleared tiles (except those becoming new specials).
      for (final cell in clearSet) {
        if (specialCells.contains(cell)) continue;
        current[cell.r][cell.c] = const Tile.empty();
      }
      // Place new special tiles.
      for (final sc in match.specials) {
        current[sc.cell.r][sc.cell.c] = Tile(
          type: sc.type,
          special: sc.kind,
          stripedOrientation: sc.orientation,
        );
      }

      // Compute gravity fall distances.
      final fallMap = _computeFallDistances(current);

      final afterGravity = applyGravity(current);

      // Compute refill sources (which row each new tile came from).
      final refillMap = _computeRefillSources(afterGravity);

      final afterRefill = refill(afterGravity);

      steps.add(CascadeStep(
        cascadeIndex: cascadeIndex,
        boardBefore: boardBefore,
        clearedCells: clearSet,
        activations: activations,
        boardAfter: afterRefill,
        fallDistances: fallMap,
        refillSources: refillMap,
      ));

      current = afterRefill;
      cascadeIndex++;
    }

    int total = 0;
    for (final s in steps) total += s.clearedCount;

    return CascadeResolution(
      finalBoard: current,
      steps: steps,
      totalCleared: total,
      clearedTypes: clearedTypes,
    );
  }

  /// Expand special activations breadth-first, adding affected cells to [clearSet].
  void _expandSpecials(Board board, Set<Cell> queue, Set<Cell> clearSet,
      List<SpecialActivation> activations) {
    final seen = <Cell>{};
    while (queue.isNotEmpty) {
      final cell = queue.first;
      queue.remove(cell);
      if (seen.contains(cell)) continue;
      seen.add(cell);

      final tile = board[cell.r][cell.c];
      if (!tile.isSpecial) continue;

      final affected = <Cell>{};
      switch (tile.special) {
        case SpecialKind.striped:
          if (tile.stripedOrientation == StripedOrientation.horizontal) {
            for (int c = 0; c < BoardHelper.cols(board); c++) affected.add(Cell(cell.r, c));
          } else {
            for (int r = 0; r < BoardHelper.rows(board); r++) affected.add(Cell(r, cell.c));
          }
          break;
        case SpecialKind.wrapped:
          for (int dr = -1; dr <= 1; dr++) {
            for (int dc = -1; dc <= 1; dc++) {
              final r = cell.r + dr, c = cell.c + dc;
              if (BoardHelper.inBounds(board, r, c)) affected.add(Cell(r, c));
            }
          }
          break;
        case SpecialKind.colorBomb:
          // Activated as part of a match: clears all of its own type.
          final target = tile.type;
          for (int r = 0; r < BoardHelper.rows(board); r++) {
            for (int c = 0; c < BoardHelper.cols(board); c++) {
              if (board[r][c].type == target) affected.add(Cell(r, c));
            }
          }
          break;
        case SpecialKind.none:
          break;
      }

      activations.add(SpecialActivation(source: cell, kind: tile.special, affected: affected));
      for (final a in affected) {
        if (!clearSet.contains(a)) {
          clearSet.add(a);
          // chain into other specials caught in the blast
          if (board[a.r][a.c].isSpecial && !seen.contains(a)) queue.add(a);
        }
      }
    }
  }

  /// Compute how far each tile will fall during gravity.
  /// Returns a map of destination cell -> rows fallen.
  Map<Cell, int> _computeFallDistances(Board board) {
    final rows = BoardHelper.rows(board);
    final cols = BoardHelper.cols(board);
    final result = <Cell, int>{};

    for (int c = 0; c < cols; c++) {
      int emptyCount = 0;
      for (int r = rows - 1; r >= 0; r--) {
        if (board[r][c].isEmpty) {
          emptyCount++;
        } else if (emptyCount > 0) {
          result[Cell(r + emptyCount, c)] = emptyCount;
        }
      }
    }
    return result;
  }

  /// Compute where each new tile in the refilled board came from.
  /// Returns a map of cell -> source row (negative = above board).
  Map<Cell, int> _computeRefillSources(Board boardAfterGravity) {
    final rows = BoardHelper.rows(boardAfterGravity);
    final cols = BoardHelper.cols(boardAfterGravity);
    final result = <Cell, int>{};

    for (int c = 0; c < cols; c++) {
      int aboveBoard = 0;
      for (int r = 0; r < rows; r++) {
        if (boardAfterGravity[r][c].isEmpty) {
          aboveBoard++;
        }
      }
      // The empty cells (which will be refilled) are at the top.
      // They came from rows -aboveBoard .. -1 (above the board).
      int sourceRow = -aboveBoard;
      for (int r = 0; r < rows; r++) {
        if (boardAfterGravity[r][c].isEmpty) {
          result[Cell(r, c)] = sourceRow;
          sourceRow++;
        }
      }
    }
    return result;
  }

  /// Drop tiles down to fill empty cells, preserving order.
  Board applyGravity(Board board) {
    final rows = BoardHelper.rows(board);
    final cols = BoardHelper.cols(board);
    final out = BoardHelper.emptyBoard(rows, cols);
    for (int c = 0; c < cols; c++) {
      final columnTiles = <Tile>[];
      for (int r = rows - 1; r >= 0; r--) {
        if (!board[r][c].isEmpty) columnTiles.add(board[r][c]);
      }
      // columnTiles[0] is bottom-most existing tile.
      int writeR = rows - 1;
      for (final t in columnTiles) {
        out[writeR][c] = t;
        writeR--;
      }
    }
    return out;
  }

  /// Fill empty cells with new random tiles from the top.
  Board refill(Board board) {
    final rows = BoardHelper.rows(board);
    final cols = BoardHelper.cols(board);
    final out = BoardHelper.clone(board);
    for (int c = 0; c < cols; c++) {
      for (int r = 0; r < rows; r++) {
        if (out[r][c].isEmpty) out[r][c] = _randomTile();
      }
    }
    return out;
  }
}
