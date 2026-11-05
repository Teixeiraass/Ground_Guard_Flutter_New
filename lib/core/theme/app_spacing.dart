import 'package:flutter/material.dart';

class AppSpacing {
  static const double spaceXS = 4;
  static const double spaceSM = 8;
  static const double spaceMD = 16;
  static const double spaceLG = 24;
  static const double spaceXL = 32;

  static const double screenPadding = 20;
  static const double touchTarget = 48;

  /// Espaço reservado no final de listas roláveis para que o conteúdo não
  /// fique permanentemente escondido atrás da nav bar flutuante.
  static const double bottomNavClearance = 110;

  static Widget vertical(double height) => SizedBox(height: height);
  static Widget horizontal(double width) => SizedBox(width: width);
}
