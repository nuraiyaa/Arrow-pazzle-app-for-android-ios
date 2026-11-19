import 'package:flutter/material.dart';

/// Neo-Minimalist Design System Color Tokens from DESIGN.md
class AppColors {
  AppColors._();

  // Surface Backgrounds
  static const Color surfaceBackground = Color(0xFF09090B);
  static const Color surfaceDarkNavy = Color(0xFF0B0F19);
  static const Color surfaceCard = Color(0xFF111827);
  static const Color surfaceCardElevated = Color(0xFF1E293B);
  static const Color surfaceBorder = Color(0xFF1E293B);
  static const Color surfaceBorderSubtle = Color(0x1AFFFFFF);

  // Brand Primaries & Accents
  static const Color brandPrimary = Color(0xFF6366F1); // Electric Indigo
  static const Color brandPrimaryPressed = Color(0xFF4F46E5); // Deep Indigo
  static const Color accentSecondary = Color(0xFF10B981); // Emerald Green
  static const Color accentGold = Color(0xFFF59E0B); // Amber Gold
  static const Color accentWarning = Color(0xFFF43F5E); // Rose Crimson
  static const Color accentCyan = Color(0xFF06B6D4); // High-tech Cyan
  static const Color accentPurple = Color(0xFF8B5CF6); // Vivid Violet

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF111827), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
