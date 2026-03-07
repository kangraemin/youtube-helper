import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const _primaryColor = Color(0xFFFF0000);
  static const _backgroundLight = Color(0xFFF8F5F5);
  static const _backgroundDark = Color(0xFF230F0F);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      primary: _primaryColor,
      brightness: Brightness.light,
      surface: _backgroundLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.workSansTextTheme(ThemeData.light().textTheme),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      primary: _primaryColor,
      brightness: Brightness.dark,
      surface: _backgroundDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.workSansTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
