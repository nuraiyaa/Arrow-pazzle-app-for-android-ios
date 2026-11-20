import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/providers/progress_provider.dart';
import '../../../shared/widgets/neo_badge.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_icon.dart';

class LevelSelectionScreen extends ConsumerWidget {
  const LevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedLevel = ref.watch(progressNotifierProvider);
    final totalStars = ref.watch(progressNotifierProvider.notifier).totalStars;

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
            Text('CHAPTER 1 & 2', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            Text('Stages 1 - 40', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: NeoBadge(
              text: '$totalStars ★',
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
              itemCount: 40, // Stages 1 to 40
              itemBuilder: (context, index) {
                final stageNum = 1 + index;
                final isCompleted = stageNum < unlockedLevel;
                final isActive = stageNum == unlockedLevel;
                final isLocked = stageNum > unlockedLevel;
                final stars = ref.watch(progressNotifierProvider.notifier).getStars(stageNum);

                return GestureDetector(
                  onTap: () {
                    if (!isLocked) {
                      context.push('/gameplay?mode=relaxed&level=$stageNum');
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.brandPrimary.withValues(alpha: 0.2)
                          : isCompleted
                              ? AppColors.surfaceCardElevated
                              : AppColors.surfaceCard.withValues(alpha: 0.4),
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
                                color: AppColors.brandPrimary.withValues(alpha: 0.4),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                NeoIcon(type: NeoIconType.star, size: 8, color: stars >= 1 ? AppColors.accentGold : AppColors.textMuted),
                                const SizedBox(width: 2),
                                NeoIcon(type: NeoIconType.star, size: 8, color: stars >= 2 ? AppColors.accentGold : AppColors.textMuted),
                                const SizedBox(width: 2),
                                NeoIcon(type: NeoIconType.star, size: 8, color: stars >= 3 ? AppColors.accentGold : AppColors.textMuted),
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Chapter Star Chest', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      Text('$totalStars / 60 Stars collected', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                NeoButton(
                  text: 'CLAIM',
                  height: 36,
                  variant: NeoButtonVariant.secondary,
                  onPressed: totalStars >= 60 ? () {} : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
