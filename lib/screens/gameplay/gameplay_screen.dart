import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:choco_blast_adventure/models/level_model.dart';
import 'package:choco_blast_adventure/providers/board_provider.dart';
import 'package:choco_blast_adventure/providers/game_state_provider.dart';
import 'package:choco_blast_adventure/providers/profile_provider.dart';
import 'package:choco_blast_adventure/screens/level_result/level_complete_screen.dart';
import 'package:choco_blast_adventure/screens/level_result/level_failed_screen.dart';
import 'package:choco_blast_adventure/screens/home/home_screen.dart';
import 'package:choco_blast_adventure/screens/level_map/level_map_screen.dart';
import 'package:choco_blast_adventure/services/audio_service.dart';
import 'package:choco_blast_adventure/widgets/board/combo_counter.dart';
import 'package:choco_blast_adventure/widgets/board/game_board.dart';

class GameplayScreen extends ConsumerStatefulWidget {
  final LevelModel level;
  const GameplayScreen({super.key, required this.level});

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  bool _resolved = false;
  bool _navigating = false;

  late final AnimationController _hudAnim;

  @override
  void initState() {
    super.initState();
    _hudAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _hudAnim.forward();
    if (widget.level.hasTimer) _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      ref.read(boardProvider(widget.level).notifier).tickTimer();
      _checkEnd();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _hudAnim.dispose();
    super.dispose();
  }

  void _checkEnd() {
    if (_resolved || _navigating) return;
    if (!mounted) return;
    final game = ref.read(boardProvider(widget.level));
    if (game.isResolving) return;
    if (game.isComplete) {
      _resolved = true;
      _timer?.cancel();
      _finish(true);
    } else if (game.isFailed) {
      _resolved = true;
      _timer?.cancel();
      _finish(false);
    }
  }

  Future<void> _finish(bool success) async {
    if (_navigating) return;
    _navigating = true;
    final game = ref.read(boardProvider(widget.level));
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    if (success) {
      final profile = ref.read(profileProvider);
      if (profile != null) {
        final lvl = await ref
            .read(boardProvider(widget.level).notifier)
            .recordResult(profile, score: game.goal.score, stars: game.stars);
        if (lvl != null && mounted) ref.read(profileProvider.notifier).updateFrom(lvl);
      }
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LevelCompleteScreen(
              level: widget.level,
              score: game.goal.score,
              stars: game.stars,
            ),
          ),
        );
      }
    } else {
      final profile = ref.read(profileProvider);
      if (profile != null) await ref.read(profileProvider.notifier).spendLife();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => LevelFailedScreen(level: widget.level, score: game.goal.score),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(boardProvider(widget.level));
    final screenW = MediaQuery.of(context).size.width;
    final boardSize = screenW - 16;

    // Check end conditions whenever game state changes
    if ((game.isComplete || game.isFailed) && !_resolved && !_navigating && !game.isResolving) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkEnd());
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0533), Color(0xFF0D0221), Color(0xFF0A0118)],
          ),
        ),
        child: Stack(
          children: [
            // Ambient animated glowing backdrop
            ..._buildBackgroundDecorations(),

            // Main gameplay UI layout
            SafeArea(
              child: Column(
                children: [
                  _hud(game),
                  const SizedBox(height: 6),
                  // Game board
                  Expanded(
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF150B35),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFF3A2570).withOpacity(0.5), width: 1.5),
                              boxShadow: [
                                BoxShadow(color: const Color(0xFFAB47BC).withOpacity(0.15), blurRadius: 40, spreadRadius: 8),
                                BoxShadow(color: const Color(0xFFFF6B9D).withOpacity(0.1), blurRadius: 25, spreadRadius: 3),
                                BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
                              ],
                            ),
                            child: GameBoard(level: widget.level, boardSize: boardSize),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: ComboCounter(
                                combo: game.combo,
                                show: game.animState.isAnimating && game.combo >= 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Goal panel below board
                  _goalPanel(game),
                  const SizedBox(height: 6),
                  _boosterTray(),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hud(GameState game) {
    final level = widget.level;

    return FadeTransition(
      opacity: CurvedAnimation(parent: _hudAnim, curve: Curves.easeOut),
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 4, 10, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2D1B69), Color(0xFF1E1145)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(color: const Color(0xFF1E1145).withOpacity(0.6), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // Pause
            GestureDetector(
              onTap: () {
                AudioService.instance.playButton();
                _showPause();
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                ),
                child: const Icon(Icons.pause_rounded, color: Colors.white, size: 18),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).boxShadow(
                begin: BoxShadow(color: Colors.white.withOpacity(0.0), blurRadius: 0),
                end: BoxShadow(color: Colors.white.withOpacity(0.4), blurRadius: 10, spreadRadius: 2),
                duration: 3200.ms,
                curve: Curves.easeInOut,
              ),
            ),
            const SizedBox(width: 10),
            // Level badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFFE91E7A)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'LV ${level.levelNumber}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12, fontFamily: 'Baloo2'),
              ),
            ),
            const SizedBox(width: 12),
            // Moves / Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.hasMoves ? 'MOVES' : 'TIME',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w600, fontSize: 9, letterSpacing: 1),
                ),
                Text(
                  '${level.hasMoves ? game.movesLeft : game.timeLeftSeconds}',
                  style: TextStyle(
                    color: (level.hasMoves && game.movesLeft <= 5) ? const Color(0xFFFF5252) : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    fontFamily: 'Baloo2',
                    height: 1.0,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Stars earned
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final filled = i < game.stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 18,
                    color: filled ? const Color(0xFFFFD54F) : Colors.white24,
                  ),
                );
              }),
            ),
            const SizedBox(width: 10),
            // Avatar
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.25), width: 1.5),
              ),
              child: Center(
                child: Text(
                  ref.watch(profileProvider)?.avatarUrl ?? '🍪',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ).animate(onPlay: (c) => c.loop()).shimmer(
        duration: 2500.ms,
        delay: 3500.ms,
        color: Colors.white.withOpacity(0.15),
        blendMode: BlendMode.srcATop,
      ),
    );
  }

  String _goalText(GameState game) {
    final l = widget.level;
    switch (l.goalType) {
      case GoalType.score:
        return '${game.goal.score} / ${l.goal.score ?? 0}';
      case GoalType.collect:
        return '${game.goal.collectedOf(l.goal.color!)} / ${l.goal.count ?? 0}';
      case GoalType.jelly:
        return '${game.goal.jellyCleared} / ${l.goal.jellyCount ?? 0}';
      case GoalType.ingredient:
        return '${game.goal.ingredientsDropped} / ${l.goal.ingredientCount ?? 0}';
    }
  }

  /// Goal panel shown below the game board — clear progress + star targets.
  Widget _goalPanel(GameState game) {
    final l = widget.level;
    final score = game.goal.score;

    // Goal progress (0..1)
    double progress;
    String goalLabel;
    IconData goalIcon;
    Color goalColor;

    switch (l.goalType) {
      case GoalType.score:
        final target = l.goal.score ?? 1;
        progress = (score / target).clamp(0.0, 1.0);
        goalLabel = 'Score $score / $target';
        goalIcon = Icons.star_rounded;
        goalColor = const Color(0xFFFFD54F);
        break;
      case GoalType.collect:
        final target = l.goal.count ?? 1;
        final current = game.goal.collectedOf(l.goal.color!);
        progress = (current / target).clamp(0.0, 1.0);
        goalLabel = 'Collect $current / $target';
        goalIcon = Icons.circle;
        goalColor = const Color(0xFF66BB6A);
        break;
      case GoalType.jelly:
        final target = l.goal.jellyCount ?? 1;
        final current = game.goal.jellyCleared;
        progress = (current / target).clamp(0.0, 1.0);
        goalLabel = 'Clear Jelly $current / $target';
        goalIcon = Icons.grid_view_rounded;
        goalColor = const Color(0xFFAB47BC);
        break;
      case GoalType.ingredient:
        final target = l.goal.ingredientCount ?? 1;
        final current = game.goal.ingredientsDropped;
        progress = (current / target).clamp(0.0, 1.0);
        goalLabel = 'Drop Ingredients $current / $target';
        goalIcon = Icons.arrow_downward_rounded;
        goalColor = const Color(0xFFFF9A3C);
        break;
    }

    final s1 = l.starThresholds[1] ?? 500;
    final s2 = l.starThresholds[2] ?? 2000;
    final s3 = l.starThresholds[3] ?? 5000;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1145).withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goalColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Goal label + progress
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: goalColor.withOpacity(0.2),
                ),
                child: Icon(goalIcon, color: goalColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  goalLabel,
                  style: TextStyle(
                    color: progress >= 1.0 ? goalColor : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    fontFamily: 'Baloo2',
                  ),
                ),
              ),
              if (progress >= 1.0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: goalColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('DONE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10, fontFamily: 'Baloo2')),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Stack(
                children: [
                  // Background
                  Container(color: Colors.white.withOpacity(0.1)),
                  // Fill
                  FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [goalColor.withOpacity(0.8), goalColor],
                        ),
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true))
                     .tint(color: Colors.white, end: 0.35, duration: 3000.ms, curve: Curves.easeInOut),
                  ),
                  // Star thresholds as markers
                  Positioned(
                    left: (s1 / (l.goal.score ?? s3)).clamp(0.0, 1.0) * (MediaQuery.of(context).size.width - 80),
                    top: 0,
                    bottom: 0,
                    child: Container(width: 2, color: Colors.white.withOpacity(0.4)),
                  ),
                  Positioned(
                    left: (s2 / (l.goal.score ?? s3)).clamp(0.0, 1.0) * (MediaQuery.of(context).size.width - 80),
                    top: 0,
                    bottom: 0,
                    child: Container(width: 2, color: Colors.white.withOpacity(0.4)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Star thresholds row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _starThreshold(1, s1, score),
              _starThreshold(2, s2, score),
              _starThreshold(3, s3, score),
            ],
          ),
        ],
      ),
    );
  }

  Widget _starThreshold(int star, int threshold, int current) {
    final earned = current >= threshold;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          earned ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 14,
          color: earned ? const Color(0xFFFFD54F) : Colors.white38,
        ),
        const SizedBox(width: 2),
        Text(
          '$threshold',
          style: TextStyle(
            color: earned ? const Color(0xFFFFD54F) : Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            fontFamily: 'Baloo2',
          ),
        ),
      ],
    );
  }

  Widget _boosterTray() {
    final profile = ref.watch(profileProvider);
    final game = ref.watch(boardProvider(widget.level));
    final profileNotifier = ref.read(profileProvider.notifier);
    final boardNotifier = ref.read(boardProvider(widget.level).notifier);

    final extraMovesCount = profile?.boosterExtraMoves ?? 0;
    final colorBombCount = profile?.boosterColorBomb ?? 0;
    final hammerCount = profile?.boosterHammer ?? 0;
    final shuffleCount = profile?.boosterShuffle ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          if (game.activeBooster == ActiveBooster.hammer)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9A3C).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFF9A3C).withOpacity(0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.gpp_maybe_rounded, color: Color(0xFFFF9A3C), size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Hammer Active: Tap any tile to break it',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Baloo2'),
                  ),
                ],
              ),
            ),
          if (game.activeBooster == ActiveBooster.freeSwitch)
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF42A5F5).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF42A5F5).withOpacity(0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.swipe_rounded, color: Color(0xFF42A5F5), size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Free Switch: Drag any two adjacent tiles',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Baloo2'),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _booster(
                    Icons.add_road_rounded,
                    'Moves\n($extraMovesCount)',
                    extraMovesCount > 0,
                    () async {
                      if (extraMovesCount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Out of Extra Moves! Buy more in the shop.')));
                        return;
                      }
                      final success = await profileNotifier.consumeBooster('extra_moves');
                      if (success) {
                        boardNotifier.useExtraMovesBooster();
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  _booster(
                    Icons.auto_awesome_rounded,
                    'Bomb\n($colorBombCount)',
                    colorBombCount > 0,
                    () async {
                      if (colorBombCount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Out of Color Bombs! Buy more in the shop.')));
                        return;
                      }
                      final success = await profileNotifier.consumeBooster('color_bomb');
                      if (success) {
                        boardNotifier.useColorBombBooster();
                      }
                    },
                  ),
                  const SizedBox(width: 12),
                  _booster(
                    Icons.gpp_maybe_rounded,
                    'Hammer\n($hammerCount)',
                    hammerCount > 0 || game.activeBooster == ActiveBooster.hammer,
                    () {
                      if (hammerCount <= 0 && game.activeBooster != ActiveBooster.hammer) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Out of Hammers! Buy more in the shop.')));
                        return;
                      }
                      boardNotifier.setActiveBooster(
                        game.activeBooster == ActiveBooster.hammer ? ActiveBooster.none : ActiveBooster.hammer,
                      );
                    },
                    highlighted: game.activeBooster == ActiveBooster.hammer,
                  ),
                  const SizedBox(width: 12),
                  // Free Switch Booster
                  // For now, let's use boosterShuffle count until we migrate db or just rename shuffle to switch
                  _booster(
                    Icons.swipe_rounded,
                    'Switch\n($shuffleCount)',
                    shuffleCount > 0 || game.activeBooster == ActiveBooster.freeSwitch,
                    () {
                      if (shuffleCount <= 0 && game.activeBooster != ActiveBooster.freeSwitch) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Out of Free Switches! Buy more in the shop.')));
                        return;
                      }
                      boardNotifier.setActiveBooster(
                        game.activeBooster == ActiveBooster.freeSwitch ? ActiveBooster.none : ActiveBooster.freeSwitch,
                      );
                    },
                    highlighted: game.activeBooster == ActiveBooster.freeSwitch,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _booster(IconData icon, String label, bool enabled, VoidCallback? onTap, {bool highlighted = false}) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          AudioService.instance.playButton();
          onTap();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: highlighted
                  ? const LinearGradient(colors: [Color(0xFFE91E7A), Color(0xFFFF6B9D)])
                  : (enabled
                      ? const LinearGradient(colors: [Color(0xFFFFC773), Color(0xFFFF9A3C)])
                      : LinearGradient(colors: [Colors.white.withOpacity(0.18), Colors.white.withOpacity(0.08)])),
              boxShadow: (enabled || highlighted)
                  ? [BoxShadow(color: (highlighted ? const Color(0xFFFF6B9D) : const Color(0xFFFF9A3C)).withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))]
                  : [],
              border: highlighted ? Border.all(color: Colors.white, width: 1.5) : null,
            ),
            child: Icon(icon, color: (enabled || highlighted) ? (highlighted ? Colors.white : const Color(0xFF3E2723)) : Colors.white54, size: 20),
          ),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 8, fontWeight: FontWeight.w600, height: 1.1)),
        ],
      ),
    );
  }

  void _showPause() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2D1B69), Color(0xFF150B35)]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 30)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFFFFC773), Color(0xFFFF9A3C)])),
                child: const Icon(Icons.pause_rounded, color: Color(0xFF3E2723), size: 26),
              ),
              const SizedBox(height: 12),
              const Text('Paused', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Baloo2')),
              const SizedBox(height: 18),
              _pauseBtn(Icons.play_arrow_rounded, 'Resume', const Color(0xFF4CAF50), () => Navigator.pop(context)),
              const SizedBox(height: 8),
              _pauseBtn(Icons.home_rounded, 'Menu', const Color(0xFF2196F3), () {
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false,
                );
              }),
              const SizedBox(height: 8),
              _pauseBtn(Icons.settings_rounded, 'Settings', const Color(0xFFAB47BC), () {
                Navigator.pop(context);
                _showSettings();
              }),
              const SizedBox(height: 8),
              _pauseBtn(Icons.exit_to_app_rounded, 'Exit Game', const Color(0xFFEF5350), () {
                Navigator.of(context).popUntil((r) => r.isFirst);
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2D1B69), Color(0xFF150B35)]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF6C5CE7).withOpacity(0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 30)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)])),
                child: const Icon(Icons.settings_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 12),
              const Text('Settings', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Baloo2')),
              const SizedBox(height: 18),
              _pauseBtn(Icons.play_arrow_rounded, 'Resume Game', const Color(0xFF4CAF50), () => Navigator.pop(context)),
              const SizedBox(height: 8),
              _pauseBtn(Icons.home_rounded, 'Home', const Color(0xFF2196F3), () {
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false,
                );
              }),
              const SizedBox(height: 8),
              _pauseBtn(Icons.map_rounded, 'Level Map', const Color(0xFFFF9800), () {
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LevelMapScreen()), (r) => false,
                );
              }),
              const SizedBox(height: 8),
              _pauseBtn(Icons.exit_to_app_rounded, 'Exit Game', const Color(0xFFEF5350), () {
                Navigator.of(context).popUntil((r) => r.isFirst);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pauseBtn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        AudioService.instance.playButton();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundDecorations() {
    return [
      // Soft background glowing spheres
      Positioned(
        top: 100,
        left: -40,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [const Color(0xFFAB47BC).withOpacity(0.12), Colors.transparent],
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 120,
        right: -30,
        child: Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [const Color(0xFFFF6B9D).withOpacity(0.1), Colors.transparent],
            ),
          ),
        ),
      ),
      Positioned(
        top: 350,
        right: -50,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [const Color(0xFF42A5F5).withOpacity(0.08), Colors.transparent],
            ),
          ),
        ),
      ),
      // Sparkling background stars
      for (int i = 0; i < 20; i++)
        Positioned(
          left: (i * 37) % MediaQuery.of(context).size.width,
          top: (i * 59) % MediaQuery.of(context).size.height,
          child: Container(
            width: (i % 2 == 0) ? 2 : 3,
            height: (i % 2 == 0) ? 2 : 3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15 + (i % 5) * 0.08),
            ),
          ).animate(
            onPlay: (c) => c.repeat(reverse: true),
          ).fadeOut(
            duration: Duration(milliseconds: 1500 + i * 200),
          ),
        ),
    ];
  }
}
//hello
//