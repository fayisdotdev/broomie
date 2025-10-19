import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light();
    return base.copyWith(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColorsPage.backgroundNeutral,
      textTheme: GoogleFonts.poppinsTextTheme(
        base.textTheme,
      ).apply(bodyColor: Colors.black87),
      primaryColor: AppColorsPage.secondaryColor,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColorsPage.secondaryColor,
        secondary: AppColorsPage.accentColor,
        background: AppColorsPage.backgroundNeutral,
        surface: AppColorsPage.surfaceNeutral,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsPage.secondaryMedium,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardColor: AppColorsPage.surfaceNeutral,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColorsPage.secondaryColor,
          elevation: 6,
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsPage.glassBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColorsPage.surfaceNeutral.withOpacity(0.6),
        selectedItemColor: AppColorsPage.secondaryColor,
        unselectedItemColor: AppColorsPage.mutedText,
        showUnselectedLabels: true,
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
    );
  }
}
