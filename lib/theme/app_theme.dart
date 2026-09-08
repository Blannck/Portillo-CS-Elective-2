import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized design system class defining colors, typography (Google Fonts Inter),
/// and Material 3 theme configurations ([lightTheme] and [darkTheme]).
class AppTheme {
  AppTheme._();


  static const Color _shopifyGreen = Color(0xFF008060);
  static const Color _shopifyGreenDark = Color(0xFF004C3F);
  static const Color _shopifyGreenLight = Color(0xFFCEEDD8);
  static const Color _shopifyAccent = Color(0xFF5C6AC4);
  static const Color _errorRed = Color(0xFFD82C0D);

  // Light surface colours
  static const Color _surfaceLight = Color(0xFFF6F6F7);
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _onSurfaceLight = Color(0xFF1A1A1A);

  // Dark surface colours
  static const Color _surfaceDark = Color(0xFF0D1117);
  static const Color _cardDark = Color(0xFF161B22);
  static const Color _onSurfaceDark = Color(0xFFE6EDF3);

  static TextTheme _buildTextTheme(Color base) {
    return GoogleFonts.interTextTheme(
      TextTheme(
        // Heading styles
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: base,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: base,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: base,
        ),
        titleLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: base,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: base,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: base,
        ),
        // Body styles
        bodyLarge: TextStyle(fontSize: 15, height: 1.6, color: base),
        bodyMedium: TextStyle(fontSize: 13, height: 1.5, color: base),
        bodySmall: TextStyle(fontSize: 12, color: base.withAlpha(179)),
        // Label styles (buttons, chips)
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        labelMedium: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _shopifyGreen,
      brightness: Brightness.light,
      primary: _shopifyGreen,
      onPrimary: Colors.white,
      primaryContainer: _shopifyGreenLight,
      onPrimaryContainer: _shopifyGreenDark,
      secondary: _shopifyAccent,
      surface: _surfaceLight,
      onSurface: _onSurfaceLight,
      error: _errorRed,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(_onSurfaceLight),
      scaffoldBackgroundColor: _surfaceLight,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: _onSurfaceLight,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _shopifyGreen,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: _onSurfaceLight),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: _cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE1E3E5), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated buttons (primary CTA)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _shopifyGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Outlined buttons (secondary)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _shopifyGreen,
          side: const BorderSide(color: _shopifyGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _shopifyGreen,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // Input decoration (search fields, etc.)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F1F1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _shopifyGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: const TextStyle(color: Color(0xFF8C9196)),
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE1E3E5),
        thickness: 1,
        space: 1,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: _shopifyGreenLight,
        labelStyle: const TextStyle(
          color: _shopifyGreenDark,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
    );
  }

  // ── Dark Theme ─────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _shopifyGreen,
      brightness: Brightness.dark,
      primary: _shopifyGreen,
      onPrimary: Colors.white,
      primaryContainer: _shopifyGreenDark,
      onPrimaryContainer: _shopifyGreenLight,
      secondary: _shopifyAccent,
      surface: _surfaceDark,
      onSurface: _onSurfaceDark,
      error: _errorRed,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(_onSurfaceDark),
      scaffoldBackgroundColor: _surfaceDark,

      appBarTheme: AppBarTheme(
        backgroundColor: _cardDark,
        foregroundColor: _onSurfaceDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black38,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: _shopifyGreen,
          letterSpacing: -0.3,
        ),
        iconTheme: const IconThemeData(color: _onSurfaceDark),
      ),

      cardTheme: CardThemeData(
        color: _cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFF30363D), width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _shopifyGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _shopifyGreen,
          side: const BorderSide(color: _shopifyGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _shopifyGreen,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF21262D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _shopifyGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: const TextStyle(color: Color(0xFF6E7681)),
      ),

      dividerTheme: const DividerThemeData(
        color: Color(0xFF30363D),
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: _shopifyGreenDark,
        labelStyle: const TextStyle(
          color: _shopifyGreenLight,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
    );
  }
}
