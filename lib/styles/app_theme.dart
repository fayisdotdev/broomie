import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light();
    return base.copyWith(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColorsPage.primaryColor,
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme).apply(
        bodyColor: AppColorsPage.onBackground,
        displayColor: AppColorsPage.onBackground,
      ),
      primaryColor: AppColorsPage.secondaryColor,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColorsPage.secondaryColor,
        onPrimary: Colors.white,
        secondary: AppColorsPage.accentColor,
        background: AppColorsPage.primaryColor,
        surface: AppColorsPage.surfaceNeutral,
        onSurface: AppColorsPage.onBackground,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsPage.secondaryDark.withOpacity(0.9),
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardColor: AppColorsPage.surfaceNeutral,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size(64, 48)),
          padding: MaterialStateProperty.all(
            const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
          elevation: MaterialStateProperty.all(6),
          backgroundColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.pressed)) {
              return AppColorsPage.secondaryDark;
            }
            return null; // use gradient via Ink for primary buttons
          }),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          textStyle: MaterialStateProperty.all(
            GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
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
        hintStyle: TextStyle(color: AppColorsPage.mutedText),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColorsPage.glassBackground,
        selectedItemColor: Colors.white,
        unselectedItemColor: AppColorsPage.mutedText,
        showUnselectedLabels: true,
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
    );
  }
}
