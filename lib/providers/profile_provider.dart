import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:choco_blast_adventure/models/level_model.dart';
import 'package:choco_blast_adventure/models/user_profile_model.dart';
import 'package:choco_blast_adventure/services/level_service.dart';
import 'package:choco_blast_adventure/services/lives_service.dart';

/// All levels, fetched from Supabase.
final levelsProvider = FutureProvider<List<LevelModel>>((ref) async {
  return LevelService.instance.fetchLevels();
});

/// The current user's per-level progress map (keyed by levelId).
final userProgressProvider = FutureProvider<Map<int, UserProgress>>((ref) async {
  final list = await LevelService.instance.fetchUserProgress();
  return {for (final p in list) p.levelId: p};
});

/// The user's profile, wrapped so lives/score updates propagate.
final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile?>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<UserProfile?> {
  ProfileNotifier() : super(null);

  void set(UserProfile? profile) => state = profile;

  /// Recompute lives from the server timestamp.
  Future<void> refreshLives() async {
    if (state == null) return;
    state = await LivesService.instance.refreshLives(state!);
  }

  Future<void> spendLife() async {
    if (state == null) return;
    state = await LivesService.instance.spendLife(state!);
  }

  /// Update totals after finishing a level.
  void updateFrom(UserProfile updated) => state = updated;
}
