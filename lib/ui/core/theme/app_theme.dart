import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Luxury Palette: Obsidian, Deep Slate, Camel & Satin Gold
  static const Color background = Color(0xFF090D16);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceLight = Color(0xFF1F2937);
  static const Color surfaceBorder = Color(0xFF2E384D);

  static const Color accentCamel = Color(0xFFC19A6B);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentCamelMuted = Color(0xFF8B6B43);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Functional Status Colors
  static const Color statusSuccess = Color(0xFF10B981);
  static const Color statusWarning = Color(0xFFF59E0B);
  static const Color statusDanger = Color(0xFFEF4444);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accentCamel,
      colorScheme: const ColorScheme.dark(
        primary: accentCamel,
        secondary: accentGold,
        surface: surface,
        error: statusDanger,
        onPrimary: Colors.black,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
          headlineLarge: GoogleFonts.outfit(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          headlineMedium: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleLarge: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSecondary,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: textSecondary,
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accentCamel,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: surfaceBorder, width: 1),
        ),
      ),
    );
  }
}
