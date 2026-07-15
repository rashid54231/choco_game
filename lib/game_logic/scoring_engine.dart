import 'package:choco_blast_adventure/core/constants/grid_config.dart';
import 'package:choco_blast_adventure/game_logic/cascade_resolver.dart';

/// Computes score from a resolved cascade, applying a combo multiplier that
/// grows slowly with each chained cascade step.
class ScoringEngine {
  final int baseTileScore;

  const ScoringEngine({this.baseTileScore = GameConstants.baseTileScore});

  /// Score for a single cascade resolution.
  int scoreForResolution(CascadeResolution resolution) {
    int total = 0;
    for (final step in resolution.steps) {
      // Combo multiplier grows: x1, x1.5, x2, x2.5, x3
      final rawMultiplier = 1.0 + step.cascadeIndex * 0.5;
      final multiplier = rawMultiplier.clamp(1.0, GameConstants.maxComboMultiplier.toDouble());
      final base = step.clearedCount * baseTileScore;
      total += (base * multiplier).round();
    }
    return total;
  }
//
  /// Score for a single special activation (extra points for juicy plays).
  int scoreForActivations(CascadeResolution resolution) {
    int total = 0;
    for (final step in resolution.steps) {
      for (final act in step.activations) {
        total += act.affected.length * 2;
      }
    }
    return total;
  }
}
//now
