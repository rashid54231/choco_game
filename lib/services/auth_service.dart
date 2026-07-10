import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:choco_blast_adventure/core/constants/grid_config.dart';
import 'package:choco_blast_adventure/models/user_profile_model.dart';
import 'package:choco_blast_adventure/services/supabase_service.dart';

/// Handles Supabase authentication (email/password + anonymous guest).
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  SupabaseClient get _client => SupabaseService.client;

  /// Current auth user.
  User? get currentUser => SupabaseService.currentUser;

  /// Sign up with email + password, then create a profile row.
  Future<UserProfile> signUp(String email, String password, String username) async {
    final res = await _client.auth.signUp(email: email, password: password);
    final user = res.user;
    if (user == null) throw Exception('Sign up failed.');
    return _ensureProfile(user.id, username);
  }

  /// Sign in with email + password.
  Future<UserProfile> signIn(String email, String password) async {
    final res = await _client.auth.signInWithPassword(email: email, password: password);
    final user = res.user;
    if (user == null) throw Exception('Sign in failed.');
    return _ensureProfile(user.id, null);
  }

  /// Continue as a guest using Supabase anonymous auth.
  Future<UserProfile> signInAsGuest() async {
    final res = await _client.auth.signInAnonymously();
    final user = res.user;
    if (user == null) throw Exception('Guest sign in failed.');
    final guestName = 'Guest_${user.id.substring(0, 6)}';
    return _ensureProfile(user.id, guestName);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Create the profile row if it does not exist yet; otherwise fetch it.
  Future<UserProfile> _ensureProfile(String userId, String? username) async {
    final existing = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (existing != null) {
      return UserProfile.fromJson(existing);
    }
    final name = username ?? 'Player_${userId.substring(0, 6)}';
    final inserted = await _client
        .from('profiles')
        .insert({
          'id': userId,
          'username': name,
          'total_score': 0,
          'current_level': 1,
          'lives': GameConstants.startingLives,
          'last_life_regen': DateTime.now().toIso8601String(),
          'is_premium': false,
        })
        .select()
        .single();
    return UserProfile.fromJson(inserted);
  }

  /// Fetch the current profile (after auth state is known).
  Future<UserProfile?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;
    final data = await _client.from('profiles').select().eq('id', user.id).maybeSingle();
    if (data == null) return _ensureProfile(user.id, null);
    return UserProfile.fromJson(data);
  }
}
