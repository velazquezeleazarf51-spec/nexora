import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores base por defecto (se pueden sobreescribir con personalización)
  static const Color defaultPrimary = Color(0xFF6C63FF);
  static const Color defaultSecondary = Color(0xFF00D9FF);
  static const Color defaultBackground = Color(0xFF0F0F13);
  static const Color defaultSurface = Color(0xFF1A1A24);
  static const Color defaultOnSurface = Color(0xFFE8E8ED);
  static const Color defaultError = Color(0xFFFF5252);

  static ThemeData buildTheme({
    required Color primary,
    required Color secondary,
    required Color background,
    required Color surface,
    required Color onSurface,
    required Brightness brightness,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.black,
      error: defaultError,
      onError: Colors.white,
      background: background,
      onBackground: onSurface,
      surface: surface,
      onSurface: onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: onSurface.withOpacity(0.5),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  // Tema oscuro por defecto
  static ThemeData get darkTheme => buildTheme(
        primary: defaultPrimary,
        secondary: defaultSecondary,
        background: defaultBackground,
        surface: defaultSurface,
        onSurface: defaultOnSurface,
        brightness: Brightness.dark,
      );

  // Tema claro por defecto
  static ThemeData get lightTheme => buildTheme(
        primary: defaultPrimary,
        secondary: defaultSecondary,
        background: const Color(0xFFF5F5F7),
        surface: Colors.white,
        onSurface: const Color(0xFF1A1A24),
        brightness: Brightness.light,
      );
}
