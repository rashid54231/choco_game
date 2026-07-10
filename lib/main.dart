import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:choco_blast_adventure/core/constants/supabase_config.dart';
import 'package:choco_blast_adventure/core/theme/app_theme.dart';
import 'package:choco_blast_adventure/providers/auth_provider.dart';
import 'package:choco_blast_adventure/screens/splash/splash_screen.dart';
import 'package:choco_blast_adventure/services/audio_service.dart';
import 'package:choco_blast_adventure/services/auth_service.dart';
import 'package:choco_blast_adventure/services/supabase_service.dart';

/// Bridges the hydrated profile from main() into the Riverpod tree.
class AuthStateContainer {
  dynamic profile;
}
final authStateContainer = AuthStateContainer();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AudioService.instance.init();

  // If Supabase is configured, initialize and try to restore a session.
  if (SupabaseConfig.isConfigured) {
    await SupabaseService.initialize();
    final user = SupabaseService.currentUser;
    if (user != null) {
      try {
        final profile = await AuthService.instance.getCurrentProfile();
        authStateContainer.profile = profile;
      } catch (_) {}
    }
  }

  runApp(const ProviderScope(child: ChocoBlastApp()));
}

class ChocoBlastApp extends ConsumerWidget {
  const ChocoBlastApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Bridge hydrated profile if available.
    if (authStateContainer.profile != null && ref.read(authProvider) == null) {
      ref.read(authProvider.notifier).setProfile(authStateContainer.profile);
    }

    return MaterialApp(
      title: 'Choco Blast Adventure',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      // Always start at splash (splash routes to home, no forced login).
      home: const SplashScreen(),
    );
  }
}
