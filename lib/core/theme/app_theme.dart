import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static TextTheme _textTheme(
    ThemeData baseTheme,
    Color primary,
    Color secondary,
  ) {
    return GoogleFonts.interTextTheme(baseTheme.textTheme).copyWith(
      displayLarge: GoogleFonts.dmSans(
        color: primary,
        fontSize: 68,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.inter(
        color: primary,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(
        color: primary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyMedium: GoogleFonts.inter(
        color: secondary,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();

    return baseTheme.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.textPrimary,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.background,
        primary: AppColors.textPrimary,
        secondary: AppColors.statusIconActive,
      ),
      textTheme: _textTheme(
        baseTheme,
        AppColors.textPrimary,
        AppColors.textSecondary,
      ),
    );
  }

  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();

    return baseTheme.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      primaryColor: const Color(0xFF0F172A),
      colorScheme: const ColorScheme.light(
        surface: Color(0xFFF5F7FB),
        primary: Color(0xFF0F172A),
        secondary: Color(0xFF0284C7),
      ),
      textTheme: _textTheme(
        baseTheme,
        const Color(0xFF0F172A),
        const Color(0xFF64748B),
      ),
    );
  }
}
