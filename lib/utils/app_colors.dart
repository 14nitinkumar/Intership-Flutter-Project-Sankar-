import 'package:flutter/material.dart';

/// Design tokens and color palette specified in the VyapaarHub blueprint.
class AppColors {
  AppColors._();

  // Primary brand palette
  static const Color primaryNavy = Color(0xFF172B4D); // App bar, headings, key surfaces
  static const Color actionTeal = Color(0xFF16A085);  // Primary CTA, links, active states
  static const Color background = Color(0xFFF4F6F9);  // Screen background
  static const Color surface = Color(0xFFFFFFFF);     // Cards, inputs, sheets
  static const Color textPrimary = Color(0xFF1F2937); // Primary body text
  static const Color textMuted = Color(0xFF667085);   // Hints, secondary labels
  static const Color border = Color(0xFFE7ECF2);      // Dividers, card borders

  // Additional status colors
  static const Color success = Color(0xFF2E7D32);     // Verified, success
  static const Color warning = Color(0xFFE65100);     // MOQ warning, low stock
  static const Color error = Color(0xFFD32F2F);       // Errors, destructive actions
  static const Color chipBackground = Color(0xFFEBF5F3); // Teal light tint
}
