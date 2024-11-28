import 'package:flutter/material.dart';

class ColorUtils {
  static Color getNPSColor(int rating) {
    if (rating <= 6) return Colors.red;
    if (rating <= 8) return Colors.amber;
    return Colors.green;
  }

  static Color getRatingColor(double rating) {
    if (rating >= 4.5) return Colors.green;
    if (rating >= 3.5) return Colors.blue;
    if (rating >= 2.5) return Colors.amber;
    return Colors.red;
  }
}