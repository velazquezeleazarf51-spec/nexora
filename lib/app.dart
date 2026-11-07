import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'features/auth/presentation/splash_screen.dart';

class NexoraApp extends ConsumerWidget {
  const NexoraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeColors = ref.watch(themeProvider);

    final theme = AppTheme.buildTheme(
      primary: themeColors.primary,
      secondary: themeColors.secondary,
      background: themeColors.background,
      surface: themeColors.surface,
      onSurface: themeColors.onSurface,
      brightness: themeColors.isDark ? Brightness.dark : Brightness.light,
    );

    return MaterialApp(
      title: 'Nexora',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const SplashScreen(),
    );
  }
}
