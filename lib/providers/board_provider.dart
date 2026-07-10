import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:choco_blast_adventure/game_logic/board.dart';
import 'package:choco_blast_adventure/models/level_model.dart';
import 'package:choco_blast_adventure/providers/game_state_provider.dart';

/// A family provider that constructs a [GameStateNotifier] for a given level.
/// Each level gets its own fresh game state instance.
final boardProvider =
    StateNotifierProvider.family<GameStateNotifier, GameState, LevelModel>(
  (ref, level) => GameStateNotifier(level),
);

/// Convenience provider exposing just the current [Board] for a level.
final boardStateProvider = Provider.family<Board, LevelModel>((ref, level) {
  return ref.watch(boardProvider(level)).board;
});
