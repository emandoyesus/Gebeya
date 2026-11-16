import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ethiopian market-inspired modern palette
  static const Color primaryGreen = Color(0xFF136A36);
  static const Color primaryGreenLight = Color(0xFF2E8540);
  static const Color accentGold = Color(0xFFD97706);
  static const Color backgroundLight = Color(0xFFF7F6F0);
  static const Color surfaceWhite = Colors.white;
  static const Color textDark = Color(0xFF1E293B);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderLight = Color(0xFFE2E8F0);
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
