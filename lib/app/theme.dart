import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Ultra-sleek OLED Dark Fitness / Financial Dashboard Palette (Kalo Style)
  static const Color oledBlack = Color(0xFF0C0E12); // Deep rich black background
  static const Color cardDark = Color(0xFF16191E); // Elevated dark card surface
  static const Color cardDarkLighter = Color(0xFF1E232B); // Secondary card surface
  static const Color cardBorder = Color(0xFF262C36); // Subtle border outline
  static const Color limeAccent = Color(0xFFB2D15A); // Neon Lime / Chartreuse primary highlight
  static const Color limeAccentMuted = Color(0xFF384318); // Dark lime container fill
  static const Color amberFlame = Color(0xFFD79C3A); // Amber / orange streak flame
  static const Color amberFlameMuted = Color(0xFF452B0E); // Amber streak container fill
  static const Color telegramBlue = Color(0xFF59B0D7); // Crisp vibrant cyan/blue

  static const Color textWhite = Color(0xFFF8FAFC); // High contrast text
  static const Color textMuted = Color(0xFF8E9BAE); // Muted secondary text
  static const Color textDim = Color(0xFF9AA7B8); // Dim auxiliary text

  // Legacy mappings for backwards-compatible references
  static const Color primaryGreen = limeAccent;
  static const Color primaryGreenDark = Color(0xFF7B9538);
  static const Color primaryGreenLight = Color(0xFFC4DE7B);
  static const Color accentGold = amberFlame;
  static const Color accentGoldLight = amberFlameMuted;
  static const Color backgroundLight = oledBlack;
  static const Color surfaceWhite = cardDark;
  static const Color textDark = textWhite;
  static const Color borderLight = cardBorder;
  static const Color priceBadgeBg = limeAccentMuted;

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: oledBlack,
      canvasColor: oledBlack,
      cardColor: cardDark,
      dividerColor: cardBorder,
      colorScheme: const ColorScheme.dark(
        primary: limeAccent,
        onPrimary: Color(0xFF0C0E12),
        secondary: amberFlame,
        surface: cardDark,
        onSurface: textWhite,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: limeAccent, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: limeAccent,
          foregroundColor: const Color(0xFF0C0E12),
          minimumSize: const Size(48, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      textTheme: GoogleFonts.notoSansEthiopicTextTheme(base.textTheme).copyWith(
        titleLarge: GoogleFonts.notoSansEthiopic(
          fontWeight: FontWeight.bold,
          color: textWhite,
          fontSize: 22,
        ),
        titleMedium: GoogleFonts.notoSansEthiopic(
          fontWeight: FontWeight.w600,
          color: textWhite,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.notoSansEthiopic(
          color: textWhite,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.notoSansEthiopic(
          color: textMuted,
          fontSize: 12,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: oledBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.notoSansEthiopic(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textWhite,
        ),
        iconTheme: const IconThemeData(color: textWhite),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: cardBorder, width: 1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardDark,
        selectedColor: limeAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder),
        ),
      ),
    );
  }

  // Backwards compatibility alias
  static ThemeData get lightTheme => darkTheme;
}

