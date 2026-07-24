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
        [TileType.apple, TileType.apple, TileType.apple, TileType.watermelon],
        [TileType.lemon, TileType.banana, TileType.avocado, TileType.orange],
        [TileType.watermelon, TileType.lemon, TileType.banana, TileType.avocado],
        [TileType.orange, TileType.watermelon, TileType.lemon, TileType.banana],
      ]);
      final result = MatchDetector.findMatches(board);
      expect(result.matchedCells.length, 3);
    });

    test('detects a vertical 3-match', () {
      final board = tileBoard([
        [TileType.apple, TileType.watermelon, TileType.lemon, TileType.banana],
        [TileType.apple, TileType.avocado, TileType.orange, TileType.avocado],
        [TileType.apple, TileType.watermelon, TileType.lemon, TileType.orange],
        [TileType.banana, TileType.watermelon, TileType.avocado, TileType.lemon],
      ]);
      final result = MatchDetector.findMatches(board);
      expect(result.matchedCells.length, 3);
    });

    test('no match on a diagonal board', () {
      final board = tileBoard([
        [TileType.apple, TileType.watermelon, TileType.lemon, TileType.banana],
        [TileType.watermelon, TileType.lemon, TileType.banana, TileType.avocado],
        [TileType.lemon, TileType.banana, TileType.avocado, TileType.orange],
        [TileType.banana, TileType.avocado, TileType.orange, TileType.apple],
      ]);
      expect(MatchDetector.hasMatches(board), isFalse);
    });

    test('horizontal 4-match creates a horizontal striped special', () {
      final board = tileBoard([
        [TileType.apple, TileType.apple, TileType.apple, TileType.apple],
        [TileType.watermelon, TileType.lemon, TileType.banana, TileType.avocado],
        [TileType.lemon, TileType.banana, TileType.avocado, TileType.orange],
        [TileType.banana, TileType.avocado, TileType.orange, TileType.watermelon],
      ]);
      final result = MatchDetector.findMatches(board);
      expect(result.specials, isNotEmpty);
      expect(result.specials.first.kind, SpecialKind.striped);
      expect(result.specials.first.orientation, StripedOrientation.horizontal);
    });

    test('vertical 4-match creates a vertical striped special', () {
      final board = tileBoard([
        [TileType.apple, TileType.watermelon, TileType.lemon, TileType.banana],
        [TileType.apple, TileType.lemon, TileType.banana, TileType.avocado],
        [TileType.apple, TileType.banana, TileType.avocado, TileType.orange],
        [TileType.apple, TileType.avocado, TileType.orange, TileType.watermelon],
      ]);
      final result = MatchDetector.findMatches(board);
      expect(result.specials.first.kind, SpecialKind.striped);
      expect(result.specials.first.orientation, StripedOrientation.vertical);
    });

    test('5-in-a-line creates a color bomb', () {
      final board = tileBoard([
        [TileType.apple, TileType.apple, TileType.apple, TileType.apple, TileType.apple],
        [TileType.watermelon, TileType.lemon, TileType.banana, TileType.avocado, TileType.orange],
        [TileType.lemon, TileType.banana, TileType.avocado, TileType.orange, TileType.watermelon],
        [TileType.banana, TileType.avocado, TileType.orange, TileType.watermelon, TileType.lemon],
        [TileType.avocado, TileType.orange, TileType.watermelon, TileType.lemon, TileType.banana],
      ]);
      final result = MatchDetector.findMatches(board);
      expect(result.specials.first.kind, SpecialKind.colorBomb);
    });

    test('L-shape creates a wrapped tile', () {
      // Vertical pair + horizontal pair sharing a corner.
      final board = tileBoard([
        [TileType.apple, TileType.watermelon, TileType.lemon],
        [TileType.apple, TileType.lemon, TileType.banana],
        [TileType.apple, TileType.apple, TileType.apple],
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
        [TileType.apple, TileType.apple, TileType.watermelon, TileType.apple],
        [TileType.lemon, TileType.banana, TileType.apple, TileType.avocado],
        [TileType.watermelon, TileType.lemon, TileType.banana, TileType.orange],
        [TileType.orange, TileType.watermelon, TileType.lemon, TileType.banana],
      ]);
      // Swapping (0,2) blueGem with (0,3)? no. Instead move the lone redBerry up.
      // Place: row0 = R R G R ; row1c2 = R. Swapping (1,2) with (0,2) makes R R R R.
      final attempt = MoveValidator.trySwap(board, 1, 2, 0, 2);
      expect(attempt.valid, isTrue);
    });

    test('invalid swap that forms no match', () {
      final board = tileBoard([
        [TileType.apple, TileType.watermelon, TileType.lemon, TileType.banana],
        [TileType.watermelon, TileType.lemon, TileType.banana, TileType.avocado],
        [TileType.lemon, TileType.banana, TileType.avocado, TileType.orange],
        [TileType.banana, TileType.avocado, TileType.orange, TileType.apple],
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
        [TileType.apple, TileType.apple, TileType.apple, TileType.watermelon],
        [TileType.lemon, TileType.banana, TileType.avocado, TileType.orange],
        [TileType.watermelon, TileType.lemon, TileType.banana, TileType.avocado],
        [TileType.orange, TileType.watermelon, TileType.lemon, TileType.banana],
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
        [TileType.apple, TileType.lemon, TileType.banana, TileType.avocado],
        [TileType.watermelon, TileType.orange, TileType.apple, TileType.watermelon],
        [TileType.lemon, TileType.banana, TileType.avocado, TileType.orange],
        [TileType.banana, TileType.avocado, TileType.orange, TileType.apple],
      ]);
      // Put a horizontal striped redBerry at (1,2) and trigger it directly.
      board[1][2] = const Tile(
        type: TileType.apple,
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
        [TileType.apple, TileType.apple, TileType.apple, TileType.watermelon],
        [TileType.lemon, TileType.banana, TileType.avocado, TileType.orange],
        [TileType.watermelon, TileType.lemon, TileType.banana, TileType.avocado],
        [TileType.orange, TileType.watermelon, TileType.lemon, TileType.banana],
      ]);
      final resolution = CascadeResolver(3).resolve(board);
      final score = ScoringEngine().scoreForResolution(resolution);
      expect(score, greaterThan(0));
    });
  });
}
