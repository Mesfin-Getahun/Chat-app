import 'package:flutter/material.dart';

class AppTheme {
  // Ultra-clean Minimal Dark Palette (Matching Reference UI Mocks Exactly)
  static const Color bgDark = Color(0xFF0D121D); // Signature dark midnight
  static const Color cardDark = Color(0xFF151C2B); // Sleek rounded cards
  static const Color cardDarkSecondary = Color(0xFF1C2436); // Secondary containers & inputs
  static const Color accentBlue = Color(0xFF1D9BF0); // Signature Sky Blue
  static const Color avatarPurple = Color(0xFF382A52); // S avatar circle
  static const Color avatarPurpleLight = Color(0xFF5D4B8B); // Top left square logo
  static const Color pillPurple = Color(0xFF221A33); // "Sam is sleeping" pill
  static const Color textPurple = Color(0xFFA78BFA); // Purple text
  static const Color accentGreen = Color(0xFF34D399); // 84% gauge green
  static const Color textWhite = Colors.white;
  static const Color textMuted = Color(0xFF8E9BB0); // Secondary label text
  static const Color dividerColor = Color(0xFF1E283C);
  static const Color callRed = Color(0xFFEF4444); // End call red button

  // Compatibility aliases
  static const Color primaryIndigo = accentBlue;
  static const Color skyBlue = accentBlue;
  static const Color callBlue = accentBlue;
  static const Color successGreen = accentGreen;
  static const Color accentViolet = avatarPurpleLight;
  static const Color cardBgDark = cardDark;
  static const Color cardBgLight = cardDarkSecondary;
  static const Color surfaceDark = cardDark;
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentBlue, Color(0xFF0284C7)],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDark,
      colorScheme: const ColorScheme.dark(
        primary: accentBlue,
        secondary: avatarPurple,
        surface: cardDark,
      ),
      fontFamily: null,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textWhite),
      ),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
    );
  }

  // Light theme uses the same clean dark mode default as requested by the user
  static ThemeData get lightTheme => darkTheme;
}
