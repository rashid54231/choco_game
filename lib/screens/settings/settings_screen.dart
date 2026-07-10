import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:choco_blast_adventure/core/theme/app_colors.dart';
import 'package:choco_blast_adventure/core/theme/app_text_styles.dart';
import 'package:choco_blast_adventure/providers/auth_provider.dart';
import 'package:choco_blast_adventure/providers/profile_provider.dart';
import 'package:choco_blast_adventure/screens/auth/login_screen.dart';
import 'package:choco_blast_adventure/services/audio_service.dart';

/// Professional settings screen — dark card-based layout.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final audio = AudioService.instance;

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
              // ── Header ────────────────────────────────────
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
                        child: Text('Settings', style: AppTextStyles.titleLarge),
                      ),
                    ),
                    const SizedBox(width: 36),
                  ],
                ),
              ),

              // ── Profile card ──────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.purpleGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: AppColors.candyPurple.withOpacity(0.3), blurRadius: 16),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile?.username ?? 'Guest', style: AppTextStyles.titleLarge),
                          const SizedBox(height: 4),
                          Text(
                            'Total Score: ${profile?.totalScore ?? 0}',
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, fontFamily: 'Baloo2'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2, end: 0),

              const SizedBox(height: 16),

              // ── Settings items ────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.glassWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Column(
                  children: [
                    _settingTile(
                      icon: Icons.music_note_rounded,
                      label: 'Music',
                      trailing: _toggle(
                        value: audio.musicEnabled,
                        onChanged: (v) {
                          audio.setMusicEnabled(v);
                          (context as Element).markNeedsBuild();
                        },
                      ),
                    ),
                    Divider(color: Colors.white.withOpacity(0.06), height: 1),
                    _settingTile(
                      icon: Icons.volume_up_rounded,
                      label: 'Sound Effects',
                      trailing: _toggle(
                        value: audio.sfxEnabled,
                        onChanged: (v) {
                          audio.setSfxEnabled(v);
                          (context as Element).markNeedsBuild();
                        },
                      ),
                    ),
                    Divider(color: Colors.white.withOpacity(0.06), height: 1),
                    _settingTile(
                      icon: Icons.info_outline_rounded,
                      label: 'About',
                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 20),
                    ),
                  ],
                ),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),

              const Spacer(),

              // ── Logout button ─────────────────────────────
              GestureDetector(
                onTap: () async {
                  await ref.read(authProvider.notifier).signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (r) => false,
                    );
                  }
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: AppColors.error.withOpacity(0.3), blurRadius: 12),
                    ],
                  ),
                  child: const Center(
                    child: Text('Log Out', style: TextStyle(fontFamily: 'Baloo2', fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                ),
              ).animate(delay: 300.ms).fadeIn(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingTile({required IconData icon, required String label, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.candy.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.candy, size: 20),
          ),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Baloo2', fontWeight: FontWeight.w600)),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }

  Widget _toggle({required bool value, required ValueChanged<bool> onChanged}) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 28,
        decoration: BoxDecoration(
          color: value ? AppColors.candy : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)],
            ),
          ),
        ),
      ),
    );
  }
}
