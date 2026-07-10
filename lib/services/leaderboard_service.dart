import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:choco_blast_adventure/services/supabase_service.dart';

/// Reads the global leaderboard. Supports a realtime subscription so the
/// UI updates live as other players' scores change.
class LeaderboardService {
  LeaderboardService._();
  static final LeaderboardService instance = LeaderboardService._();

  SupabaseClient get _client => SupabaseService.client;

  /// Top players by total score (the `leaderboard` view).
  Future<List<Map<String, dynamic>>> fetchLeaderboard({int limit = 100}) async {
    final data = await _client
        .from('leaderboard')
        .select()
        .limit(limit);
    return (data as List).map((e) => e as Map<String, dynamic>).toList();
  }

  /// Subscribe to realtime changes on the `profiles` table so the board
  /// refreshes live. Returns a subscription the caller must close.
  Stream<List<Map<String, dynamic>>> subscribe() {
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast();
    // Initial load.
    fetchLeaderboard().then(controller.add);

    final channel = _client
        .channel('leaderboard-changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'profiles',
          callback: (_) {
            fetchLeaderboard().then(controller.add);
          },
        )
        .subscribe();

    controller.onCancel = () {
      _client.removeChannel(channel);
    };

    return controller.stream;
  }
}
