// Centralized color utilities and semantic tokens for the app
import 'package:flutter/material.dart';
import 'dart:math';

class AppColorsPage {
  // Base / neutrals
  // Primary background (app canvas)
  static const Color primaryColor = Color(0xFFF7F8FA); // near-white, airy
  // Surface for cards and sheets
  static const Color surfaceNeutral = Colors.white;

  // Brand colors
  static const Color secondaryColor = Color(0xFF4CAF50); // green brand
  static const Color accentColor = Color(0xFF66D17A); // light pastel

  // Derived shades
  static final Color secondaryLight = secondaryColor.withOpacity(0.14);
  static final Color secondaryMedium = secondaryColor.withOpacity(0.32);
  static final Color secondaryDark = const Color(0xFF2E7D32);

  // Text tokens
  // Primary on-background text
  static final Color onBackground = Colors.black87;
  // Secondary / muted text
  static final Color mutedText = Colors.black54;
  // Backwards-compatible alias (many files reference this)
  static final Color textColor = mutedText;

  // Accent gradient for buttons / highlights (signature)
  static final Gradient primaryGradient = LinearGradient(
    colors: [
      secondaryColor.withOpacity(0.95),
      secondaryColor.withOpacity(0.65),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Subtle glass background for floating elements
  static final Color glassBackground = Colors.white.withOpacity(0.55);

  // Elevated blur overlay color for depth
  static final Color elevationOverlay = Colors.black.withOpacity(0.06);

  // Utilities
  static Color withOpacity(Color c, double t) => c.withOpacity(t);
}

// Small swatch preview widget (kept for dev/debug screens)
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
