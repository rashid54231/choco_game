import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:choco_blast_adventure/core/constants/tile_constants.dart';
import 'package:choco_blast_adventure/game_logic/match_detector.dart';
import 'package:choco_blast_adventure/game_logic/move_validator.dart';
import 'package:choco_blast_adventure/models/animation_state.dart';
import 'package:choco_blast_adventure/models/level_model.dart';
import 'package:choco_blast_adventure/models/tile_model.dart';
import 'package:choco_blast_adventure/providers/board_provider.dart';
import 'package:choco_blast_adventure/providers/profile_provider.dart';
import 'package:choco_blast_adventure/providers/game_state_provider.dart';
import 'package:choco_blast_adventure/services/audio_service.dart';
import 'package:choco_blast_adventure/widgets/board/bomb_blast_overlay.dart';
import 'package:choco_blast_adventure/widgets/board/tile_widget.dart';
import 'package:choco_blast_adventure/widgets/board/match_particles.dart';
import 'dart:ui'; // For ImageFilter

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
  bool _swapTriggered = false;

  double get cellSize => widget.boardSize / widget.level.gridSize;

  @override
  Widget build(BuildContext context) {
    // Only watch what is needed for the overlay to prevent full board rebuilds
    final hasBombBlast = ref.watch(boardProvider(widget.level).select(
      (s) => s.animState.bombBlastCenter != null && s.animState.bombBlastCells.isNotEmpty
    ));
    final bombCenter = ref.watch(boardProvider(widget.level).select((s) => s.animState.bombBlastCenter));
    final bombCells = ref.watch(boardProvider(widget.level).select((s) => s.animState.bombBlastCells));
    final bombTile = bombCenter != null ? ref.watch(boardProvider(widget.level).select((s) => s.board[bombCenter.r][bombCenter.c])) : null;

    final activeCascadeStep = ref.watch(boardProvider(widget.level).select((s) => s.animState.activeCascadeStep));

    final rows = widget.level.gridSize;
    final cols = widget.level.gridSize;

    return SizedBox(
      width: widget.boardSize,
      height: widget.boardSize,
      child: Stack(
        children: [
          // Glassmorphism Board Background
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF150538).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ],
                ),
              ),
            ),
          ),
          Container(
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
                return CellWidget(
                  level: widget.level,
                  r: r,
                  c: c,
                  cellSize: cellSize,
                  onPanStart: (d) { 
                    _dragStartR = r; _dragStartC = c; _panStart = d.localPosition; 
                    _swapTriggered = false;
                  },
                  onPanUpdate: _handlePanUpdate,
                  onPanEnd: _handlePanEnd,
                  onTapHammer: () => _tapHammer(r, c),
                  onTapSpecial: () => _tapSpecial(r, c),
                );
              },
            ),
          ),
          // Bomb blast overlay
          if (hasBombBlast && bombCenter != null && bombTile != null)
            Positioned.fill(
              child: BombBlastOverlay(
                center: _cellToOffset(bombCenter, rows),
                color: _bombColor(bombTile),
                hitPositions: bombCells
                    .map((cell) => _cellToOffset(cell, rows))
                    .toSet(),
              ),
            ),
          
          // Advanced Combo Popup Overlay
          if (activeCascadeStep >= 2)
            Positioned.fill(
              child: Center(
                child: IgnorePointer(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildComboText(activeCascadeStep, key: ValueKey('combo_$activeCascadeStep')),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComboText(int step, {Key? key}) {
    String text;
    Color color;
    if (step == 2) { text = 'Sweet!'; color = Colors.orangeAccent; }
    else if (step == 3) { text = 'Delicious!'; color = Colors.pinkAccent; }
    else if (step == 4) { text = 'Divine!'; color = Colors.purpleAccent; }
    else { text = 'Unbelievable!'; color = Colors.yellowAccent; }

    return Animate(
      child: Text(
        text,
        key: key,
        style: TextStyle(
          fontFamily: 'Baloo2',
          fontSize: 48 + (step * 4.0).clamp(0, 24),
          fontWeight: FontWeight.w900,
          color: color,
          height: 1,
          shadows: const [
            Shadow(color: Colors.black54, offset: Offset(2, 4), blurRadius: 4),
            Shadow(color: Colors.white70, offset: Offset(-1, -1), blurRadius: 2),
          ],
        ),
      ),
    ).scale(
      begin: const Offset(0.5, 0.5), 
      end: const Offset(1, 1), 
      duration: const Duration(milliseconds: 400), 
      curve: Curves.elasticOut,
    ).then(
      delay: const Duration(milliseconds: 400),
    ).fadeOut(
      duration: const Duration(milliseconds: 200),
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
      case TileType.apple:
        return const Color(0xFFEF5350);
      case TileType.watermelon:
        return const Color(0xFF66BB6A);
      case TileType.lemon:
        return const Color(0xFFFFEE58);
      case TileType.banana:
        return const Color(0xFFFFCA28);
      case TileType.avocado:
        return const Color(0xFF9CCC65);
      case TileType.orange:
        return const Color(0xFFFFA726);
      case null:
        return Colors.white;
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_busy) return;
    _panEnd = details.localPosition;
    
    // Trigger swap immediately mid-swipe for extreme responsiveness
    if (!_swapTriggered && _panStart != null && _dragStartR != null && _dragStartC != null) {
      final dx = _panEnd!.dx - _panStart!.dx;
      final dy = _panEnd!.dy - _panStart!.dy;
      if (dx.abs() > 20 || dy.abs() > 20) {
        _swapTriggered = true;
        int tr = _dragStartR!, tc = _dragStartC!;
        if (dx.abs() > dy.abs()) {
          tc += dx > 0 ? 1 : -1;
        } else {
          tr += dy > 0 ? 1 : -1;
        }
        _trySwap(_dragStartR!, _dragStartC!, tr, tc);
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_busy) return;
    if (!_swapTriggered && _dragStartR != null && _dragStartC != null && _panStart != null && _panEnd != null) {
      final dx = _panEnd!.dx - _panStart!.dx;
      final dy = _panEnd!.dy - _panStart!.dy;

      // Ignore tiny drags (taps)
      if (dx.abs() >= 8 || dy.abs() >= 8) {
        int tr = _dragStartR!, tc = _dragStartC!;
        if (dx.abs() > dy.abs()) {
          tc += dx > 0 ? 1 : -1;
        } else {
          tr += dy > 0 ? 1 : -1;
        }
        _trySwap(_dragStartR!, _dragStartC!, tr, tc);
      }
    }
    _resetDrag();
  }

  void _resetDrag() {
    _dragStartR = null;
    _dragStartC = null;
    _panStart = null;
    _panEnd = null;
    _swapTriggered = false;
  }

  void _tapHammer(int r, int c) async {
    if (_busy) return;
    setState(() => _busy = true);
    final notifier = ref.read(boardProvider(widget.level).notifier);
    final profileNotifier = ref.read(profileProvider.notifier);
    
    // Attempt to consume 1 hammer booster
    final success = await profileNotifier.consumeBooster('hammer');
    if (success) {
      await notifier.applyHammer(r, c);
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
        notifier.setActiveBooster(ActiveBooster.none);
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
    final profileNotifier = ref.read(profileProvider.notifier);
    
    if (notifier.snapshot.activeBooster == ActiveBooster.freeSwitch) {
      final success = await profileNotifier.consumeBooster('shuffle'); // Using shuffle as fallback if we don't have free_switch in DB
      if (success) {
        await notifier.applyFreeSwitch(r1, c1, r2, c2);
        if (!mounted) { setState(() => _busy = false); return; }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Out of Free Switches! Buy more in the shop.')),
          );
          notifier.setActiveBooster(ActiveBooster.none);
        }
      }
      setState(() => _busy = false);
      return;
    }
    
    final valid = await notifier.attemptSwap(r1, c1, r2, c2);
    if (!mounted) { setState(() => _busy = false); return; }
    if (!valid) {
      AudioService.instance.playInvalid();
    } else {
      if (notifier.snapshot.combo >= 3) HapticFeedback.mediumImpact();
    }
    if (valid && !notifier.snapshot.isComplete && !notifier.snapshot.isFailed) {
      if (!MoveValidator.hasAnyValidMove(notifier.snapshot.board)) notifier.reshuffle();
    }
    setState(() => _busy = false);
  }
}

class CellWidget extends ConsumerWidget {
  final LevelModel level;
  final int r;
  final int c;
  final double cellSize;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;
  final VoidCallback onTapHammer;
  final VoidCallback onTapSpecial;

  const CellWidget({
    super.key,
    required this.level,
    required this.r,
    required this.c,
    required this.cellSize,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onTapHammer,
    required this.onTapSpecial,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBooster = ref.watch(boardProvider(level).select((s) => s.activeBooster));
    final tile = ref.watch(boardProvider(level).select((s) => s.board[r][c]));
    final a = ref.watch(boardProvider(level).select((s) => s.animState.stateFor(r, c)));

    // MATCHED: flash glow
    if (a.phase == CellAnimPhase.matched) {
      return GestureDetector(
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 1.15),
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
          builder: (_, s, _) => Transform.scale(
            scale: s,
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.85), spreadRadius: 2)]),
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
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeInQuad,
            builder: (_, s, _) => Transform.scale(
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
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: TweenAnimationBuilder<Offset>(
          tween: Tween(begin: Offset(0, -px), end: Offset.zero),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          builder: (_, o, _) => Transform.translate(
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
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: TweenAnimationBuilder<Offset>(
          tween: Tween(begin: Offset(0, -from - cellSize), end: Offset.zero),
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutBack,
          builder: (_, o, _) => Transform.translate(
            offset: o,
            child: tile.isEmpty ? const SizedBox.shrink() : TileWidget(tile: tile, size: cellSize, row: r, col: c),
          ),
        ),
      );
    }

    // IDLE
    return GestureDetector(
      onTap: activeBooster == ActiveBooster.hammer
          ? onTapHammer
          : (tile.isSpecial ? onTapSpecial : null),
      onPanStart: (d) {
        onPanStart(d);
      },
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 80),
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: FadeTransition(opacity: anim, child: child)),
        child: tile.isEmpty
            ? const SizedBox.shrink(key: ValueKey('empty'))
            : TileWidget(key: ValueKey('${tile.type}-${tile.special}-$r-$c'), tile: tile, size: cellSize, row: r, col: c),
      ),
    );
  }
}
