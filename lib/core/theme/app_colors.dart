import 'package:flutter/material.dart';

/// Zen Studio palette: Deep Charcoal, Slate Gray, single Action Accent.
class AppColors {
  AppColors._();

  static const Color deepCharcoal = Color(0xFF121212);
  static const Color slateGray = Color(0xFF2C2C2E);
  static const Color slateGrayLight = Color(0xFF3A3A3C);
  static const Color actionAccent = Color(0xFF0A84FF); // Electric Blue
  static const Color actionAccentAlt = Color(0xFFFF9F0A); // Vivid Orange (optional)

  static const Color surface = Color(0xFF1C1C1E);
  static const Color cardBackground = Color(0xFF2C2C2E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color divider = Color(0xFF38383A);

  /// For focus intensity heatmap: lighter = less, darker = more (e.g. 8+ hrs).
  static const Color heatmapLow = Color(0xFF2C2C2E);
  static const Color heatmapMid = Color(0xFF48484A);
  static const Color heatmapHigh = Color(0xFF0A84FF);

  // Light theme colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1C1C1E);
  static const Color lightTextSecondary = Color(0xFF8E8E93);
  static const Color lightDivider = Color(0xFFE5E5EA);
  static const Color lightSlateGray = Color(0xFFF2F2F7);
}
