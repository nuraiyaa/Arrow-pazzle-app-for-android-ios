import 'package:flutter/material.dart';

/// Clean Neo-Minimalist Light Design System Color Tokens
class AppColors {
  AppColors._();

  // Surface Backgrounds (Light Mode)
  static const Color surfaceBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceDarkNavy = Color(0xFF0F172A); // Slate 900
  static const Color surfaceCard = Color(0xFFFFFFFF); // Crisp White
  static const Color surfaceCardElevated = Color(0xFFFFFFFF);
  static const Color surfaceBorder = Color(0xFFE2E8F0); // Slate 200
  static const Color surfaceBorderSubtle = Color(0xFFF1F5F9); // Slate 100

  // Brand Primaries & Accents
  static const Color brandPrimary = Color(0xFF4F46E5); // Vibrant Indigo
  static const Color brandPrimaryPressed = Color(0xFF4338CA);
  static const Color accentSecondary = Color(0xFF10B981); // Emerald Green
  static const Color accentGold = Color(0xFFF59E0B); // Amber Gold
  static const Color accentWarning = Color(0xFFEF4444); // Crimson Coral
  static const Color accentCyan = Color(0xFF0EA5E9); // Sky Blue
  static const Color accentPurple = Color(0xFF8B5CF6); // Vivid Violet

  // Text Colors (Light Mode)
  static const Color textPrimary = Color(0xFF0F172A); // High contrast dark slate
  static const Color textSecondary = Color(0xFF475569); // Medium slate
  static const Color textMuted = Color(0xFF94A3B8); // Muted slate

  // Puzzle Board Specific Colors (Matching Reference Screenshot)
  static const Color boardBackground = Color(0xFFFFFFFF);
  static const Color boardGridDot = Color(0xFFD8E2ED); // Subtle grid intersection dots
  static const Color arrowDefaultStroke = Color(0xFF1E293B); // Deep navy/slate stroke
  static const Color arrowHighlight = Color(0xFF4F46E5);
  static const Color arrowError = Color(0xFFEF4444);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
