import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Exact Color Scheme from Ruposhi International Google Site Embed
  static const Color rose950 = Color(0xFF4C0519); // Burgundy Noir
  static const Color rose900 = Color(0xFF881337); // Velvet Rose
  static const Color rose800 = Color(0xFF9F1239);
  static const Color rose700 = Color(0xFFBE123C); // Action Rose
  static const Color rose600 = Color(0xFFE11D48); // Vibrant Brand Rose
  static const Color rose500 = Color(0xFFF43F5E);
  static const Color rose200 = Color(0xFFFECDD3);
  static const Color rose100 = Color(0xFFFFE4E6);
  static const Color rose50 = Color(0xFFFFF1F2); // Soft Pink Tint

  static const Color gold600 = Color(0xFF8F6F14); // Deep Gold Text
  static const Color gold500 = Color(0xFFB59024);
  static const Color gold400 = Color(0xFFD4AF37); // Luxury Metallic Gold
  static const Color gold300 = Color(0xFFE6C675);
  static const Color gold100 = Color(0xFFFBF5E6); // Light Gold Pill BG

  static const Color surfaceCream = Color(0xFFFDFBF9); // Official Site Canvas
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1F1418); // Dark Charcoal Text
  static const Color textMuted = Color(0xFF6B7280); // Gray 500
  static const Color borderSubtle = Color(0xFFFFE4E6); // Rose 100 border

  // Semantic & backwards compatibility aliases
  static const Color darkPlum = rose950;
  static const Color midnightPlum = rose950;
  static const Color primaryRose = rose600;
  static const Color goldAccent = gold400;
  static const Color goldLight = gold100;
  static const Color softBlush = rose50;
  static const Color deepPlum = rose900;

  // Gradients matching the site
  static const LinearGradient logoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [rose600, rose900],
  );

  static const LinearGradient heroSlideGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xE64C0519), // rose-950/90
      Color(0x994C0519), // rose-950/60
      Color(0x00000000),
    ],
  );

  static const LinearGradient goldBadgeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFDF7A), gold400, gold500],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surfaceCream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: rose600,
        primary: rose600,
        onPrimary: Colors.white,
        secondary: gold400,
        surface: surfaceWhite,
        onSurface: textDark,
        surfaceContainerHighest: rose50,
      ),
      dividerColor: borderSubtle,
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.bold,
          color: textDark,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: -0.2,
        ),
        headlineSmall: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontWeight: FontWeight.w700,
          color: textDark,
          letterSpacing: 0.5,
        ),
        titleMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.inter(
          color: textDark,
          fontSize: 15,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          color: textDark,
          fontSize: 13.5,
          height: 1.45,
        ),
        bodySmall: GoogleFonts.inter(
          color: textMuted,
          fontSize: 12,
        ),
        labelLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: rose50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: rose600, width: 1.5),
        ),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
        labelStyle: const TextStyle(color: textMuted, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: rose600,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textDark,
          side: const BorderSide(color: borderSubtle),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSubtle),
        ),
      ),
    );
  }
}
