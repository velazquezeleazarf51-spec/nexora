import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app_theme.dart';

class ThemeColors {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color onSurface;
  final bool isDark;

  const ThemeColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.isDark,
  });

  ThemeColors copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? onSurface,
    bool? isDark,
  }) {
    return ThemeColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      onSurface: onSurface ?? this.onSurface,
      isDark: isDark ?? this.isDark,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'primary': primary.value,
      'secondary': secondary.value,
      'background': background.value,
      'surface': surface.value,
      'onSurface': onSurface.value,
      'isDark': isDark,
    };
  }

  factory ThemeColors.fromMap(Map<dynamic, dynamic> map) {
    return ThemeColors(
      primary: Color(map['primary'] as int),
      secondary: Color(map['secondary'] as int),
      background: Color(map['background'] as int),
      surface: Color(map['surface'] as int),
      onSurface: Color(map['onSurface'] as int),
      isDark: map['isDark'] as bool? ?? true,
    );
  }

  static ThemeColors get defaults => const ThemeColors(
        primary: AppTheme.defaultPrimary,
        secondary: AppTheme.defaultSecondary,
        background: AppTheme.defaultBackground,
        surface: AppTheme.defaultSurface,
        onSurface: AppTheme.defaultOnSurface,
        isDark: true,
      );
}

class ThemeNotifier extends StateNotifier<ThemeColors> {
  ThemeNotifier() : super(ThemeColors.defaults) {
    _loadFromLocal();
  }

  final _box = Hive.box('theme');

  Future<void> _loadFromLocal() async {
    final data = _box.get('colors');
    if (data != null) {
      state = ThemeColors.fromMap(Map<dynamic, dynamic>.from(data));
    }
  }

  Future<void> _saveToLocal() async {
    await _box.put('colors', state.toMap());
  }

  void updatePrimary(Color color) {
    state = state.copyWith(primary: color);
    _saveToLocal();
  }

  void updateSecondary(Color color) {
    state = state.copyWith(secondary: color);
    _saveToLocal();
  }

  void updateBackground(Color color) {
    state = state.copyWith(background: color);
    _saveToLocal();
  }

  void updateSurface(Color color) {
    state = state.copyWith(surface: color);
    _saveToLocal();
  }

  void updateOnSurface(Color color) {
    state = state.copyWith(onSurface: color);
    _saveToLocal();
  }

  void toggleDarkMode() {
    final newIsDark = !state.isDark;
    if (newIsDark) {
      state = ThemeColors.defaults.copyWith(isDark: true);
    } else {
      state = ThemeColors(
        primary: AppTheme.defaultPrimary,
        secondary: AppTheme.defaultSecondary,
        background: const Color(0xFFF5F5F7),
        surface: Colors.white,
        onSurface: const Color(0xFF1A1A24),
        isDark: false,
      );
    }
    _saveToLocal();
  }

  void resetToDefaults() {
    state = ThemeColors.defaults;
    _saveToLocal();
  }

  void applyCustomColors({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? onSurface,
  }) {
    state = state.copyWith(
      primary: primary,
      secondary: secondary,
      background: background,
      surface: surface,
      onSurface: onSurface,
    );
    _saveToLocal();
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeColors>((ref) {
  return ThemeNotifier();
});
