import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:choco_blast_adventure/core/constants/grid_config.dart';
import 'package:choco_blast_adventure/core/constants/tile_constants.dart';
import 'package:choco_blast_adventure/game_logic/board.dart';
import 'package:choco_blast_adventure/game_logic/board_generator.dart';
import 'package:choco_blast_adventure/game_logic/cascade_resolver.dart';
import 'package:choco_blast_adventure/game_logic/match_detector.dart';
import 'package:choco_blast_adventure/game_logic/move_validator.dart';
import 'package:choco_blast_adventure/game_logic/scoring_engine.dart';
import 'package:choco_blast_adventure/models/animation_state.dart';
import 'package:choco_blast_adventure/models/level_model.dart';
import 'package:choco_blast_adventure/models/tile_model.dart';
import 'package:choco_blast_adventure/models/user_profile_model.dart';
import 'package:choco_blast_adventure/services/audio_service.dart';
import 'package:choco_blast_adventure/services/level_service.dart';

class GoalProgress {
  int score;
  final Map<TileType, int> collected;
  int jellyCleared;
  int ingredientsDropped;

  GoalProgress({this.score = 0, Map<TileType, int>? collected})
      : collected = collected ?? {},
        jellyCleared = 0,
        ingredientsDropped = 0;

  int collectedOf(TileType t) => collected[t] ?? 0;
  void addCollected(TileType t, int n) => collected[t] = collectedOf(t) + n;
}

class GameState {
  final Board board;
  final LevelModel level;
  final int movesLeft;
  final int timeLeftSeconds;
  final GoalProgress goal;
  final int combo;
  final bool isResolving;
  final bool isComplete;
  final bool isFailed;
  final int stars;
  final BoardAnimState animState;

  const GameState({
    required this.board,
    required this.level,
    required this.movesLeft,
    required this.timeLeftSeconds,
    required this.goal,
    this.combo = 0,
    this.isResolving = false,
    this.isComplete = false,
    this.isFailed = false,
    this.stars = 0,
    this.animState = BoardAnimState.idle,
  });

  GameState copyWith({
    Board? board,
    int? movesLeft,
    int? timeLeftSeconds,
    GoalProgress? goal,
    int? combo,
    bool? isResolving,
    bool? isComplete,
    bool? isFailed,
    int? stars,
    BoardAnimState? animState,
  }) {
    return GameState(
      board: board ?? this.board,
      level: level,
      movesLeft: movesLeft ?? this.movesLeft,
      timeLeftSeconds: timeLeftSeconds ?? this.timeLeftSeconds,
      goal: goal ?? this.goal,
      combo: combo ?? this.combo,
      isResolving: isResolving ?? this.isResolving,
      isComplete: isComplete ?? this.isComplete,
      isFailed: isFailed ?? this.isFailed,
      stars: stars ?? this.stars,
      animState: animState ?? this.animState,
    );
  }
}

class GameStateNotifier extends StateNotifier<GameState> {
  final BoardGenerator _generator = BoardGenerator();
  final CascadeResolver _resolver = CascadeResolver();
  final ScoringEngine _scoring = const ScoringEngine();

  List<CascadeStep> _pendingSteps = [];
  CascadeResolution? _pendingResolution;
  bool _isAnimatingSteps = false;

  GameStateNotifier(LevelModel level)
      : super(GameState(
          board: BoardGenerator().generate(level.gridSize, level.gridSize),
          level: level,
          movesLeft: level.moveLimit ?? 0,
          timeLeftSeconds: level.timeLimitSeconds ?? 0,
          goal: GoalProgress(),
        )) {
    _ensureSolvable();
  }

  GameState get snapshot => state;

  void _ensureSolvable() {
    var board = state.board;
    int guard = 0;
    while (!MoveValidator.hasAnyValidMove(board) && guard < 20) {
      board = _generator.generate(state.level.gridSize, state.level.gridSize);
      guard++;
    }
    state = state.copyWith(board: board);
  }

  Future<bool> attemptSwap(int r1, int c1, int r2, int c2) async {
    if (state.isResolving || state.isComplete || state.isFailed) return false;

    final attempt = MoveValidator.trySwap(state.board, r1, c1, r2, c2);
    if (!attempt.valid) return false;

    state = state.copyWith(isResolving: true, board: attempt.swappedBoard);

    final resolution = _resolveSwap(state.board, r1, c1, r2, c2);
    _pendingResolution = resolution;
    _pendingSteps = List.from(resolution.steps);

    final gained = _scoring.scoreForResolution(resolution) +
        _scoring.scoreForActivations(resolution);
    final oldGoal = state.goal;
    final goal = GoalProgress(
      score: oldGoal.score + gained,
      collected: Map.from(oldGoal.collected),
    );
    for (final t in resolution.clearedTypes) {
      goal.addCollected(t, _countTypeInResolution(resolution, t));
    }

    final movesLeft = state.level.hasMoves ? state.movesLeft - 1 : state.movesLeft;
    state = state.copyWith(goal: goal, movesLeft: movesLeft);

    _isAnimatingSteps = true;
    try {
      await _animateNextStep();
    } catch (_) {
      _finishCascade();
    }

    return true;
  }

  /// Animate cascade steps — ultra fast for snappy feel.
  Future<void> _animateNextStep() async {
    if (_pendingSteps.isEmpty) {
      _finishCascade();
      return;
    }

    final step = _pendingSteps.removeAt(0);
    final totalSteps = (_pendingResolution?.steps.length ?? 1);
    final stepIndex = step.cascadeIndex;

    // Phase 1: Flash (40ms)
    state = state.copyWith(
      animState: BoardAnimState.flash(step.clearedCells, stepIndex, totalSteps),
    );
    await Future.delayed(const Duration(milliseconds: 40));

    // Phase 2: Pop (30ms)
    state = state.copyWith(
      animState: BoardAnimState.pop(step.clearedCells, stepIndex, totalSteps),
    );
    await Future.delayed(const Duration(milliseconds: 30));

    // Phase 3: Gravity + board swap (60ms)
    state = state.copyWith(
      board: step.boardAfter,
      animState: BoardAnimState.fall(step.fallDistances, stepIndex, totalSteps),
    );
    await Future.delayed(const Duration(milliseconds: 60));

    // Phase 4: Refill (30ms)
    state = state.copyWith(
      animState: BoardAnimState.refill(step.refillSources, stepIndex, totalSteps),
    );
    await Future.delayed(const Duration(milliseconds: 30));

    await _animateNextStep();
  }

  void _finishCascade() {
    _isAnimatingSteps = false;
    final resolution = _pendingResolution;

    // Update live stars so HUD reflects current score immediately
    final liveStars = state.level.starsForScore(state.goal.score);

    state = state.copyWith(
      board: resolution?.finalBoard ?? state.board,
      combo: resolution?.steps.length ?? 0,
      isResolving: false,
      animState: BoardAnimState.idle,
      stars: liveStars,
    );

    _pendingSteps = [];
    _pendingResolution = null;

    // Check end conditions with a slight delay to ensure state is settled
    Future.microtask(() => _checkEndConditions());
  }

  CascadeResolution _resolveSwap(Board board, int r1, int c1, int r2, int c2) {
    final t1 = board[r1][c1];
    final t2 = board[r2][c2];

    if (t1.special == SpecialKind.colorBomb || t2.special == SpecialKind.colorBomb) {
      final bombCell = t1.special == SpecialKind.colorBomb ? Cell(r1, c1) : Cell(r2, c2);
      final otherTile = t1.special == SpecialKind.colorBomb ? t2 : t1;
      return _resolveColorBomb(board, bombCell, otherTile.type);
    }

    if (t1.isSpecial && t2.isSpecial) {
      return _resolveSpecialCombo(board, Cell(r1, c1), Cell(r2, c2), t1, t2);
    }

    return _resolver.resolve(board);
  }

  CascadeResolution _resolveColorBomb(Board board, Cell bomb, TileType? targetType) {
    final cleared = <Cell>{};
    for (int r = 0; r < BoardHelper.rows(board); r++) {
      for (int c = 0; c < BoardHelper.cols(board); c++) {
        if (board[r][c].type == targetType || (r == bomb.r && c == bomb.c)) {
          cleared.add(Cell(r, c));
        }
      }
    }
    var current = BoardHelper.clone(board);
    for (final cell in cleared) {
      current[cell.r][cell.c] = const Tile.empty();
    }
    current = _resolver.applyGravity(current);
    current = _resolver.refill(current);
    return _resolver.resolve(current);
  }

  CascadeResolution _resolveSpecialCombo(
      Board board, Cell a, Cell b, Tile t1, Tile t2) {
    final cleared = <Cell>{};
    final rows = BoardHelper.rows(board);
    final cols = BoardHelper.cols(board);

    void addRow(int r) {
      for (int c = 0; c < cols; c++) cleared.add(Cell(r, c));
    }

    void addCol(int c) {
      for (int r = 0; r < rows; r++) cleared.add(Cell(r, c));
    }

    void add3x3(Cell cell) {
      for (int dr = -1; dr <= 1; dr++) {
        for (int dc = -1; dc <= 1; dc++) {
          final r = cell.r + dr, c = cell.c + dc;
          if (BoardHelper.inBounds(board, r, c)) cleared.add(Cell(r, c));
        }
      }
    }

    if (t1.special == SpecialKind.colorBomb && t2.special == SpecialKind.colorBomb) {
      for (int r = 0; r < rows; r++) {
        for (int c = 0; c < cols; c++) cleared.add(Cell(r, c));
      }
    } else if (t1.special == SpecialKind.striped && t2.special == SpecialKind.striped) {
      addRow(a.r); addCol(a.c); addRow(b.r); addCol(b.c);
    } else if ((t1.special == SpecialKind.striped && t2.special == SpecialKind.wrapped) ||
        (t1.special == SpecialKind.wrapped && t2.special == SpecialKind.striped)) {
      for (int dr = -1; dr <= 1; dr++) {
        if (a.r + dr >= 0 && a.r + dr < rows) addRow(a.r + dr);
        if (b.r + dr >= 0 && b.r + dr < rows) addRow(b.r + dr);
      }
      for (int dc = -1; dc <= 1; dc++) {
        if (a.c + dc >= 0 && a.c + dc < cols) addCol(a.c + dc);
        if (b.c + dc >= 0 && b.c + dc < cols) addCol(b.c + dc);
      }
    } else if (t1.special == SpecialKind.wrapped && t2.special == SpecialKind.wrapped) {
      add3x3(a); add3x3(b);
    } else {
      final other = t1.special == SpecialKind.colorBomb ? t2 : t1;
      return _resolveColorBomb(board, a, other.type);
    }

    var current = BoardHelper.clone(board);
    for (final cell in cleared) {
      current[cell.r][cell.c] = const Tile.empty();
    }
    current = _resolver.applyGravity(current);
    current = _resolver.refill(current);
    return _resolver.resolve(current);
  }

  int _countTypeInResolution(CascadeResolution res, TileType type) {
    int n = 0;
    for (final step in res.steps) {
      for (final cell in step.clearedCells) {
        final t = step.boardBefore[cell.r][cell.c].type;
        if (t == type) n++;
      }
    }
    return n;
  }

  void _checkEndConditions() {
    final goal = state.goal;
    final level = state.level;
    bool reached = false;

    switch (level.goalType) {
      case GoalType.score:
        reached = goal.score >= (level.goal.score ?? 0);
        break;
      case GoalType.collect:
        final want = level.goal.count ?? 0;
        final have = goal.collectedOf(level.goal.color!);
        reached = have >= want;
        break;
      case GoalType.jelly:
        reached = goal.jellyCleared >= (level.goal.jellyCount ?? 0);
        break;
      case GoalType.ingredient:
        reached = goal.ingredientsDropped >= (level.goal.ingredientCount ?? 0);
        break;
    }

    if (reached) {
      final stars = level.starsForScore(goal.score);
      state = state.copyWith(isComplete: true, stars: stars);
      return;
    }

    final outOfMoves = level.hasMoves && state.movesLeft <= 0;
    final outOfTime = level.hasTimer && state.timeLeftSeconds <= 0;
    if (outOfMoves || outOfTime) {
      state = state.copyWith(isFailed: true, stars: level.starsForScore(goal.score));
    }
  }

  void tickTimer() {
    if (state.isComplete || state.isFailed || state.isResolving) return;
    if (!state.level.hasTimer) return;
    final left = state.timeLeftSeconds - 1;
    state = state.copyWith(timeLeftSeconds: left);
    _checkEndConditions();
  }

  void reshuffle() {
    if (state.isComplete || state.isFailed) return;
    _ensureSolvable();
  }

  /// Tap on a special tile to activate it directly — SUPER POWERFUL.
  /// Blasts: same-colored tiles + full row + full column.
  Future<bool> tapActivate(int r, int c) async {
    if (state.isResolving || state.isComplete || state.isFailed) return false;
    final tile = state.board[r][c];
    if (!tile.isSpecial) return false;

    HapticFeedback.mediumImpact();
    AudioService.instance.playSpecial();

    // Build the blast set: same color + row + column
    final blastCells = <Cell>{};
    final rows = BoardHelper.rows(state.board);
    final cols = BoardHelper.cols(state.board);
    final targetType = tile.type;

    // All same-colored tiles
    for (int rr = 0; rr < rows; rr++) {
      for (int cc = 0; cc < cols; cc++) {
        if (state.board[rr][cc].type == targetType) {
          blastCells.add(Cell(rr, cc));
        }
      }
    }
    // Full row
    for (int cc = 0; cc < cols; cc++) {
      blastCells.add(Cell(r, cc));
    }
    // Full column
    for (int rr = 0; rr < rows; rr++) {
      blastCells.add(Cell(rr, c));
    }

    // Show bomb blast animation FIRST
    state = state.copyWith(
      isResolving: true,
      animState: BoardAnimState.bombBlast(Cell(r, c), blastCells),
    );

    // Wait for the visual blast
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return false;

    // Now actually clear the cells
    state = state.copyWith(
      animState: BoardAnimState.flash(blastCells, 0, 1),
    );
    await Future.delayed(const Duration(milliseconds: 40));

    state = state.copyWith(
      animState: BoardAnimState.pop(blastCells, 0, 1),
    );
    await Future.delayed(const Duration(milliseconds: 30));

    var current = BoardHelper.clone(state.board);
    for (final cell in blastCells) {
      current[cell.r][cell.c] = const Tile.empty();
    }
    current = _resolver.applyGravity(current);
    current = _resolver.refill(current);

    final resolution = _resolver.resolve(current);

    _pendingResolution = resolution;
    _pendingSteps = List.from(resolution.steps);

    // Score for the bomb blast
    final bombScore = blastCells.length * GameConstants.baseTileScore;
    final cascadeScore = _scoring.scoreForResolution(resolution) +
        _scoring.scoreForActivations(resolution);
    final gained = bombScore + cascadeScore;

    final oldGoal = state.goal;
    final goal = GoalProgress(
      score: oldGoal.score + gained,
      collected: Map.from(oldGoal.collected),
    );
    for (final cell in blastCells) {
      final t = state.board[cell.r][cell.c].type;
      if (t != null) goal.addCollected(t, 1);
    }
    for (final t in resolution.clearedTypes) {
      goal.addCollected(t, _countTypeInResolution(resolution, t));
    }

    state = state.copyWith(goal: goal, movesLeft: state.movesLeft - 1);

    // Continue with cascade animations
    _isAnimatingSteps = true;
    try {
      await _animateNextStep();
    } catch (_) {
      _finishCascade();
    }

    return true;
  }

  Future<UserProfile?> recordResult(UserProfile profile, {required int score, required int stars}) async {
    return LevelService.instance.recordLevelResult(
      profile: profile,
      levelId: state.level.id,
      score: score,
      stars: stars,
    );
  }
}
