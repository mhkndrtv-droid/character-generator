// lib/themes/app_themes.dart
import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF6750A4),
        primaryContainer: Color(0xFFEADDFF),
        secondary: Color(0xFF625B71),
        secondaryContainer: Color(0xFFE8DEF8),
        tertiary: Color(0xFF7D5260),
        tertiaryContainer: Color(0xFFFFD8E4),
        surface: Color(0xFFFFFBFE),
        surfaceContainerHighest: Color(0xFFE7E0EC),
        surfaceContainer: Color(0xFFFFFBFE),
        onSurface: Color(0xFF1C1B1F),
        onSurfaceVariant: Color(0xFF49454F),
        error: Color(0xFFB3261E),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        outline: Color(0xFF79747E),
        outlineVariant: Color(0xFFCAC4D0),
        shadow: Color(0xFF000000),
        surfaceTint: Color(0xFF6750A4),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF6750A4),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6750A4),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF7F2FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFE7E0EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFF6750A4), width: 2),
        ),
        contentPadding: EdgeInsets.all(16),
        labelStyle: TextStyle(
          color: Color(0xFF49454F),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFE7E0EC),
        labelStyle: const TextStyle(
          color: Color(0xFF1C1B1F),
        ),
        selectedColor: const Color(0xFF6750A4),
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFD0BCFF),
        primaryContainer: Color(0xFF4F378B),
        secondary: Color(0xFFCCC2DC),
        secondaryContainer: Color(0xFF4A4458),
        tertiary: Color(0xFFEFB8C8),
        tertiaryContainer: Color(0xFF633B48),
        surface: Color(0xFF1C1B1F),
        surfaceContainerHighest: Color(0xFF49454F),
        surfaceContainer: Color(0xFF1C1B1F),
        onSurface: Color(0xFFE6E1E5),
        onSurfaceVariant: Color(0xFFCAC4D0),
        error: Color(0xFFF2B8B5),
        onPrimary: Color(0xFF371E73),
        onSecondary: Color(0xFF332D41),
        outline: Color(0xFF938F99),
        outlineVariant: Color(0xFF49454F),
        shadow: Color(0xFF000000),
        surfaceTint: Color(0xFFD0BCFF),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF332D41),
        foregroundColor: Color(0xFFE6E1E5),
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F378B),
          foregroundColor: const Color(0xFFE6E1E5),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 4,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF332D41),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFF4A4458)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFD0BCFF), width: 2),
        ),
        contentPadding: EdgeInsets.all(16),
        labelStyle: TextStyle(
          color: Color(0xFFCAC4D0),
        ),
        hintStyle: TextStyle(
          color: Color(0xFF938F99),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF4A4458),
        labelStyle: const TextStyle(
          color: Color(0xFFE6E1E5),
        ),
        selectedColor: const Color(0xFF4F378B),
        checkmarkColor: const Color(0xFFE6E1E5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF4A4458),
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF4F378B),
        foregroundColor: Color(0xFFE6E1E5),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFFD0BCFF),
      ),
    );
  }
}
