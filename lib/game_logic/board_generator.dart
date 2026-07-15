import 'dart:math';

import 'package:choco_blast_adventure/core/constants/tile_constants.dart';
import 'package:choco_blast_adventure/game_logic/board.dart';
import 'package:choco_blast_adventure/game_logic/match_detector.dart';
import 'package:choco_blast_adventure/models/tile_model.dart';
import 'package:choco_blast_adventure/models/level_model.dart';

/// Generates fresh random boards with no pre-existing matches and at least
/// one valid move available.
class BoardGenerator {
  final Random _random;

  BoardGenerator([int? seed]) : _random = Random(seed);

  /// Generate a [rows] x [cols] board with no initial matches.
  Board generate(int rows, int cols, {LevelModel? level}) {
    Board board;
    int attempts = 0;
    do {
      board = _randomBoard(rows, cols, level: level);
      attempts++;
    } while (MatchDetector.findMatches(board).hasMatches && attempts < 50);
    return board;
  }

  Board _randomBoard(int rows, int cols, {LevelModel? level}) {
    final board = BoardHelper.emptyBoard(rows, cols);
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        board[r][c] = _randomNonMatchingTile(board, r, c);
      }
    }
    
    // Inject Blockers based on level configuration
    if (level != null) {
      _injectBlockers(board, rows, cols, level);
    }
    
    return board;
  }
  
  void _injectBlockers(Board board, int rows, int cols, LevelModel level) {
    // Inject Ice (Jelly)
    if (level.goalType == GoalType.jelly) {
      int iceNeeded = level.goal.jellyCount ?? (rows * cols ~/ 4);
      int placed = 0;
      int attempts = 0;
      while (placed < iceNeeded && attempts < 200) {
        int r = _random.nextInt(rows);
        int c = _random.nextInt(cols);
        if (board[r][c].blocker == BlockerType.none) {
          board[r][c] = board[r][c].copyWith(blocker: BlockerType.ice, iceLayers: 1);
          placed++;
        }
        attempts++;
      }
    }
    
    // Inject Chocolate for levels > 10 randomly
    if (level.levelNumber > 10) {
      int chocoCount = (level.levelNumber - 10) ~/ 5; // e.g. 1 at 15, 2 at 20
      chocoCount = chocoCount.clamp(0, 4);
      int placed = 0;
      int attempts = 0;
      while (placed < chocoCount && attempts < 50) {
        int r = _random.nextInt(rows); // Usually at bottom
        int c = _random.nextInt(cols);
        if (board[r][c].blocker == BlockerType.none) {
          // Chocolate replaces the tile entirely (no color)
          board[r][c] = const Tile.empty().copyWith(blocker: BlockerType.chocolate);
          placed++;
        }
        attempts++;
      }
    }
  }

  /// Pick a random tile type that does NOT immediately form a 3-in-a-row with
  /// the two cells to the left or above.
  Tile _randomNonMatchingTile(Board board, int r, int c) {
    TileType type;
    int safety = 0;
    do {
      type = allTileTypes[_random.nextInt(tileTypeCount)];
      safety++;
    } while (_causesMatch(board, r, c, type) && safety < 50);
    return Tile(type: type);
  }

  bool _causesMatch(Board board, int r, int c, TileType type) {
    // Two to the left same?
    if (c >= 2 &&
        board[r][c - 1].type == type &&
        board[r][c - 2].type == type) {
      return true;
    }
    // Two above same?
    if (r >= 2 &&
        board[r - 1][c].type == type &&
        board[r - 2][c].type == type) {
      return true;
    }
    return false;
  }

  /// Create a new random tile (used for refills).
  Tile randomTile() => Tile(type: allTileTypes[_random.nextInt(tileTypeCount)]);
}
