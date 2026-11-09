import 'package:flutter/material.dart';

class CricketTheme {
  // Official Light Modern Cricket Color Palette
  static const Color primaryGreen = Color(0xFF2E7D32);     // Cricket ground-inspired green
  static const Color secondaryGreen = Color(0xFF66BB6A);   // Soft accent green
  static const Color background = Color(0xFFF7FAF7);       // Very light greenish white
  static const Color surface = Color(0xFFFFFFFF);          // Clean white
  static const Color primaryText = Color(0xFF1B2A1F);      // Dark forest green
  static const Color secondaryText = Color(0xFF718078);    // Muted grey-green
  static const Color border = Color(0xFFE3EBE4);           // Subtle green-grey
  static const Color accentGold = Color(0xFFD9A441);       // Highlights, trophies & achievements
  static const Color liveRed = Color(0xFFE53935);          // Live match status

  // Aliases for compatibility
  static const Color backgroundLight = background;
  static const Color surfaceWhite = surface;
  static const Color primaryDarkBlue = primaryGreen;
  static const Color primaryBlue = primaryGreen;
  static const Color lightBlue = secondaryGreen;
  static const Color accentCyan = secondaryGreen;
  static const Color textDark = primaryText;

  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 10,
    offset: Offset(0, 3),
    spreadRadius: 1,
  );

  static const BoxShadow activeCardShadow = BoxShadow(
    color: Color(0x142E7D32),
    blurRadius: 14,
    offset: Offset(0, 4),
    spreadRadius: 1,
  );

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryGreen,
        onPrimary: Colors.white,
        secondary: secondaryGreen,
        onSecondary: Colors.white,
        error: liveRed,
        onError: Colors.white,
        surface: surface,
        onSurface: primaryText,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: primaryText,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryText,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
        iconTheme: IconThemeData(color: primaryGreen),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: border, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryGreen,
        unselectedItemColor: secondaryText,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: secondaryText, fontSize: 14),
        labelStyle: const TextStyle(color: secondaryText, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 1.8),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryGreen,
        unselectedLabelColor: secondaryText,
        indicatorColor: primaryGreen,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }
}
