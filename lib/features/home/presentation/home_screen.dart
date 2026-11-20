import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/ads/neo_banner_ad_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/providers/progress_provider.dart';
import '../../../shared/widgets/neo_badge.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_icon.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlockedLevel = ref.watch(progressNotifierProvider);
    final coins = ref.watch(progressNotifierProvider.notifier).coins;

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // 1. Top Status HUD Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeoBadge.level(14),
                  Row(
                    children: [
                      NeoBadge.coins(coins),
                      const SizedBox(width: 8),
                      NeoBadge.hearts(3),
                    ],
                  ),
                  NeoButton.icon(
                    icon: NeoIconType.settings,
                    onPressed: () => context.push('/settings'),
                    height: 40,
                    width: 40,
                  ),
                ],
              ),

              // Scrollable Responsive Middle Section
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 10),
                        // 2. Hero Branding Section
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceCardElevated,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: AppColors.brandPrimary.withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.brandPrimary.withValues(alpha: 0.3),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: NeoIcon(
                                    type: NeoIconType.arrowUp,
                                    size: 44,
                                    color: AppColors.brandPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                AppStrings.appTitle.toUpperCase(),
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppStrings.tagline,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.accentCyan,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 3. Play Cards Grid / Quick Actions
                        Row(
                          children: [
                            // Continue Level Card
                            Expanded(
                              flex: 3,
                              child: NeoCard(
                                hasGlow: true,
                                padding: const EdgeInsets.all(18),
                                onTap: () => context.push('/gameplay?level=$unlockedLevel'),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.brandPrimary.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            'STAGE $unlockedLevel',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.brandPrimary,
                                            ),
                                          ),
                                        ),
                                        const NeoIcon(
                                          type: NeoIconType.play,
                                          size: 20,
                                          color: AppColors.brandPrimary,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      AppStrings.play,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Continue journey',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Modes Selector Card
                            Expanded(
                              flex: 2,
                              child: NeoCard(
                                padding: const EdgeInsets.all(18),
                                onTap: () => context.push('/modes'),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    NeoIcon(
                                      type: NeoIconType.trophy,
                                      size: 22,
                                      color: AppColors.accentGold,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'MODES',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      '3 Variations',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // 4. Daily Rewards & Streak Card
                        NeoCard(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              const NeoIcon(type: NeoIconType.gift, size: 28, color: AppColors.accentGold),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Daily Reward Active', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                    SizedBox(height: 2),
                                    Text('+50 Coins ready', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              NeoButton(
                                text: 'CLAIM',
                                height: 36,
                                variant: NeoButtonVariant.rewarded,
                                onPressed: () {
                                  ref.read(progressNotifierProvider.notifier).addCoins(50);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Claimed 50 Daily Coins!')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // 5. Bottom Navigation Dock
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.surfaceBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      icon: const NeoIcon(type: NeoIconType.play, size: 22, color: AppColors.brandPrimary),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const NeoIcon(type: NeoIconType.star, size: 22, color: AppColors.textSecondary),
                      onPressed: () => context.push('/levels'),
                    ),
                    IconButton(
                      icon: const NeoIcon(type: NeoIconType.trophy, size: 22, color: AppColors.textSecondary),
                      onPressed: () => context.push('/leaderboard'),
                    ),
                    IconButton(
                      icon: const NeoIcon(type: NeoIconType.gift, size: 22, color: AppColors.textSecondary),
                      onPressed: () => context.push('/collections'),
                    ),
                  ],
                ),
              ),

              // 6. AdMob Banner (Non-intrusive bottom placement)
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: NeoBannerAdWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
