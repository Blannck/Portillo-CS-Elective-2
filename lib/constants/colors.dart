import 'package:flutter/material.dart';

/// Wireframe color palette matching the specification slides
class AppColors {
  AppColors._();

  // Top bar
  static const Color appBarBackground = Color(0xFF1E1E1E);
  static const Color appBarTitle = Colors.white;

  // Backgrounds
  static const Color scaffoldBackground = Color(0xFFE8ECEF);
  static const Color drawerBackground = Color(0xFFE2E4E7);
  static const Color drawerHover = Color(0xFFD4D8DC);

  // Cards
  static const Color primaryCard = Color(0xFFA8A8A8); // Top square cards & desktop right top card
  static const Color secondaryCard = Color(0xFFEDEDED); // Horizontal list cards & desktop right bottom card
  static const Color cardBorder = Color(0xFFD0D4D8);

  // Text & Icons
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF666666);
  static const Color iconColor = Color(0xFF222222);
}
