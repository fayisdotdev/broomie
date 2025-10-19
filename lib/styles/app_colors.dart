// Centralized color utilities for the app
import 'package:flutter/material.dart';
import 'dart:math';

class AppColorsPage {
  // Core palette
  static const Color primaryColor = Color(0xFFF7F8FA); // soft off-white
  static const Color secondaryColor = Color(0xFF4CAF50); // green
  static const Color accentColor = Color(0xFF66D17A); // pastel accent

  // Shade variations (derived)
  static final Color secondaryLight = secondaryColor.withOpacity(0.92);
  static final Color secondaryMedium = secondaryColor.withOpacity(0.72);
  static final Color secondaryDark = Color(0xFF2E7D32);

  // Neutral surfaces
  static final Color backgroundNeutral = Colors.grey.shade50;
  static final Color surfaceNeutral = Colors.white;
  static final Color mutedText = Colors.black54;
  static final Color textColor = Colors.black54;

  // Accent gradient for buttons / highlights
  static final Gradient primaryGradient = LinearGradient(
    colors: [
      secondaryColor.withOpacity(0.95),
      secondaryColor.withOpacity(0.65),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Subtle glass background for float elements
  static final Color glassBackground = Colors.white.withOpacity(0.55);

  // Utility
  static Color withOpacity(Color c, double t) => c.withOpacity(t);
}

// Small swatch preview widget
class ColorBox extends StatelessWidget {
  final Color color;
  final String label;

  const ColorBox({required this.color, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: useWhiteForeground(color) ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  bool useWhiteForeground(Color backgroundColor) {
    final v = sqrt(
      0.299 * pow(backgroundColor.red, 2) +
          0.587 * pow(backgroundColor.green, 2) +
          0.114 * pow(backgroundColor.blue, 2),
    );
    return v < 130;
  }
}
