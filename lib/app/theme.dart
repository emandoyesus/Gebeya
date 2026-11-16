import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // JIJI-inspired vibrant Ethiopian market palette
  static const Color jijiGreen = Color(0xFF00B53F);
  static const Color primaryGreen = Color(0xFF00B53F);
  static const Color primaryGreenDark = Color(0xFF0B7B39);
  static const Color accentGold = Color(0xFFF59E0B);
  static const Color telegramBlue = Color(0xFF0088CC);
  static const Color backgroundLight = Color(0xFFF4F5F7);
  static const Color surfaceWhite = Colors.white;
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color priceBadgeBg = Color(0xFFE8F5E9);

  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        secondary: accentGold,
        surface: surfaceWhite,
      ),
      scaffoldBackgroundColor: backgroundLight,
      dividerColor: borderLight,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: borderLight),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textTheme: GoogleFonts.notoSansEthiopicTextTheme(base.textTheme).copyWith(
        titleLarge: GoogleFonts.notoSansEthiopic(
          fontWeight: FontWeight.bold,
          color: textDark,
          fontSize: 20,
        ),
        titleMedium: GoogleFonts.notoSansEthiopic(
          fontWeight: FontWeight.w600,
          color: textDark,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.notoSansEthiopic(
          color: textDark,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.notoSansEthiopic(
          color: textMuted,
          fontSize: 12,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceWhite,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: GoogleFonts.notoSansEthiopic(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderLight, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        side: BorderSide.none,
      ),
    );
  }
}
