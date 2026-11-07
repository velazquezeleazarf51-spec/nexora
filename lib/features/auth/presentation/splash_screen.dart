import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants.dart';
import '../../home/home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key, this.supabaseReady = true});
  final bool supabaseReady;
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    final ready = widget.supabaseReady && Constants.hasSupabaseCredentials;
    Session? session;
    if (ready) {
      try { session = Supabase.instance.client.auth.currentSession; } catch (_) {}
    }
    if (!mounted) return;
    if (session != null) {
      final email = session.user.email ?? 'Usuario';
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => HomeScreen(supabaseReady: true, isDemo: false, displayName: email.split('@').first),
      ));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => LoginScreen(supabaseReady: ready),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.hub_rounded, size: 56, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text('Nexora', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Tu espacio. Tus reglas.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 40),
          SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: theme.colorScheme.primary)),
        ]),
      ),
    );
  }
}
