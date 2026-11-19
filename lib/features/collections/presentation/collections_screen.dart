import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/neo_badge.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_icon.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: NeoButton.icon(
          icon: NeoIconType.chevronLeft,
          onPressed: () => context.pop(),
        ),
        title: const Text('COLLECTIONS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: NeoBadge.coins(2450),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Active Equipped Showcase Card
            NeoCard(
              hasGlow: true,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentSecondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('CURRENTLY EQUIPPED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.accentSecondary)),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCardElevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.brandPrimary, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandPrimary.withOpacity(0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: NeoIcon(type: NeoIconType.arrowUp, size: 36, color: AppColors.brandPrimary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Neon Prism Arrow', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  const Text('Legendary • +10% XP Bonus', style: TextStyle(fontSize: 12, color: AppColors.accentCyan)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text('AVAILABLE ARROW THEMES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 12),

            // Skins Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: [
                _buildSkinCard('Classic Obsidian', AppColors.textPrimary, isEquipped: true),
                _buildSkinCard('Cyber Neon', AppColors.accentCyan, isUnlocked: true),
                _buildSkinCard('Golden Royal', AppColors.accentGold, cost: '500'),
                _buildSkinCard('Emerald Matrix', AppColors.accentSecondary, lockedReason: 'Stage 50'),
                _buildSkinCard('Solar Flare', AppColors.accentGold, lockedReason: 'Timed 10'),
                _buildSkinCard('Void Amethyst', AppColors.accentPurple, lockedReason: 'Star Chest'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkinCard(
    String name,
    Color color, {
    bool isEquipped = false,
    bool isUnlocked = false,
    String? cost,
    String? lockedReason,
  }) {
    return NeoCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeoIcon(type: NeoIconType.arrowUp, size: 26, color: color),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          if (isEquipped)
            const Text('EQUIPPED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.accentSecondary))
          else if (isUnlocked)
            const Text('EQUIP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.brandPrimary))
          else if (cost != null)
            Text('$cost Coins', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.accentGold))
          else if (lockedReason != null)
            Text(lockedReason, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
