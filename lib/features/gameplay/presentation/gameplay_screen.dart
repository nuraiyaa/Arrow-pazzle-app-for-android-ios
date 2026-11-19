import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/neo_badge.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_icon.dart';

class GameplayScreen extends StatelessWidget {
  const GameplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Top HUD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeoButton.icon(
                    icon: NeoIconType.pause,
                    onPressed: () => _showPauseDialog(context),
                    height: 42,
                    width: 42,
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.brandPrimary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.brandPrimary.withOpacity(0.4)),
                        ),
                        child: const Text(
                          'STAGE 42',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: AppColors.brandPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'RELAXED MODE',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      NeoBadge.hearts(3),
                      const SizedBox(width: 8),
                      NeoBadge.coins(2450),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Placeholder for CustomPainter Arrow Board (To be fully integrated in Phase 4)
            Center(
              child: Container(
                width: 320,
                height: 320,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandPrimary.withOpacity(0.1),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                  ),
                  itemCount: 36,
                  itemBuilder: (context, index) {
                    final isGoldenHint = index == 16;
                    final directions = [
                      NeoIconType.arrowUp,
                      NeoIconType.arrowRight,
                      NeoIconType.arrowDown,
                      NeoIconType.arrowLeft,
                    ];
                    final dir = directions[index % directions.length];

                    return Container(
                      decoration: BoxDecoration(
                        color: isGoldenHint ? AppColors.accentGold.withOpacity(0.25) : AppColors.surfaceCardElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isGoldenHint ? AppColors.accentGold : AppColors.surfaceBorderSubtle,
                          width: isGoldenHint ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: NeoIcon(
                          type: dir,
                          size: 18,
                          color: isGoldenHint ? AppColors.accentGold : AppColors.textPrimary.withOpacity(0.85),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const Spacer(),

            // Tool Actions Dock
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildToolButton(
                    icon: NeoIconType.undo,
                    label: AppStrings.undo,
                    badge: 'x3',
                    onTap: () {},
                  ),
                  _buildToolButton(
                    icon: NeoIconType.hint,
                    label: AppStrings.hint,
                    badge: 'x2',
                    isGold: true,
                    onTap: () {},
                  ),
                  _buildToolButton(
                    icon: NeoIconType.refresh,
                    label: AppStrings.restart,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Ad Banner Container Slot
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.surfaceBorderSubtle),
              ),
              child: const Center(
                child: Text(
                  'ADVERTISEMENT',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton({
    required NeoIconType icon,
    required String label,
    String? badge,
    bool isGold = false,
    required VoidCallback onTap,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            NeoCard(
              borderRadius: 20,
              padding: const EdgeInsets.all(14),
              hasGlow: isGold,
              borderColor: isGold ? AppColors.accentGold : null,
              onTap: onTap,
              child: NeoIcon(
                type: icon,
                size: 24,
                color: isGold ? AppColors.accentGold : AppColors.textPrimary,
              ),
            ),
            if (badge != null)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isGold ? AppColors.accentGold : AppColors.brandPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  void _showPauseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: NeoCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'GAME PAUSED',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1),
              ),
              const SizedBox(height: 20),
              NeoButton(
                text: 'RESUME',
                width: double.infinity,
                onPressed: () => ctx.pop(),
              ),
              const SizedBox(height: 12),
              NeoButton(
                text: 'LEVELS MAP',
                variant: NeoButtonVariant.secondary,
                width: double.infinity,
                onPressed: () {
                  ctx.pop();
                  context.push('/levels');
                },
              ),
              const SizedBox(height: 12),
              NeoButton(
                text: 'MAIN MENU',
                variant: NeoButtonVariant.secondary,
                width: double.infinity,
                onPressed: () {
                  ctx.pop();
                  context.go('/');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
