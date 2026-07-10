import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:choco_blast_adventure/core/theme/app_colors.dart';
import 'package:choco_blast_adventure/core/theme/app_text_styles.dart';
import 'package:choco_blast_adventure/providers/profile_provider.dart';
import 'package:choco_blast_adventure/services/leaderboard_service.dart';

/// Professional leaderboard — dark glass card layout.
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  late final Stream<List<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = LeaderboardService.instance.subscribe();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final myId = profile?.id;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A0533), Color(0xFF0D0221)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Header ──────────────────────────────────
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.glassWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text('Leaderboard', style: AppTextStyles.titleLarge),
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),

              // ── Content ──────────────────────────────────
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _stream,
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.candy));
                    }
                    final rows = snap.data!;
                    final myRank = rows.indexWhere((r) => r['id'] == myId);
                    return Column(
                      children: [
                        if (myRank >= 0)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 12),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Your rank: #${myRank + 1}  •  ${rows[myRank]['total_score']} pts',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Baloo2', fontSize: 15),
                                ),
                              ],
                            ),
                          ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: rows.length,
                            itemBuilder: (context, i) {
                              final row = rows[i];
                              final isMe = row['id'] == myId;
                              final isTop3 = i < 3;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: isMe
                                      ? LinearGradient(
                                          colors: [AppColors.primary.withOpacity(0.2), AppColors.primary.withOpacity(0.08)],
                                        )
                                      : isTop3
                                          ? LinearGradient(
                                              colors: [AppColors.gold.withOpacity(0.1), Colors.transparent],
                                            )
                                          : null,
                                  color: isMe ? null : AppColors.glassWhite,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isMe
                                        ? AppColors.primary.withOpacity(0.5)
                                        : isTop3
                                            ? AppColors.gold.withOpacity(0.3)
                                            : AppColors.glassBorder,
                                    width: isMe ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Rank badge
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: isTop3 ? AppColors.goldGradient : LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${i + 1}',
                                          style: TextStyle(
                                            color: isTop3 ? Colors.white : Colors.white54,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            fontFamily: 'Baloo2',
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Avatar
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isMe ? AppColors.candy.withOpacity(0.2) : Colors.white.withOpacity(0.08),
                                      ),
                                      child: Icon(
                                        isMe ? Icons.person : Icons.person_outline,
                                        color: isMe ? AppColors.candy : Colors.white38,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        row['username'] ?? '?',
                                        style: TextStyle(
                                          color: isMe ? Colors.white : Colors.white70,
                                          fontSize: 15,
                                          fontWeight: isMe ? FontWeight.w700 : FontWeight.w500,
                                          fontFamily: 'Baloo2',
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${row['total_score'] ?? 0}',
                                      style: TextStyle(
                                        color: isTop3 ? AppColors.gold : Colors.white54,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        fontFamily: 'Baloo2',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
