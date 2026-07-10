import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:choco_blast_adventure/core/constants/supabase_config.dart';

/// Thin wrapper around the Supabase client. All other services depend on this.
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static bool get isReady => SupabaseConfig.isConfigured;

  /// Initialize Supabase. Call once before runApp.
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  /// The current signed-in user, or null for guests / logged-out.
  static User? get currentUser => client.auth.currentUser;

  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// True if a real (non-anonymous) session exists.
  static bool get isSignedIn => currentUser != null;
}
