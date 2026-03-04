import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  
  static const Color primaryCyan = Color(0xFF00D4FF);
  static const Color primaryBlue = Color(0xFF0066FF);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentGold = Color(0xFFFFD700);

  
  static const Color darkBg = Color(0xFF050B18);
  static const Color darkSurface = Color(0xFF0D1B2A);
  static const Color darkCard = Color(0xFF112240);
  static const Color darkBorder = Color(0xFF1E3A5F);

  
  static const Color lightBg = Color(0xFFF0F7FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFE8F4FD);
  static const Color lightBorder = Color(0xFFB8D9F5);

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: darkBg,
        colorScheme: const ColorScheme.dark(
          primary: primaryCyan,
          secondary: accentOrange,
          surface: darkSurface,
          background: darkBg,
          onPrimary: darkBg,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        ),
        fontFamily: 'Nunito',
        cardTheme: CardThemeData(
          color: darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: darkBorder, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryCyan,
            foregroundColor: darkBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: lightBg,
        colorScheme: const ColorScheme.light(
          primary: primaryBlue,
          secondary: accentOrange,
          surface: lightSurface,
          background: lightBg,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF0D1B2A),
          onBackground: Color(0xFF0D1B2A),
        ),
        fontFamily: 'Nunito',
        cardTheme: CardThemeData(
          color: lightCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: lightBorder, width: 1),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
}
