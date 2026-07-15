import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:choco_blast_adventure/core/constants/grid_config.dart';
import 'package:choco_blast_adventure/models/user_profile_model.dart';
import 'package:choco_blast_adventure/services/supabase_service.dart';

/// Manages lives with server-timestamp-based regeneration (anti-cheat).
class LivesService {
  LivesService._();
  static final LivesService instance = LivesService._();

  SupabaseClient get _client => SupabaseService.client;

  /// Recompute lives based on the server timestamp. Regenerates 1 life per
  /// [GameConstants.lifeRegenMinutes], capped at [GameConstants.maxLives].
  /// Premium users have unlimited lives.
  Future<UserProfile> refreshLives(UserProfile profile) async {
    if (profile.isPremium) {
      return profile.copyWith(lives: GameConstants.maxLives, lastLifeRegen: DateTime.now());
    }
    if (profile.lives >= GameConstants.maxLives) {
      return profile.copyWith(lastLifeRegen: DateTime.now());
    }

    final now = DateTime.now();
    final elapsed = now.difference(profile.lastLifeRegen);
    final minutes = elapsed.inMinutes;
    final regen = minutes ~/ GameConstants.lifeRegenMinutes;

    if (regen <= 0) return profile;

    final newLives = (profile.lives + regen).clamp(0, GameConstants.maxLives);
    // Advance the regen timestamp by the consumed intervals.
    final consumed = regen * GameConstants.lifeRegenMinutes;
    final newRegen = profile.lastLifeRegen.add(Duration(minutes: consumed));

    final updated = profile.copyWith(lives: newLives, lastLifeRegen: newRegen);
    await _client.from('profiles').update({
      'lives': newLives,
      'last_life_regen': newRegen.toIso8601String(),
    }).eq('id', profile.id);
    return updated;
  }

  /// Spend one life (e.g. on a level failure). Returns updated profile.
  Future<UserProfile> spendLife(UserProfile profile) async {
    final refreshed = await refreshLives(profile);
    if (refreshed.isPremium) return refreshed;
    
    final newLives = (refreshed.lives - 1).clamp(0, GameConstants.maxLives);
    // If we were at max lives, our regen timer starts NOW.
    final newRegen = refreshed.lives >= GameConstants.maxLives ? DateTime.now() : refreshed.lastLifeRegen;
    
    final updated = refreshed.copyWith(lives: newLives, lastLifeRegen: newRegen);
    await _client.from('profiles').update({
      'lives': newLives,
      'last_life_regen': newRegen.toIso8601String()
    }).eq('id', profile.id);
    return updated;
  }

  /// Duration until the next life regenerates (for the UI countdown).
  Duration timeUntilNextLife(UserProfile profile) {
    if (profile.isPremium || profile.lives >= GameConstants.maxLives) return Duration.zero;
    final elapsed = DateTime.now().difference(profile.lastLifeRegen);
    final totalSecs = GameConstants.lifeRegenMinutes * 60;
    final remSecs = totalSecs - (elapsed.inSeconds % totalSecs);
    return Duration(seconds: remSecs);
  }
}
