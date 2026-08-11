import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:choco_blast_adventure/core/theme/app_colors.dart';
import 'package:choco_blast_adventure/models/level_model.dart';
import 'package:choco_blast_adventure/providers/profile_provider.dart';
import 'package:choco_blast_adventure/screens/gameplay/gameplay_screen.dart';
import 'package:choco_blast_adventure/screens/home/home_screen.dart';
import 'package:choco_blast_adventure/screens/shop/shop_screen.dart';
import 'package:choco_blast_adventure/services/audio_service.dart';
import 'package:choco_blast_adventure/services/cache_service.dart';
import 'package:choco_blast_adventure/services/lives_service.dart';
import 'dart:async';

/// Professional level map — dark cosmic theme with glowing path and milestone markers.
class LevelMapScreen extends ConsumerStatefulWidget {
  const LevelMapScreen({super.key});
  @override
  ConsumerState<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends ConsumerState<LevelMapScreen> {
  final ScrollController _scroll = ScrollController();
  int _selectedTab = 0;
  Set<int> _completed = {};
  Map<int, int> _levelStars = {};
  int _highestUnlocked = 1;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final completed = await CacheService.instance.getCompletedLevels();
    final highest = await CacheService.instance.getHighestUnlockedLevel();
    final stars = await CacheService.instance.getAllLevelStars();
    if (mounted) {
      setState(() {
        _completed = completed;
        _highestUnlocked = highest;
        _levelStars = stars;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF1A0533), // Fallback background color
      body: Stack(
        children: [
          // ── Main content (Background is now inside the scroll view) ──────────────────────────────
          SafeArea(
            child: Column(
              children: [
                _topBar(),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(color: AppColors.candy),
                        )
                      : SingleChildScrollView(
                          controller: _scroll,
                          padding: const EdgeInsets.only(bottom: 80),
                          child: Container(
                            height: screenH * 3.2,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/candy_map_bg.png'),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Color(0x550D0221), 
                                  BlendMode.darken,
                                ),
                              ),
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Put decorative elements inside so they also scroll
                                ..._buildDecorations(),
                                _buildPath(),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),

          // ── Level Up button ───────────────────────────
          Positioned(
            bottom: 70,
            right: 16,
            child: GestureDetector(
              onTap: () {
                AudioService.instance.playButton();
                _levelUp();
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.gold.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 4)),
                  ],
                ),
                child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 28),
              ),
            ).animate(delay: 1200.ms).fadeIn().scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
          ),

          // ── Bottom tab bar ───────────────────────────
          Positioned(bottom: 0, left: 0, right: 0, child: _bottomBar()),
        ],
      ),
    );
  }

  List<Widget> _buildDecorations() {
    return [
      // Stars
      for (int i = 0; i < 30; i++)
        Positioned(
          left: math.Random(i).nextDouble() * 400,
          top: math.Random(i + 100).nextDouble() * 1200,
          child: Container(
            width: 2 + math.Random(i + 200).nextDouble() * 3,
            height: 2 + math.Random(i + 200).nextDouble() * 3,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15 + math.Random(i + 300).nextDouble() * 0.2),
            ),
          ),
        ),
      // Glow orbs
      Positioned(top: 200, left: -40, child: _glowOrb(120, const Color(0xFFAB47BC).withValues(alpha: 0.08))),
      Positioned(top: 600, right: -30, child: _glowOrb(100, const Color(0xFFFF6B9D).withValues(alpha: 0.06))),
      Positioned(top: 1000, left: -20, child: _glowOrb(90, const Color(0xFF42A5F5).withValues(alpha: 0.07))),
    ];
  }

  Widget _glowOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
    );
  }

  Widget _topBar() {
    final profile = ref.watch(profileProvider);
    final coins = profile?.coins ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 16),
        ],
      ),
      child: Row(
        children: [
          // Hearts
          const _HeartBadge(),
          const SizedBox(width: 8),
          // Coins
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on_rounded, color: Colors.white, size: 14),
                const SizedBox(width: 3),
                Text(
                  '$coins',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Baloo2'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Level info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level $_highestUnlocked',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    fontFamily: 'Baloo2',
                  ),
                ),
                Text(
                  '${_completed.length} / 50 completed',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontFamily: 'Baloo2',
                  ),
                ),
              ],
            ),
          ),
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8),
              ],
            ),
            child: Center(child: Text(profile?.avatarUrl ?? '🍪', style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 8),
          // Home
          GestureDetector(
            onTap: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false,
            ),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.glassWhite,
                border: Border.all(color: AppColors.glassBorder, width: 1),
              ),
              child: const Icon(Icons.home_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPath() {
    final levelCount = 50;
    final pathPoints = <Offset>[];
    final screenW = MediaQuery.of(context).size.width;

    for (int i = 0; i < levelCount; i++) {
      final t = i / (levelCount - 1);
      final y = 60.0 + t * (MediaQuery.of(context).size.height * 3.1);
      final x = screenW / 2 + math.sin(t * math.pi * 5) * (screenW * 0.3);
      pathPoints.add(Offset(x, y));
    }

    return Stack(
      children: [
        // Path glow
        CustomPaint(
          size: Size(screenW, MediaQuery.of(context).size.height * 3.2),
          painter: _PathGlowPainter(pathPoints),
        ),
        // Path
        CustomPaint(
          size: Size(screenW, MediaQuery.of(context).size.height * 3.2),
          painter: _PathPainter(pathPoints),
        ),
        // Level nodes
        for (int i = 0; i < levelCount; i++)
          _levelNode(i + 1, pathPoints[i], i),
      ],
    );
  }

  Widget _levelNode(int level, Offset pos, int index) {
    final isCompleted = _completed.contains(level);
    final isUnlocked = level <= _highestUnlocked;
    final isCurrent = level == _highestUnlocked && !isCompleted;
    final stars = _levelStars[level] ?? 0;

    const double nodeSize = 72.0; // Larger, more tappable
    const double starSize = 24.0;

    return Positioned(
      // Centre the node on the path point
      left: pos.dx - nodeSize / 2,
      top: pos.dy - nodeSize / 2,
      child: GestureDetector(
        onTap: isUnlocked ? () {
          AudioService.instance.playButton();
          _playLevel(level);
        } : null,
        child: SizedBox(
          width: nodeSize,
          height: nodeSize + 15, // Extra space for stars at the bottom
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // ── Professional Stars Plate (Left side, horizontal, behind the node) ───────
              if (isCompleted)
                Positioned(
                  right: nodeSize - 16, // Right edge of the plate tucks 16px under the left side of the circle
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A0533).withValues(alpha: 0.95), // Deep space purple plate
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: stars > 0 ? const Color(0xFFFFD54F) : Colors.white.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: stars > 0 ? const Color(0xFFFFD54F).withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.6),
                            blurRadius: 8,
                            offset: const Offset(-2, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (i) {
                          final filled = i < stars;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1.5),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Solid base (Dark for empty, Gold for filled)
                                Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: filled ? const Color(0xFFFFD54F) : const Color(0xFF3B1E63),
                                ),
                                // Crisp border for empty stars so they don't disappear
                                if (!filled)
                                  const Icon(
                                    Icons.star_border_rounded,
                                    size: 16,
                                    color: Colors.white60,
                                  ),
                                // Subtle inner shadow / highlight
                                if (filled)
                                  Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: Colors.transparent,
                                    shadows: [
                                      Shadow(color: const Color(0xFFF57F17).withValues(alpha: 0.8), blurRadius: 4, offset: const Offset(0, 1)),
                                    ],
                                  ),
                              ],
                            ),
                          ).animate(delay: (index * 50 + i * 150).ms).scale(begin: const Offset(0, 0), end: const Offset(1, 1), curve: Curves.elasticOut, duration: 600.ms);
                        }),
                      ),
                    ),
                  ),
                ),

              // ── 3D Premium Candy Button ──────────────────
              Positioned(
                top: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: nodeSize,
                  height: nodeSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Premium gradients based on state
                    gradient: isCompleted
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF81C784), Color(0xFF388E3C), Color(0xFF1B5E20)],
                            stops: [0.0, 0.5, 1.0],
                          )
                        : isCurrent
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFFF8A65), Color(0xFFF4511E), Color(0xFFBF360C)],
                                stops: [0.0, 0.5, 1.0],
                              )
                            : isUnlocked
                                ? const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFFBA68C8), Color(0xFF8E24AA), Color(0xFF4A148C)],
                                    stops: [0.0, 0.5, 1.0],
                                  )
                                : LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Colors.white.withValues(alpha: 0.25), Colors.white.withValues(alpha: 0.05)],
                                  ),
                    border: Border.all(
                      color: isCurrent
                          ? const Color(0xFFFFD54F)
                          : isCompleted
                              ? const Color(0xFFA5D6A7)
                              : Colors.white.withValues(alpha: isUnlocked ? 0.6 : 0.15),
                      width: isCurrent ? 3 : 2,
                    ),
                    boxShadow: [
                      if (isCurrent)
                        BoxShadow(color: const Color(0xFFFF8A65).withValues(alpha: 0.8), blurRadius: 20, spreadRadius: 4),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 6,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Inner Glossy Highlight
                      if (isUnlocked)
                        Positioned(
                          top: 4,
                          left: 12,
                          right: 12,
                          height: nodeSize * 0.35,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(nodeSize / 2),
                            ),
                          ),
                        ),
                      // Center Content (Number or Lock)
                      Center(
                        child: isUnlocked
                            ? Text(
                                '$level',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 28,
                                  fontFamily: 'Baloo2',
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.4),
                                      offset: const Offset(0, 3),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              )
                            : Icon(Icons.lock_rounded, color: Colors.white.withValues(alpha: 0.5), size: 28),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Bouncing Indicator for Current Level ───────
              if (isCurrent)
                const Positioned(
                  top: -24,
                  child: Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFFFD54F), size: 40, shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))]),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: -5, end: 5, duration: 600.ms, curve: Curves.easeInOut),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: index * 50), duration: 300.ms)
          .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), delay: Duration(milliseconds: index * 50), duration: 300.ms, curve: Curves.easeOutBack),
    );
  }

  void _playLevel(int level) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameplayScreen(level: LevelModel.level(level))),
    ).then((_) => _loadProgress());
  }

  void _levelUp() async {
    final nextLevel = _highestUnlocked + 1;
    if (nextLevel > 50) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Already at max level!')),
        );
      }
      return;
    }
    await CacheService.instance.setHighestUnlockedLevel(nextLevel);
    if (mounted) {
      _loadProgress();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Level Up! Now at Level $nextLevel')),
      );
    }
  }

  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.tabBg,
        border: Border(top: BorderSide(color: AppColors.glassBorder, width: 1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _tabItem(Icons.map_rounded, 'Map', 0),
            _tabItem(Icons.event_rounded, 'Events', 1),
            _tabItem(Icons.people_rounded, 'Friends', 2),
            _tabItem(Icons.star_rounded, 'Star', 3),
            _tabItem(Icons.store_rounded, 'Shop', 4),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(IconData icon, String label, int index) {
    final active = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        AudioService.instance.playButton();
        if (index == 4) {
          // Navigate to Shop
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ShopScreen()),
          );
        } else {
          setState(() => _selectedTab = index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: active ? AppColors.candy.withValues(alpha: 0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: active ? AppColors.candy : Colors.white38, size: 22),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: active ? AppColors.candy : Colors.white38,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              fontFamily: 'Baloo2',
            ),
          ),
        ],
      ),
    );
  }
}

/// Glow behind the path.
class _PathGlowPainter extends CustomPainter {
  final List<Offset> points;
  _PathGlowPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = const Color(0x15AB47BC)
      ..strokeWidth = 40
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
      path.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
    }
    path.lineTo(points.last.dx, points.last.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_PathGlowPainter oldDelegate) => false;
}

/// Dark road with candy-cane stripes.
class _PathPainter extends CustomPainter {
  final List<Offset> points;
  _PathPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..strokeWidth = 28
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final shadowPath = Path();
    shadowPath.moveTo(points[0].dx, points[0].dy + 3);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
      shadowPath.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy + 3);
    }
    shadowPath.lineTo(points.last.dx, points.last.dy + 3);
    canvas.drawPath(shadowPath, shadowPaint);

    // Main path
    final roadPaint = Paint()
      ..color = const Color(0xFF2D1B69)
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final roadPath = Path();
    roadPath.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
      roadPath.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
    }
    roadPath.lineTo(points.last.dx, points.last.dy);
    canvas.drawPath(roadPath, roadPaint);

    // Candy-cane stripes
    final stripePaint = Paint()
      ..color = const Color(0xFF6C5CE7).withValues(alpha: 0.3)
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final stripePath = Path();
    stripePath.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final mid = Offset((prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2);
      stripePath.quadraticBezierTo(prev.dx, prev.dy, mid.dx, mid.dy);
    }
    stripePath.lineTo(points.last.dx, points.last.dy);

    final metrics = stripePath.computeMetrics().first;
    const dashLength = 12.0;
    const gapLength = 12.0;
    double distance = 0;
    final dashPath = Path();
    while (distance < metrics.length) {
      final start = metrics.getTangentForOffset(distance)!.position;
      final end = metrics.getTangentForOffset(
        (distance + dashLength).clamp(0.0, metrics.length),
      )!.position;
      dashPath.moveTo(start.dx, start.dy);
      dashPath.lineTo(end.dx, end.dy);
      distance += dashLength + gapLength;
    }
    canvas.drawPath(dashPath, stripePaint);
  }

  @override
  bool shouldRepaint(_PathPainter oldDelegate) => false;
}

class _HeartBadge extends ConsumerStatefulWidget {
  const _HeartBadge();
  @override
  ConsumerState<_HeartBadge> createState() => _HeartBadgeState();
}

class _HeartBadgeState extends ConsumerState<_HeartBadge> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final lives = profile?.lives ?? 5;
    String timerText = '';
    
    if (profile != null && lives < 5 && !profile.isPremium) {
      final rem = LivesService.instance.timeUntilNextLife(profile);
      if (rem.inSeconds <= 0) {
        ref.read(profileProvider.notifier).refreshLives();
      } else {
        final m = rem.inMinutes.toString().padLeft(2, '0');
        final s = (rem.inSeconds % 60).toString().padLeft(2, '0');
        timerText = ' $m:$s';
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.error.withValues(alpha: 0.3), AppColors.error.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite, color: Color(0xFFFF5252), size: 16),
          const SizedBox(width: 4),
          Text('$lives$timerText', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
