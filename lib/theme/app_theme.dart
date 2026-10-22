import 'package:flutter/material.dart';

/// Theme for the app. Mirrors the original app's dark Roblox styling
/// with an orange accent (from `btn_txtcolor` #e8652d) and white text.
class AppTheme {
  AppTheme._();

  static const Color background = Color(0xFF0E0E12);
  static const Color surface = Color(0xFF1B1B22);
  static const Color accent = Color(0xFFE8652D);
  static const Color accentSoft = Color(0xFFF08A57);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB7B7C0);
  static const Color cardSelected = Color(0xFF2E2E38);

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accentSoft,
        surface: surface,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'Sora',
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: textPrimary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Sora',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: surface,
        contentTextStyle: TextStyle(color: textPrimary),
      ),
    );
  }
}
