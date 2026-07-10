import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:choco_blast_adventure/models/level_model.dart';
import 'package:choco_blast_adventure/models/user_profile_model.dart';
import 'package:choco_blast_adventure/services/supabase_service.dart';

/// Reads level definitions and per-user progress from Supabase.
class LevelService {
  LevelService._();
  static final LevelService instance = LevelService._();

  SupabaseClient get _client => SupabaseService.client;

  /// Fetch all levels ordered by level number.
  Future<List<LevelModel>> fetchLevels() async {
    final data = await _client
        .from('levels')
        .select()
        .order('level_number', ascending: true);
    return (data as List).map((e) => LevelModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetch a single level by its number.
  Future<LevelModel?> fetchLevelByNumber(int levelNumber) async {
    final data = await _client
        .from('levels')
        .select()
        .eq('level_number', levelNumber)
        .maybeSingle();
    if (data == null) return null;
    return LevelModel.fromJson(data);
  }

  /// Fetch the current user's progress for every level.
  Future<List<UserProgress>> fetchUserProgress() async {
    final user = SupabaseService.currentUser;
    if (user == null) return [];
    final data = await _client.from('user_progress').select().eq('user_id', user.id);
    return (data as List).map((e) => UserProgress.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Save (upsert) the user's progress for a level.
  Future<void> saveProgress(UserProgress progress) async {
    await _client.from('user_progress').upsert(progress.toJson());
  }

  /// Record a completed level: updates best score, stars, completion and totals.
  Future<UserProfile> recordLevelResult({
    required UserProfile profile,
    required int levelId,
    required int score,
    required int stars,
  }) async {
    final user = SupabaseService.currentUser;
    if (user == null) return profile;

    // Upsert progress.
    final existing = await _client
        .from('user_progress')
        .select()
        .eq('user_id', user.id)
        .eq('level_id', levelId)
        .maybeSingle();

    final newBest = (existing == null)
        ? score
        : (score > (existing['best_score'] as int? ?? 0) ? score : existing['best_score'] as int);
    final newStars = (existing == null)
        ? stars
        : (stars > (existing['stars'] as int? ?? 0) ? stars : existing['stars'] as int);

    await _client.from('user_progress').upsert({
      'user_id': user.id,
      'level_id': levelId,
      'best_score': newBest,
      'stars': newStars,
      'completed': true,
      'updated_at': DateTime.now().toIso8601String(),
    });

    // Update profile totals.
    final gain = score - (existing?['best_score'] as int? ?? 0);
    final updatedTotal = profile.totalScore + gain.clamp(0, 1000000000);
    final nextLevel = stars > 0 ? profile.currentLevel + 1 : profile.currentLevel;
    final updated = profile.copyWith(totalScore: updatedTotal, currentLevel: nextLevel);
    await _client.from('profiles').update({
      'total_score': updatedTotal,
      'current_level': nextLevel,
    }).eq('id', user.id);

    return updated;
  }
}
