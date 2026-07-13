import 'package:choco_blast_adventure/core/constants/grid_config.dart';

/// User profile, mapped from the `profiles` table (extends Supabase auth.users).
class UserProfile {
  final String id;
  final String username;
  final String? avatarUrl;
  final int totalScore;
  final int currentLevel;
  final int lives;
  final DateTime lastLifeRegen;
  final bool isPremium;
  final DateTime createdAt;
  final int coins;
  final int boosterExtraMoves;
  final int boosterColorBomb;
  final int boosterHammer;
  final int boosterShuffle;

  const UserProfile({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.totalScore,
    required this.currentLevel,
    required this.lives,
    required this.lastLifeRegen,
    required this.isPremium,
    required this.createdAt,
    required this.coins,
    required this.boosterExtraMoves,
    required this.boosterColorBomb,
    required this.boosterHammer,
    required this.boosterShuffle,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      totalScore: json['total_score'] as int? ?? 0,
      currentLevel: json['current_level'] as int? ?? 1,
      lives: json['lives'] as int? ?? GameConstantsPlaceholder.startingLives,
      lastLifeRegen: DateTime.parse(json['last_life_regen'] as String? ??
          DateTime.now().toIso8601String()),
      isPremium: json['is_premium'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String? ??
          DateTime.now().toIso8601String()),
      coins: json['coins'] as int? ?? 1000,
      boosterExtraMoves: json['booster_extra_moves'] as int? ?? 3,
      boosterColorBomb: json['booster_color_bomb'] as int? ?? 2,
      boosterHammer: json['booster_hammer'] as int? ?? 2,
      boosterShuffle: json['booster_shuffle'] as int? ?? 3,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'avatar_url': avatarUrl,
        'total_score': totalScore,
        'current_level': currentLevel,
        'lives': lives,
        'last_life_regen': lastLifeRegen.toIso8601String(),
        'is_premium': isPremium,
        'coins': coins,
        'booster_extra_moves': boosterExtraMoves,
        'booster_color_bomb': boosterColorBomb,
        'booster_hammer': boosterHammer,
        'booster_shuffle': boosterShuffle,
      };

  UserProfile copyWith({
    String? username,
    String? avatarUrl,
    int? totalScore,
    int? currentLevel,
    int? lives,
    DateTime? lastLifeRegen,
    bool? isPremium,
    int? coins,
    int? boosterExtraMoves,
    int? boosterColorBomb,
    int? boosterHammer,
    int? boosterShuffle,
  }) {
    return UserProfile(
      id: id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalScore: totalScore ?? this.totalScore,
      currentLevel: currentLevel ?? this.currentLevel,
      lives: lives ?? this.lives,
      lastLifeRegen: lastLifeRegen ?? this.lastLifeRegen,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt,
      coins: coins ?? this.coins,
      boosterExtraMoves: boosterExtraMoves ?? this.boosterExtraMoves,
      boosterColorBomb: boosterColorBomb ?? this.boosterColorBomb,
      boosterHammer: boosterHammer ?? this.boosterHammer,
      boosterShuffle: boosterShuffle ?? this.boosterShuffle,
    );
  }
}

/// Small helper to avoid importing GameConstants (which is fine, but keeps
/// the model self-contained). Mirrors [GameConstants.startingLives].
class GameConstantsPlaceholder {
  static const int startingLives = 5;
}

/// Per-user level progress, mapped from `user_progress`.
class UserProgress {
  final String id;
  final String userId;
  final int levelId;
  final int stars;
  final int bestScore;
  final bool completed;
  final DateTime updatedAt;

  const UserProgress({
    required this.id,
    required this.userId,
    required this.levelId,
    required this.stars,
    required this.bestScore,
    required this.completed,
    required this.updatedAt,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      levelId: json['level_id'] as int,
      stars: json['stars'] as int? ?? 0,
      bestScore: json['best_score'] as int? ?? 0,
      completed: json['completed'] as bool? ?? false,
      updatedAt: DateTime.parse(json['updated_at'] as String? ??
          DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'level_id': levelId,
        'stars': stars,
        'best_score': bestScore,
        'completed': completed,
        'updated_at': updatedAt.toIso8601String(),
      };

  UserProgress copyWith({int? stars, int? bestScore, bool? completed, DateTime? updatedAt}) {
    return UserProgress(
      id: id,
      userId: userId,
      levelId: levelId,
      stars: stars ?? this.stars,
      bestScore: bestScore ?? this.bestScore,
      completed: completed ?? this.completed,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
