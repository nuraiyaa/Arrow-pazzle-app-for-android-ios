import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/neo_badge.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_icon.dart';

class GameModesScreen extends StatelessWidget {
  const GameModesScreen({super.key});

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
        title: const Text('GAME MODES', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
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
            // Mode 1: Relaxed Mode
            NeoCard(
              hasGlow: true,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          NeoIcon(type: NeoIconType.star, size: 24, color: AppColors.brandPrimary),
                          SizedBox(width: 10),
                          Text('Relaxed Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentSecondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.accentSecondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Zen puzzle solving with 3-heart safety system', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildDifficultyPill('Easy', false),
                      const SizedBox(width: 8),
                      _buildDifficultyPill('Hard', true),
                      const SizedBox(width: 8),
                      _buildDifficultyPill('Master', false),
                    ],
                  ),
                  const SizedBox(height: 20),
                  NeoButton(
                    text: 'PLAY STAGE 42',
                    icon: NeoIconType.play,
                    width: double.infinity,
                    onPressed: () => context.push('/gameplay'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Mode 2: Challenge Mode
            NeoCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      NeoIcon(type: NeoIconType.trophy, size: 24, color: AppColors.accentPurple),
                      SizedBox(width: 10),
                      Text('Challenge Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Larger grids with immovable obstacle blocks', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 16),
                  NeoButton(
                    text: 'ENTER CHALLENGE',
                    variant: NeoButtonVariant.secondary,
                    width: double.infinity,
                    onPressed: () => context.push('/gameplay'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Mode 3: Timed Rush
            NeoCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      NeoIcon(type: NeoIconType.stopwatch, size: 24, color: AppColors.accentCyan),
                      SizedBox(width: 10),
                      Text('Timed Rush', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Fast-paced blitz against the clock with combo scores', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 16),
                  NeoButton(
                    text: 'START BLITZ',
                    variant: NeoButtonVariant.secondary,
                    width: double.infinity,
                    onPressed: () => context.push('/gameplay'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyPill(String title, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.brandPrimary : AppColors.surfaceCardElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? AppColors.brandPrimary : AppColors.surfaceBorderSubtle,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }
}
