import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:choco_blast_adventure/models/user_profile_model.dart';
import 'package:choco_blast_adventure/services/auth_service.dart';
import 'package:choco_blast_adventure/services/cache_service.dart';

/// Holds the currently signed-in user's profile (null = signed out / guest-less).
final authProvider = StateNotifierProvider<AuthNotifier, UserProfile?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<UserProfile?> {
  AuthNotifier() : super(null);

  Future<UserProfile> signUp(String email, String password, String username) async {
    final profile = await AuthService.instance.signUp(email, password, username);
    state = profile;
    await CacheService.instance.saveProfile(profile);
    return profile;
  }

  Future<UserProfile> signIn(String email, String password) async {
    final profile = await AuthService.instance.signIn(email, password);
    state = profile;
    await CacheService.instance.saveProfile(profile);
    return profile;
  }

  Future<UserProfile> signInAsGuest() async {
    final profile = await AuthService.instance.signInAsGuest();
    state = profile;
    await CacheService.instance.saveProfile(profile);
    return profile;
  }

  Future<void> signOut() async {
    await AuthService.instance.signOut();
    state = null;
  }

  Future<void> refresh() async {
    final profile = await AuthService.instance.getCurrentProfile();
    state = profile;
  }

  void setProfile(UserProfile profile) => state = profile;
}

/// True while an auth/network operation is in flight.
final authLoadingProvider = StateProvider<bool>((ref) => false);
