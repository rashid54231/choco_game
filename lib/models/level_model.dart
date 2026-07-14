import 'package:choco_blast_adventure/core/constants/tile_constants.dart';

/// Level goal types as defined in the `levels` table.
enum GoalType {
  score,
  collect,
  jelly,
  ingredient,
}

/// A parsed goal target pulled from the `goal_target` jsonb column.
class GoalTarget {
  final GoalType type;

  /// For 'score' goals.
  final int? score;

  /// For 'collect' goals.
  final TileType? color;
  final int? count;

  /// For 'jelly' goals: number of jelly blockers to clear.
  final int? jellyCount;
//
  /// For 'ingredient' goals: number of ingredients to drop.
  final int? ingredientCount;

  const GoalTarget({
    required this.type,
    this.score,
    this.color,
    this.count,
    this.jellyCount,
    this.ingredientCount,
  });

  factory GoalTarget.fromJson(GoalType type, Map<String, dynamic> json) {
    switch (type) {
      case GoalType.score:
        return GoalTarget(type: type, score: json['score'] as int?);
      case GoalType.collect:
        return GoalTarget(
          type: type,
          color: json['color'] != null ? tileTypeFromLabel(json['color'] as String) : null,
          count: json['count'] as int?,
        );
      case GoalType.jelly:
        return GoalTarget(type: type, jellyCount: json['count'] as int?);
      case GoalType.ingredient:
        return GoalTarget(type: type, ingredientCount: json['count'] as int?);
    }
  }
}

/// A single level definition, mapped from the `levels` table.
class LevelModel {
  final int id;
  final int levelNumber;
  final int gridSize;
  final int? moveLimit;
  final int? timeLimitSeconds;
  final GoalType goalType;
  final GoalTarget goal;
  final Map<int, int> starThresholds; // star (1..3) -> score needed

  const LevelModel({
    required this.id,
    required this.levelNumber,
    required this.gridSize,
    required this.moveLimit,
    required this.timeLimitSeconds,
    required this.goalType,
    required this.goal,
    required this.starThresholds,
  });

  bool get hasTimer => timeLimitSeconds != null;
  bool get hasMoves => moveLimit != null;

  /// Default level for offline play (no Supabase required).
  /// Level 1-10: normal, 11-20: harder, 21-30: expert.
  factory LevelModel.level(int levelNumber) {
    // Gradual score increase: 1-10 easy, 11-20 medium, 21-30 hard, 31-50 expert
    final int scoreGoal;
    if (levelNumber <= 10) {
      // 2000 to 5500 (easy)
      scoreGoal = 1500 + levelNumber * 400;
    } else if (levelNumber <= 20) {
      // 6000 to 12500 (medium)
      scoreGoal = 5500 + (levelNumber - 10) * 700;
    } else if (levelNumber <= 30) {
      // 13000 to 25500 (hard)
      scoreGoal = 12500 + (levelNumber - 20) * 1300;
    } else {
      // 26000 to 57500 (expert)
      scoreGoal = 25500 + (levelNumber - 30) * 1600;
    }

    final goals = List.generate(50, (i) {
      final lvl = i + 1;
      final g = lvl <= 10
          ? 1500 + lvl * 400
          : lvl <= 20
              ? 5500 + (lvl - 10) * 700
              : lvl <= 30
                  ? 12500 + (lvl - 20) * 1300
                  : 25500 + (lvl - 30) * 1600;
      return GoalTarget(type: GoalType.score, score: g);
    });
    final idx = (levelNumber - 1).clamp(0, goals.length - 1);

    // Grid: 8x8 (1-15), 9x9 (16-30), 10x10 (31-50)
    final grid = levelNumber >= 31 ? 10 : (levelNumber >= 16 ? 9 : 8);

    // Moves: 30 at level 1, gradually decrease
    final moves = (30 - ((levelNumber - 1) * 0.45).floor()).clamp(15, 30);

    // Star thresholds
    final s1 = (scoreGoal * 0.5).round();
    final s2 = (scoreGoal * 0.8).round();
    final s3 = (scoreGoal * 1.2).round();

    return LevelModel(
      id: levelNumber,
      levelNumber: levelNumber,
      gridSize: grid,
      moveLimit: moves,
      timeLimitSeconds: null,
      goalType: GoalType.score,
      goal: goals[idx],
      starThresholds: {1: s1, 2: s2, 3: s3},
    );
  }

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    final goalType = GoalType.values.firstWhere(
      (e) => e.name == json['goal_type'],
      orElse: () => GoalType.score,
    );
    final goalJson = Map<String, dynamic>.from(json['goal_target'] as Map);
    final starJson = Map<String, dynamic>.from(json['star_thresholds'] as Map);
    final thresholds = starJson.map(
      (k, v) => MapEntry(int.parse(k), (v as num).toInt()),
    );

    return LevelModel(
      id: json['id'] as int,
      levelNumber: json['level_number'] as int,
      gridSize: json['grid_size'] as int? ?? 8,
      moveLimit: json['move_limit'] as int?,
      timeLimitSeconds: json['time_limit_seconds'] as int?,
      goalType: goalType,
      goal: GoalTarget.fromJson(goalType, goalJson),
      starThresholds: thresholds,
    );
  }

  /// Compute how many stars a final score earns (0..3).
  int starsForScore(int score) {
    int stars = 0;
    for (int s = 1; s <= 3; s++) {
      if (score >= (starThresholds[s] ?? 0)) stars = s;
    }
    return stars;
  }
}
