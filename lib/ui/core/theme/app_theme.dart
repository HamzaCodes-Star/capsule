import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Palette from Design System
  static const Color primaryTeal = Color(0xFF004741);     // Primary: Forest Teal
  static const Color secondaryCream = Color(0xFFF0EDE4);  // Secondary: Ecru / Stone
  static const Color tertiaryGold = Color(0xFFFFBE0B);    // Tertiary: Vibrant Marigold
  static const Color neutralDark = Color(0xFF131815);     // Neutral: Deep Forest Noir (Background)

  // Surface & Layering
  static const Color surface = Color(0xFF1B221E);         // Main Card Surface
  static const Color surfaceLight = Color(0xFF242C27);    // Secondary Surface
  static const Color surfaceBorder = Color(0xFF2E3933);   // Subtle Border
  static const Color canvasCard = Color(0xFF262F2A);      // Outfit Canvas Background

  // Text Colors
  static const Color textPrimary = Color(0xFFFBFBFB);
  static const Color textSecondary = Color(0xFFC0CDC6);
  static const Color textMuted = Color(0xFF798B82);

  // Status & Tags
  static const Color statusSuccess = Color(0xFF10B981);
  static const Color statusWarning = Color(0xFFFFBE0B);
  static const Color statusDanger = Color(0xFFD94436);

  // Backwards compatibility aliases
  static const Color background = neutralDark;
  static const Color accentCamel = tertiaryGold;
  static const Color accentGold = tertiaryGold;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: neutralDark,
      primaryColor: tertiaryGold,
      colorScheme: const ColorScheme.dark(
        primary: tertiaryGold,
        secondary: primaryTeal,
        surface: surface,
        error: statusDanger,
        onPrimary: Color(0xFF131815),
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(
        ThemeData.dark().textTheme.copyWith(
          displayLarge: GoogleFonts.epilogue(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
          headlineLarge: GoogleFonts.epilogue(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          headlineMedium: GoogleFonts.epilogue(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
          titleLarge: GoogleFonts.epilogue(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          titleMedium: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textPrimary,
          ),
          bodyLarge: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSecondary,
          ),
          bodyMedium: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: textSecondary,
          ),
          labelLarge: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: neutralDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.epilogue(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: tertiaryGold,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 16,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: surfaceBorder, width: 1),
        ),
      ),
    );
  }
}
