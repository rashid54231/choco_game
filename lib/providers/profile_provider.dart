import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:choco_blast_adventure/models/level_model.dart';
import 'package:choco_blast_adventure/models/user_profile_model.dart';
import 'package:choco_blast_adventure/providers/auth_provider.dart';
import 'package:choco_blast_adventure/services/auth_service.dart';
import 'package:choco_blast_adventure/services/cache_service.dart';
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
  final authUser = ref.watch(authProvider);
  final notifier = ProfileNotifier(ref);
  notifier.state = authUser;
  return notifier;
});

class ProfileNotifier extends StateNotifier<UserProfile?> {
  final Ref ref;
  ProfileNotifier(this.ref) : super(null);

  void set(UserProfile? profile) {
    state = profile;
    if (profile != null) {
      ref.read(authProvider.notifier).setProfile(profile);
    }
  }

  /// Recompute lives from the server timestamp.
  Future<void> refreshLives() async {
    if (state == null) return;
    final updated = await LivesService.instance.refreshLives(state!);
    set(updated);
  }

  Future<void> spendLife() async {
    if (state == null) return;
    final updated = await LivesService.instance.spendLife(state!);
    set(updated);
  }

  /// Update totals after finishing a level.
  void updateFrom(UserProfile updated) {
    set(updated);
  }

  Future<bool> consumeBooster(String boosterType) async {
    final currentProfile = state;
    if (currentProfile == null) return false;

    int newExtraMoves = currentProfile.boosterExtraMoves;
    int newColorBomb = currentProfile.boosterColorBomb;
    int newHammer = currentProfile.boosterHammer;
    int newShuffle = currentProfile.boosterShuffle;

    if (boosterType == 'extra_moves') {
      if (newExtraMoves <= 0) return false;
      newExtraMoves--;
    } else if (boosterType == 'color_bomb') {
      if (newColorBomb <= 0) return false;
      newColorBomb--;
    } else if (boosterType == 'hammer') {
      if (newHammer <= 0) return false;
      newHammer--;
    } else if (boosterType == 'shuffle') {
      if (newShuffle <= 0) return false;
      newShuffle--;
    } else {
      return false;
    }

    final updated = currentProfile.copyWith(
      boosterExtraMoves: newExtraMoves,
      boosterColorBomb: newColorBomb,
      boosterHammer: newHammer,
      boosterShuffle: newShuffle,
    );

    set(updated);
    await CacheService.instance.saveProfile(updated);
    try {
      await AuthService.instance.updateProfile(updated);
    } catch (_) {}

    return true;
  }

  Future<bool> buyBooster(String boosterType, int cost) async {
    final currentProfile = state;
    if (currentProfile == null) return false;
    if (currentProfile.coins < cost) return false;

    int newCoins = currentProfile.coins - cost;
    int newExtraMoves = currentProfile.boosterExtraMoves;
    int newColorBomb = currentProfile.boosterColorBomb;
    int newHammer = currentProfile.boosterHammer;
    int newShuffle = currentProfile.boosterShuffle;
    int newLives = currentProfile.lives;

    if (boosterType == 'extra_moves') {
      newExtraMoves += 1;
    } else if (boosterType == 'color_bomb') {
      newColorBomb += 1;
    } else if (boosterType == 'hammer') {
      newHammer += 1;
    } else if (boosterType == 'shuffle') {
      newShuffle += 3; // Pack of 3
    } else if (boosterType == 'lives') {
      newLives = (newLives + 5).clamp(0, 5); // Add 5 lives, max 5
    } else {
      return false;
    }

    final updated = currentProfile.copyWith(
      coins: newCoins,
      boosterExtraMoves: newExtraMoves,
      boosterColorBomb: newColorBomb,
      boosterHammer: newHammer,
      boosterShuffle: newShuffle,
      lives: newLives,
    );

    set(updated);
    await CacheService.instance.saveProfile(updated);
    try {
      await AuthService.instance.updateProfile(updated);
    } catch (_) {}

    return true;
  }

  Future<void> updateUsernameAndAvatar(String username, String avatarUrl) async {
    final currentProfile = state;
    if (currentProfile == null) return;

    final updated = currentProfile.copyWith(
      username: username,
      avatarUrl: avatarUrl,
    );

    set(updated);
    await CacheService.instance.saveProfile(updated);
    try {
      await AuthService.instance.updateProfile(updated);
    } catch (_) {}
  }
}
