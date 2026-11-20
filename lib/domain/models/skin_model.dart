import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum SkinUnlockType {
  free,
  coins,
  stage,
  timedScore,
}

class ArrowSkin {
  final String id;
  final String name;
  final String rarity;
  final Color primaryColor;
  final Color glowColor;
  final SkinUnlockType unlockType;
  final int costCoins;
  final int requiredStage;
  final int requiredTimedScore;
  final String perkText;

  const ArrowSkin({
    required this.id,
    required this.name,
    required this.rarity,
    required this.primaryColor,
    required this.glowColor,
    this.unlockType = SkinUnlockType.free,
    this.costCoins = 0,
    this.requiredStage = 0,
    this.requiredTimedScore = 0,
    this.perkText = '',
  });

  static const List<ArrowSkin> allSkins = [
    ArrowSkin(
      id: 'classic_obsidian',
      name: 'Classic Obsidian',
      rarity: 'Common',
      primaryColor: AppColors.textPrimary,
      glowColor: AppColors.brandPrimary,
      unlockType: SkinUnlockType.free,
      perkText: 'Standard issue tactical arrow',
    ),
    ArrowSkin(
      id: 'cyber_neon',
      name: 'Cyber Neon',
      rarity: 'Rare',
      primaryColor: AppColors.accentCyan,
      glowColor: AppColors.accentCyan,
      unlockType: SkinUnlockType.coins,
      costCoins: 250,
      perkText: '+5% Score in Timed Mode',
    ),
    ArrowSkin(
      id: 'golden_royal',
      name: 'Golden Royal',
      rarity: 'Epic',
      primaryColor: AppColors.accentGold,
      glowColor: AppColors.accentGold,
      unlockType: SkinUnlockType.coins,
      costCoins: 500,
      perkText: '+10% Coins on Stage Victory',
    ),
    ArrowSkin(
      id: 'emerald_matrix',
      name: 'Emerald Matrix',
      rarity: 'Rare',
      primaryColor: AppColors.accentSecondary,
      glowColor: AppColors.accentSecondary,
      unlockType: SkinUnlockType.stage,
      requiredStage: 10,
      perkText: 'Unlocked at Stage 10',
    ),
    ArrowSkin(
      id: 'solar_flare',
      name: 'Solar Flare',
      rarity: 'Epic',
      primaryColor: Color(0xFFFB923C),
      glowColor: Color(0xFFF97316),
      unlockType: SkinUnlockType.timedScore,
      requiredTimedScore: 1500,
      perkText: 'Unlocked with 1,500+ Blitz Score',
    ),
    ArrowSkin(
      id: 'void_amethyst',
      name: 'Void Amethyst',
      rarity: 'Legendary',
      primaryColor: AppColors.accentPurple,
      glowColor: Color(0xFFA855F7),
      unlockType: SkinUnlockType.coins,
      costCoins: 1000,
      perkText: '+15% XP and Star Glow Trail',
    ),
  ];

  static ArrowSkin getById(String id) {
    return allSkins.firstWhere(
      (s) => s.id == id,
      orElse: () => allSkins.first,
    );
  }
}
