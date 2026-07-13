import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'package:choco_blast_adventure/core/constants/tile_constants.dart';
import 'package:choco_blast_adventure/game_logic/match_detector.dart';
import 'package:choco_blast_adventure/game_logic/move_validator.dart';
import 'package:choco_blast_adventure/models/animation_state.dart';
import 'package:choco_blast_adventure/models/level_model.dart';
import 'package:choco_blast_adventure/models/tile_model.dart';
import 'package:choco_blast_adventure/providers/board_provider.dart';
import 'package:choco_blast_adventure/providers/profile_provider.dart';
import 'package:choco_blast_adventure/services/audio_service.dart';
import 'package:choco_blast_adventure/widgets/board/bomb_blast_overlay.dart';
import 'package:choco_blast_adventure/widgets/board/tile_widget.dart';
import 'package:choco_blast_adventure/widgets/board/match_particles.dart';

class GameBoard extends ConsumerStatefulWidget {
  final LevelModel level;
  final double boardSize;
  const GameBoard({super.key, required this.level, required this.boardSize});

  @override
  ConsumerState<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends ConsumerState<GameBoard> {
  int? _dragStartR;
  int? _dragStartC;
  Offset? _panStart;
  Offset? _panEnd;
  bool _busy = false;

  double get cellSize => widget.boardSize / widget.level.gridSize;

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(boardProvider(widget.level));
    final rows = widget.level.gridSize;
    final cols = widget.level.gridSize;
    final anim = game.animState;

    final hasBombBlast = anim.bombBlastCenter != null && anim.bombBlastCells.isNotEmpty;

    return SizedBox(
      width: widget.boardSize,
      height: widget.boardSize,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1C3352), Color(0xFF142840)],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            padding: const EdgeInsets.all(4),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
              ),
              itemCount: rows * cols,
              itemBuilder: (context, index) {
                final r = index ~/ cols;
                final c = index % cols;
                return _buildCell(game.isHammerMode, game.board[r][c], r, c, anim.stateFor(r, c));
              },
            ),
          ),
          // Bomb blast overlay
          if (hasBombBlast)
            Positioned.fill(
              child: BombBlastOverlay(
                center: _cellToOffset(anim.bombBlastCenter!, rows),
                color: _bombColor(game.board[anim.bombBlastCenter!.r][anim.bombBlastCenter!.c]),
                hitPositions: anim.bombBlastCells
                    .map((cell) => _cellToOffset(cell, rows))
                    .toSet(),
              ),
            ),
        ],
      ),
    );
  }

  Offset _cellToOffset(Cell cell, int gridSize) {
    final cellW = widget.boardSize / gridSize;
    return Offset(
      4 + cell.c * cellW + cellW / 2,
      4 + cell.r * cellW + cellW / 2,
    );
  }

  Color _bombColor(Tile tile) {
    switch (tile.type) {
      case TileType.blueSphere:
        return const Color(0xFF42A5F5);
      case TileType.greenSquare:
        return const Color(0xFF66BB6A);
      case TileType.purpleFlower:
        return const Color(0xFFAB47BC);
      case TileType.orangeBean:
        return const Color(0xFFFF9A3C);
      case TileType.redBerry:
        return const Color(0xFFEF5350);
      case TileType.yellowStar:
        return const Color(0xFFFFD54F);
      case null:
        return Colors.white;
    }
  }

  Widget _buildCell(bool isHammerMode, Tile tile, int r, int c, CellAnimState a) {
    // MATCHED: flash glow
    if (a.phase == CellAnimPhase.matched) {
      return GestureDetector(
        onPanStart: (d) { _dragStartR = r; _dragStartC = c; _panStart = d.localPosition; },
        onPanUpdate: (d) { _panEnd = d.localPosition; },
        onPanEnd: (d) => _handlePanEnd(),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 1.2),
          duration: const Duration(milliseconds: 50),
          curve: Curves.easeOut,
          builder: (_, s, __) => Transform.scale(
            scale: s,
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.85), blurRadius: 10, spreadRadius: 2)]),
              child: tile.isEmpty ? const SizedBox.shrink() : TileWidget(tile: tile, size: cellSize),
            ),
          ),
        ),
      );
    }

    // POPPING: shrink + particles
    if (a.phase == CellAnimPhase.popping) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 1.0, end: 0.0),
            duration: const Duration(milliseconds: 50),
            curve: Curves.easeIn,
            builder: (_, s, __) => Transform.scale(
              scale: s,
              child: tile.isEmpty ? const SizedBox.shrink() : TileWidget(tile: tile, size: cellSize),
            ),
          ),
          Positioned(
            left: cellSize / 2 - 14,
            top: cellSize / 2 - 14,
            child: SizedBox(
              width: 28,
              height: 28,
              child: MatchParticles(
                center: const Offset(14, 14),
                color: tile.type != null ? tileBaseColor[tile.type!]! : Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    // FALLING: slide down
    if (a.phase == CellAnimPhase.falling && a.fallDistance > 0) {
      final px = a.fallDistance * (cellSize + 2);
      return GestureDetector(
        onPanStart: (d) { _dragStartR = r; _dragStartC = c; _panStart = d.localPosition; },
        onPanUpdate: (d) { _panEnd = d.localPosition; },
        onPanEnd: (d) => _handlePanEnd(),
        child: TweenAnimationBuilder<Offset>(
          tween: Tween(begin: Offset(0, -px), end: Offset.zero),
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
          builder: (_, o, __) => Transform.translate(
            offset: o,
            child: tile.isEmpty ? const SizedBox.shrink() : TileWidget(tile: tile, size: cellSize),
          ),
        ),
      );
    }

    // REFILLING: slide in from top
    if (a.phase == CellAnimPhase.refilling) {
      final from = a.fromRow.abs() * (cellSize + 2);
      return GestureDetector(
        onPanStart: (d) { _dragStartR = r; _dragStartC = c; _panStart = d.localPosition; },
        onPanUpdate: (d) { _panEnd = d.localPosition; },
        onPanEnd: (d) => _handlePanEnd(),
        child: TweenAnimationBuilder<Offset>(
          tween: Tween(begin: Offset(0, -from - cellSize), end: Offset.zero),
          duration: const Duration(milliseconds: 50),
          curve: Curves.easeOutBack,
          builder: (_, o, __) => Transform.translate(
            offset: o,
            child: tile.isEmpty ? const SizedBox.shrink() : TileWidget(tile: tile, size: cellSize),
          ),
        ),
      );
    }

    // IDLE
    return GestureDetector(
      onTap: isHammerMode
          ? () => _tapHammer(isHammerMode, r, c)
          : (tile.isSpecial ? () => _tapSpecial(r, c) : null),
      onPanStart: (d) { _dragStartR = r; _dragStartC = c; _panStart = d.localPosition; },
      onPanUpdate: (d) { _panEnd = d.localPosition; },
      onPanEnd: (d) => _handlePanEnd(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 80),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: FadeTransition(opacity: anim, child: child)),
        child: tile.isEmpty
            ? const SizedBox.shrink(key: ValueKey('empty'))
            : TileWidget(key: ValueKey('${tile.type}-${tile.special}-$r-$c'), tile: tile, size: cellSize),
      ),
    );
  }

  void _handlePanEnd() {
    if (_dragStartR == null || _dragStartC == null || _panStart == null || _panEnd == null) return;

    final dx = _panEnd!.dx - _panStart!.dx;
    final dy = _panEnd!.dy - _panStart!.dy;

    // Ignore tiny drags (taps)
    if (dx.abs() < 8 && dy.abs() < 8) {
      _resetDrag();
      return;
    }

    int tr = _dragStartR!, tc = _dragStartC!;
    if (dx.abs() > dy.abs()) {
      // Horizontal swipe
      tc += dx > 0 ? 1 : -1;
    } else {
      // Vertical swipe
      tr += dy > 0 ? 1 : -1;
    }
    _trySwap(_dragStartR!, _dragStartC!, tr, tc);
    _resetDrag();
  }

  void _resetDrag() {
    _dragStartR = null;
    _dragStartC = null;
    _panStart = null;
    _panEnd = null;
  }

  void _tapHammer(bool isHammerMode, int r, int c) async {
    if (_busy) return;
    setState(() => _busy = true);
    final notifier = ref.read(boardProvider(widget.level).notifier);
    final profileNotifier = ref.read(profileProvider.notifier);
    
    // Attempt to consume 1 hammer booster
    final success = await profileNotifier.consumeBooster('hammer');
    if (success) {
      await notifier.useHammerBooster(r, c);
      if (!mounted) { setState(() => _busy = false); return; }
      final game = ref.read(boardProvider(widget.level));
      if (!game.isComplete && !game.isFailed) {
        if (!MoveValidator.hasAnyValidMove(game.board)) notifier.reshuffle();
      }
    } else {
      // Show snackbar or alert if out of boosters
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Out of Hammers! Buy more in the shop.')),
        );
        notifier.toggleHammerMode(); // Turn off hammer mode since we didn't have any
      }
    }
    setState(() => _busy = false);
  }

  void _tapSpecial(int r, int c) async {
    if (_busy) return;
    setState(() => _busy = true);
    final notifier = ref.read(boardProvider(widget.level).notifier);
    await notifier.tapActivate(r, c);
    if (!mounted) { setState(() => _busy = false); return; }
    final game = ref.read(boardProvider(widget.level));
    if (!game.isComplete && !game.isFailed) {
      if (!MoveValidator.hasAnyValidMove(game.board)) notifier.reshuffle();
    }
    setState(() => _busy = false);
  }

  Future<void> _trySwap(int r1, int c1, int r2, int c2) async {
    if (_busy) return;
    if (r2 < 0 || c2 < 0 || r2 >= widget.level.gridSize || c2 >= widget.level.gridSize) return;
    if (!mounted) return;
    setState(() => _busy = true);
    HapticFeedback.lightImpact();
    AudioService.instance.playSwap();
    final notifier = ref.read(boardProvider(widget.level).notifier);
    final valid = await notifier.attemptSwap(r1, c1, r2, c2);
    if (!mounted) { setState(() => _busy = false); return; }
    if (!valid) {
      AudioService.instance.playInvalid();
    } else {
      AudioService.instance.playMatch();
      if (notifier.snapshot.combo >= 3) HapticFeedback.mediumImpact();
    }
    if (valid && !notifier.snapshot.isComplete && !notifier.snapshot.isFailed) {
      if (!MoveValidator.hasAnyValidMove(notifier.snapshot.board)) notifier.reshuffle();
    }
    setState(() => _busy = false);
  }
}
