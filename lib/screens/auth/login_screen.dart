import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:choco_blast_adventure/core/theme/app_colors.dart';
import 'package:choco_blast_adventure/core/theme/app_text_styles.dart';
import 'package:choco_blast_adventure/providers/auth_provider.dart';
import 'package:choco_blast_adventure/screens/auth/signup_screen.dart';
import 'package:choco_blast_adventure/screens/level_map/level_map_screen.dart';

/// Professional login screen — dark glass card layout.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;

  Future<void> _signIn() async {
    setState(() => _error = null);
    try {
      await ref.read(authProvider.notifier).signIn(_email.text.trim(), _password.text);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LevelMapScreen()),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> _guest() async {
    await ref.read(authProvider.notifier).signInAsGuest();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LevelMapScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Logo
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF8D6E63), Color(0xFF5D4037)],
                      ),
                      boxShadow: [
                        BoxShadow(color: AppColors.gold.withOpacity(0.2), blurRadius: 20),
                      ],
                    ),
                    child: const Center(child: Text('🍫', style: TextStyle(fontSize: 36))),
                  ).animate().scale(begin: const Offset(0, 0), end: const Offset(1, 1), curve: Curves.elasticOut),

                  const SizedBox(height: 16),
                  const Text('Welcome Back!', style: AppTextStyles.displayLarge),
                  const SizedBox(height: 32),

                  // Glass card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.glassWhite,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.glassBorder, width: 1),
                    ),
                    child: Column(
                      children: [
                        _field(_email, 'Email', false, Icons.email_rounded),
                        const SizedBox(height: 14),
                        _field(_password, 'Password', true, Icons.lock_rounded),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        _buildButton('Log In', AppColors.pinkButtonGradient, _signIn),
                        const SizedBox(height: 12),
                        _buildButton('Continue as Guest', AppColors.purpleGradient, _guest),
                      ],
                    ),
                  ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    ),
                    child: const Text(
                      'Create an account',
                      style: TextStyle(color: AppColors.candy, fontSize: 16, fontFamily: 'Baloo2', fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, bool obscure, IconData icon) {
    return TextField(
      controller: c,
      obscureText: obscure,
      keyboardType: obscure ? TextInputType.text : TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white, fontFamily: 'Baloo2'),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontFamily: 'Baloo2'),
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.candy, width: 2),
        ),
      ),
    );
  }

  Widget _buildButton(String label, LinearGradient gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontFamily: 'Baloo2', fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
//hhh
//hsgahd