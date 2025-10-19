// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';

class AppColorsPage extends StatelessWidget {
  static const Color primaryColor = Colors.white;
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFF03A9F4);
  static const Color lightGreen = Color(0xFFC8E6C9);
  static const Color lightBlue = Color(0xFFB3E5FC);
  static const Color darkGreen = Color(0xFF2E7D32);
  static const Color darkBlue = Color(0xFF0288D1);
  static const Color textColor = Colors.black87;

  const AppColorsPage({super.key}); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Colors Palette'),
        backgroundColor: secondaryColor,
      ),
      body: Container(
        color: primaryColor,
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Primary Color',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ColorBox(color: primaryColor, label: 'White'),
            SizedBox(height: 16),
            Text(
              'Secondary Colors',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                ColorBox(color: secondaryColor, label: 'Green'),
                ColorBox(color: accentColor, label: 'Blue'),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Shades',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 10,
              children: [
                ColorBox(color: lightGreen, label: 'Light Green'),
                ColorBox(color: lightBlue, label: 'Light Blue'),
                ColorBox(color: darkGreen, label: 'Dark Green'),
                ColorBox(color: darkBlue, label: 'Dark Blue'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ColorBox extends StatelessWidget {
  final Color color;
  final String label;

  const ColorBox({required this.color, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: useWhiteForeground(color) ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  // Simple function to decide text color based on background
  bool useWhiteForeground(Color backgroundColor) {
    int v = sqrt(
      pow(backgroundColor.red, 2) * 0.299 +
          pow(backgroundColor.green, 2) * 0.587 +
          pow(backgroundColor.blue, 2) * 0.114,
    ).round();
    return v < 130;
  }
}
