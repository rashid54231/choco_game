import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:choco_blast_adventure/models/user_profile_model.dart';

/// Caches the last-known profile locally so the app can show something
/// (and keep playing) when the network / Supabase is unavailable.
class CacheService {
  CacheService._();
  static final CacheService instance = CacheService._();

  static const _profileKey = 'cached_profile';
  static const _completedLevelsKey = 'completed_levels';
  static const _highestLevelKey = 'highest_unlocked_level';

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }

  // --- Level Progress ---

  /// Returns the set of completed level numbers.
  Future<Set<int>> getCompletedLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_completedLevelsKey);
    if (raw == null) return {};
    return raw.map((e) => int.parse(e)).toSet();
  }

  /// Mark a level as completed and unlock the next one.
  Future<void> completeLevel(int levelNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = await getCompletedLevels();
    completed.add(levelNumber);
    await prefs.setStringList(
      _completedLevelsKey,
      completed.map((e) => e.toString()).toList(),
    );
    // Unlock next level
    final current = prefs.getInt(_highestLevelKey) ?? 1;
    if (levelNumber + 1 > current) {
      await prefs.setInt(_highestLevelKey, levelNumber + 1);
    }
  }

  /// Returns the highest unlocked level number (starts at 1).
  Future<int> getHighestUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highestLevelKey) ?? 1;
  }

  /// Sets the highest unlocked level number.
  Future<void> setHighestUnlockedLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highestLevelKey, level);
  }

  /// Returns the next level to play (first uncompleted, or last unlocked).
  Future<int> getNextLevel() async {
    final highest = await getHighestUnlockedLevel();
    final completed = await getCompletedLevels();
    for (int i = 1; i <= highest; i++) {
      if (!completed.contains(i)) return i;
    }
    // All unlocked levels completed — play the next one (if within max).
    final next = highest + 1;
    if (next <= 30) return next;
    return highest; // All levels done
  }

  // --- Level Stars ---

  /// Returns stars earned for a level (0 if not completed or no stars saved).
  Future<int> getLevelStars(int levelNumber) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('level_stars_$levelNumber') ?? 0;
  }

  /// Returns a map of level number → stars for all completed levels.
  Future<Map<int, int>> getAllLevelStars() async {
    final prefs = await SharedPreferences.getInstance();
    final completed = await getCompletedLevels();
    final map = <int, int>{};
    for (final level in completed) {
      map[level] = prefs.getInt('level_stars_$level') ?? 0;
    }
    return map;
  }

  /// Save stars earned for a level (keeps the higher value).
  Future<void> setLevelStars(int levelNumber, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('level_stars_$levelNumber') ?? 0;
    if (stars > current) {
      await prefs.setInt('level_stars_$levelNumber', stars);
    }
  }
}
