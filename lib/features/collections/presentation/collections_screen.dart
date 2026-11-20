import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/ads/neo_banner_ad_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/providers/progress_provider.dart';
import '../../../domain/models/skin_model.dart';
import '../../../shared/widgets/neo_badge.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_icon.dart';

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coins = ref.watch(progressNotifierProvider.notifier).coins;
    final equippedSkin = ref.watch(progressNotifierProvider.notifier).equippedSkin;
    final unlockedSkinIds = ref.watch(progressNotifierProvider.notifier).unlockedSkinIds;

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
            child: NeoBadge.coins(coins),
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
              borderColor: equippedSkin.primaryColor,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentSecondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'CURRENTLY EQUIPPED',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.accentSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceCardElevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: equippedSkin.primaryColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: equippedSkin.primaryColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: NeoIcon(type: NeoIconType.arrowUp, size: 40, color: equippedSkin.primaryColor),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(equippedSkin.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text('${equippedSkin.rarity} • ${equippedSkin.perkText}', style: TextStyle(fontSize: 12, color: equippedSkin.primaryColor)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ARROW SKINS & THEMES',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 12),

            // Skins Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ArrowSkin.allSkins.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final skin = ArrowSkin.allSkins[index];
                final isEquipped = skin.id == equippedSkin.id;
                final isUnlocked = unlockedSkinIds.contains(skin.id);

                return NeoCard(
                  padding: const EdgeInsets.all(12),
                  borderColor: isEquipped ? skin.primaryColor : null,
                  hasGlow: isEquipped,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceBackground,
                          shape: BoxShape.circle,
                          border: Border.all(color: skin.primaryColor.withValues(alpha: 0.3)),
                        ),
                        child: NeoIcon(type: NeoIconType.arrowUp, size: 28, color: skin.primaryColor),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        skin.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        skin.rarity,
                        style: TextStyle(fontSize: 10, color: skin.primaryColor, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      if (isEquipped)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accentSecondary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('EQUIPPED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.accentSecondary)),
                        )
                      else if (isUnlocked)
                        NeoButton(
                          text: 'EQUIP',
                          height: 30,
                          onPressed: () {
                            ref.read(progressNotifierProvider.notifier).equipSkin(skin.id);
                          },
                        )
                      else if (skin.unlockType == SkinUnlockType.coins)
                        NeoButton(
                          text: 'BUY ${skin.costCoins}',
                          height: 30,
                          variant: NeoButtonVariant.rewarded,
                          onPressed: coins >= skin.costCoins
                              ? () async {
                                  final ok = await ref.read(progressNotifierProvider.notifier).unlockSkin(skin.id);
                                  if (ok) {
                                    ref.read(progressNotifierProvider.notifier).equipSkin(skin.id);
                                  }
                                }
                              : null,
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceCardElevated,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            skin.unlockType == SkinUnlockType.stage
                                ? 'Stage ${skin.requiredStage}'
                                : '${skin.requiredTimedScore} pts',
                            style: const TextStyle(fontSize: 9, color: AppColors.textMuted, fontWeight: FontWeight.w700),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const NeoBannerAdWidget(),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
