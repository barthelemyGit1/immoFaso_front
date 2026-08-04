import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette et thème ImmoFaso.
/// Couleurs pensées pour évoquer la terre ocre / le bâti de Bobo-Dioulasso
/// tout en restant sobres pour une app immobilière (confiance, lisibilité).
class AppColors {
  AppColors._();

  static const Color primary = Color.fromARGB(211, 223, 117, 12); // terracotta
  static const Color primaryDark = Color(0xFF8A4A1F);
  static const Color secondary = Color(0xFF1F4B43); // vert profond
  static const Color background = Color(0xFFFAF7F3);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF221B17);
  static const Color textSecondary = Color(0xFF6E6259);
  static const Color error = Color(0xD4A0172A);
  static const Color success = Color(0xFF2E7D5B);
  static const Color warning = Color(0xFFE0A32C);
  static const Color border = Color(0xFFE5DED6);

  // Couleurs par rôle (utilisées dans le back-office / badges admin)
  static const Color roleLocataire = Color(0xFF2E6F9E);
  static const Color roleProprietaire = Color(0xD4A0172A);
  static const Color roleAdmin = Color(0xFF6B3FA0);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(211, 160, 23, 41),
        primary: const Color.fromARGB(211, 223, 117, 12),
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.inter().fontFamily,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromARGB(211, 223, 117, 12), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
