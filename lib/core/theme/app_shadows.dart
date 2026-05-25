import 'package:flutter/material.dart';

class AppShadows {
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(4, 4),
    ),
    BoxShadow(
      color: Colors.white.withOpacity(0.9),
      blurRadius: 10,
      offset: const Offset(-4, -4),
    ),
  ];

  static List<BoxShadow> pressedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 6,
      offset: const Offset(2, 2),
    ),
  ];
}