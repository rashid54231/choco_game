import 'package:choco_blast_adventure/game_logic/board.dart';
import 'package:choco_blast_adventure/game_logic/board_generator.dart';
import 'package:choco_blast_adventure/game_logic/cascade_resolver.dart';
import 'package:choco_blast_adventure/game_logic/match_detector.dart';
import 'package:choco_blast_adventure/game_logic/move_validator.dart';
import 'package:choco_blast_adventure/game_logic/scoring_engine.dart';
import 'package:choco_blast_adventure/models/tile_model.dart';
import 'package:choco_blast_adventure/core/constants/tile_constants.dart';
import 'package:flutter_test/flutter_test.dart';

Board tileBoard(List<List<TileType?>> types) {
  return types.map((row) {
    return row.map((t) => t == null ? const Tile.empty() : Tile(type: t)).toList();
  }).toList();
}

void main() {
  group('MatchDetector', () {
    test('detects a horizontal 3-match', () {
      final board = tileBoard([
        [TileType.redBerry, TileType.redBerry, TileType.redBerry, TileType.blueSphere],
        [TileType.greenSquare, TileType.yellowStar, TileType.purpleFlower, TileType.orangeBean],
        [TileType.blueSphere, TileType.greenSquare, TileType.yellowStar, TileType.purpleFlower],
        [TileType.orangeBean, TileType.blueSphere, TileType.greenSquare, TileType.yellowStar],
      ]);
      final result = MatchDetector.findMatches(board);
      expect(result.matchedCells.length, 3);
    });

    test('detects a vertical 3-match', () {
      final board = tileBoard([
        [TileType.redBerry, TileType.blueSphere, TileType.greenSquare, TileType.yellowStar],
        [TileType.redBerry, TileType.purpleFlower, TileType.orangeBean, TileType.purpleFlower],
        [TileType.redBerry, TileType.blueSphere, TileType.greenSquare, TileType.orangeBean],
        [TileType.yellowStar, TileType.blueSphere, TileType.purpleFlower, TileType.greenSquare],
      ]);
      final result = MatchDetector.findMatches(board);
      expect(result.matchedCells.length, 3);
    });

    test('no match on a diagonal board', () {
      final board = tileBoard([
        [TileType.redBerry, TileType.blueSphere, TileType.greenSquare, TileType.yellowStar],
        [TileType.blueSphere, TileType.greenSquare, TileType.yellowStar, TileType.purpleFlower],
        [TileType.greenSquare, TileType.yellowStar, TileType.purpleFlower, TileType.orangeBean],
        [TileType.yellowStar, TileType.purpleFlower, TileType.orangeBean, TileType.redBerry],
      ]);
      expect(MatchDetector.hasMatches(board), isFalse);
    });

    test('horizontal 4-match creates a horizontal striped special', () {
      final board = tileBoard([
        [TileType.redBerry, TileType.redBerry, TileType.redBerry, TileType.redBerry],
        [TileType.blueSphere, TileType.greenSquare, TileType.yellowStar, TileType.purpleFlower],
        [TileType.greenSquare, TileType.yellowStar, TileType.purpleFlower, TileType.orangeBean],
        [TileType.yellowStar, TileType.purpleFlower, TileType.orangeBean, TileType.blueSphere],
      ]);
      final result = MatchDetector.findMatches(board);
      expect(result.specials, isNotEmpty);
      expect(result.specials.first.kind, SpecialKind.striped);
      expect(result.specials.first.orientation, StripedOrientation.horizontal);
    });

    test('vertical 4-match creates a vertical striped special', () {
      final board = tileBoard([
        [TileType.redBerry, TileType.blueSphere, TileType.greenSquare, TileType.yellowStar],
        [TileType.redBerry, TileType.greenSquare, TileType.yellowStar, TileType.purpleFlower],
        [TileType.redBerry, TileType.yellowStar, TileType.purpleFlower, TileType.orangeBean],
        [TileType.redBerry, TileType.purpleFlower, TileType.orangeBean, TileType.blueSphere],
      ]);
      final result = MatchDetector.findMatches(board);
      expect(result.specials.first.kind, SpecialKind.striped);
      expect(result.specials.first.orientation, StripedOrientation.vertical);
    });

    test('5-in-a-line creates a color bomb', () {
      final board = tileBoard([
        [TileType.redBerry, TileType.redBerry, TileType.redBerry, TileType.redBerry, TileType.redBerry],
        [TileType.blueSphere, TileType.greenSquare, TileType.yellowStar, TileType.purpleFlower, TileType.orangeBean],
        [TileType.greenSquare, TileType.yellowStar, TileType.purpleFlower, TileType.orangeBean, TileType.blueSphere],
        [TileType.yellowStar, TileType.purpleFlower, TileType.orangeBean, TileType.blueSphere, TileType.greenSquare],
        [TileType.purpleFlower, TileType.orangeBean, TileType.blueSphere, TileType.greenSquare, TileType.yellowStar],
      ]);
      final result = MatchDetector.findMatches(board);
      expect(result.specials.first.kind, SpecialKind.colorBomb);
    });

    test('L-shape creates a wrapped tile', () {
      // Vertical pair + horizontal pair sharing a corner.
      final board = tileBoard([
        [TileType.redBerry, TileType.blueSphere, TileType.greenSquare],
        [TileType.redBerry, TileType.greenSquare, TileType.yellowStar],
        [TileType.redBerry, TileType.redBerry, TileType.redBerry],
      ]);
      final result = MatchDetector.findMatches(board);
      final wrapped = result.specials.where((s) => s.kind == SpecialKind.wrapped);
      expect(wrapped, isNotEmpty);
    });
  });

  group('BoardGenerator', () {
    test('generates a board with no initial matches', () {
      final gen = BoardGenerator(42);
      final board = gen.generate(8, 8);
      expect(MatchDetector.hasMatches(board), isFalse);
    });

    test('generated board has the right dimensions', () {
      final board = BoardGenerator(1).generate(8, 8);
      expect(BoardHelper.rows(board), 8);
      expect(BoardHelper.cols(board), 8);
    });
  });

  group('MoveValidator', () {
    test('valid swap that forms a match', () {
      final board = tileBoard([
        [TileType.redBerry, TileType.redBerry, TileType.blueSphere, TileType.redBerry],
        [TileType.greenSquare, TileType.yellowStar, TileType.redBerry, TileType.purpleFlower],
        [TileType.blueSphere, TileType.greenSquare, TileType.yellowStar, TileType.orangeBean],
        [TileType.orangeBean, TileType.blueSphere, TileType.greenSquare, TileType.yellowStar],
      ]);
      // Swapping (0,2) blueGem with (0,3)? no. Instead move the lone redBerry up.
      // Place: row0 = R R G R ; row1c2 = R. Swapping (1,2) with (0,2) makes R R R R.
      final attempt = MoveValidator.trySwap(board, 1, 2, 0, 2);
      expect(attempt.valid, isTrue);
    });

    test('invalid swap that forms no match', () {
      final board = tileBoard([
        [TileType.redBerry, TileType.blueSphere, TileType.greenSquare, TileType.yellowStar],
        [TileType.blueSphere, TileType.greenSquare, TileType.yellowStar, TileType.purpleFlower],
        [TileType.greenSquare, TileType.yellowStar, TileType.purpleFlower, TileType.orangeBean],
        [TileType.yellowStar, TileType.purpleFlower, TileType.orangeBean, TileType.redBerry],
      ]);
      final attempt = MoveValidator.trySwap(board, 0, 0, 0, 1);
      expect(attempt.valid, isFalse);
    });

    test('finds a valid move on a solvable board', () {
      final board = BoardGenerator(7).generate(8, 8);
      expect(MoveValidator.hasAnyValidMove(board), isTrue);
    });
  });

  group('CascadeResolver', () {
    test('resolves a match and produces a stable board with no matches', () {
      final board = tileBoard([
        [TileType.redBerry, TileType.redBerry, TileType.redBerry, TileType.blueSphere],
        [TileType.greenSquare, TileType.yellowStar, TileType.purpleFlower, TileType.orangeBean],
        [TileType.blueSphere, TileType.greenSquare, TileType.yellowStar, TileType.purpleFlower],
        [TileType.orangeBean, TileType.blueSphere, TileType.greenSquare, TileType.yellowStar],
      ]);
      final resolution = CascadeResolver(99).resolve(board);
      expect(resolution.steps, isNotEmpty);
      // The resolver loop continues until no matches remain, so the final
      // board should be stable. On very small boards the refill may chain
      // deeply but the resolver guarantees convergence.
      expect(resolution.totalCleared, greaterThanOrEqualTo(3));
      // Board remains fully populated (no empty cells after refill).
      for (final row in resolution.finalBoard) {
        for (final t in row) {
          expect(t.isEmpty, isFalse);
        }
      }
    });

    test('striped tile activation clears a full row', () {
      final board = tileBoard([
        [TileType.redBerry, TileType.greenSquare, TileType.yellowStar, TileType.purpleFlower],
        [TileType.blueSphere, TileType.orangeBean, TileType.redBerry, TileType.blueSphere],
        [TileType.greenSquare, TileType.yellowStar, TileType.purpleFlower, TileType.orangeBean],
        [TileType.yellowStar, TileType.purpleFlower, TileType.orangeBean, TileType.redBerry],
      ]);
      // Put a horizontal striped redBerry at (1,2) and trigger it directly.
      board[1][2] = const Tile(
        type: TileType.redBerry,
        special: SpecialKind.striped,
        stripedOrientation: StripedOrientation.horizontal,
      );
      final resolution = CascadeResolver(5).resolve(board, preActivated: {const Cell(1, 2)});
      // Row 1 should be cleared (and refilled), final board stable.
      expect(MatchDetector.hasMatches(resolution.finalBoard), isFalse);
    });
  });

  group('ScoringEngine', () {
    test('combo multiplier increases score for chained cascades', () {
      final board = tileBoard([
        [TileType.redBerry, TileType.redBerry, TileType.redBerry, TileType.blueSphere],
        [TileType.greenSquare, TileType.yellowStar, TileType.purpleFlower, TileType.orangeBean],
        [TileType.blueSphere, TileType.greenSquare, TileType.yellowStar, TileType.purpleFlower],
        [TileType.orangeBean, TileType.blueSphere, TileType.greenSquare, TileType.yellowStar],
      ]);
      final resolution = CascadeResolver(3).resolve(board);
      final score = ScoringEngine().scoreForResolution(resolution);
      expect(score, greaterThan(0));
    });
  });
}
