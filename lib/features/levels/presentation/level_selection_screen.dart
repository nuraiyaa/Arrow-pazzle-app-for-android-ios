import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/neo_badge.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_icon.dart';

class LevelSelectionScreen extends StatelessWidget {
  const LevelSelectionScreen({super.key});

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
        title: const Column(
          children: [
            Text('CHAPTER 2: NEON LABYRINTH', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            Text('Stages 31 - 60', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: NeoBadge(
              text: '84/90',
              icon: NeoIconType.star,
              iconColor: AppColors.accentGold,
              backgroundColor: AppColors.surfaceCard,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.9,
              ),
              itemCount: 28, // Stages 31 to 58
              itemBuilder: (context, index) {
                final stageNum = 31 + index;
                final isCompleted = stageNum < 42;
                final isActive = stageNum == 42;
                final isLocked = stageNum > 42;

                return GestureDetector(
                  onTap: () {
                    if (!isLocked) context.push('/gameplay');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.brandPrimary.withOpacity(0.2)
                          : isCompleted
                              ? AppColors.surfaceCardElevated
                              : AppColors.surfaceCard.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive
                            ? AppColors.brandPrimary
                            : isCompleted
                                ? AppColors.surfaceBorderSubtle
                                : Colors.transparent,
                        width: isActive ? 2 : 1,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppColors.brandPrimary.withOpacity(0.4),
                                blurRadius: 12,
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isLocked)
                          const NeoIcon(type: NeoIconType.lock, size: 18, color: AppColors.textMuted)
                        else ...[
                          Text(
                            '$stageNum',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isActive ? AppColors.brandPrimary : Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isCompleted)
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                NeoIcon(type: NeoIconType.star, size: 8, color: AppColors.accentGold),
                                SizedBox(width: 2),
                                NeoIcon(type: NeoIconType.star, size: 8, color: AppColors.accentGold),
                                SizedBox(width: 2),
                                NeoIcon(type: NeoIconType.star, size: 8, color: AppColors.accentGold),
                              ],
                            )
                          else if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.brandPrimary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('PLAY', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800)),
                            ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Chapter Reward Drawer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
            ),
            child: Row(
              children: [
                const NeoIcon(type: NeoIconType.gift, size: 28, color: AppColors.accentGold),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chapter Star Chest', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      Text('6 more stars to unlock 500 Coins', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                NeoButton(
                  text: 'CLAIM',
                  height: 36,
                  variant: NeoButtonVariant.secondary,
                  onPressed: null, // Locked
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
