import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/neo_badge.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_icon.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                      NeoBadge.coins(2450),
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

              const Spacer(flex: 2),

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
                          color: AppColors.brandPrimary.withOpacity(0.5),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandPrimary.withOpacity(0.3),
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

              const Spacer(flex: 2),

              // 3. Primary Action Area (PLAY & Modes)
              NeoButton(
                text: AppStrings.play,
                subtext: 'Stage 42 • Relaxed',
                icon: NeoIconType.play,
                height: 64,
                width: double.infinity,
                onPressed: () => context.push('/gameplay'),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: NeoCard(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      onTap: () => context.push('/modes'),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NeoIcon(type: NeoIconType.trophy, size: 24, color: AppColors.accentPurple),
                          SizedBox(height: 10),
                          Text('Challenge', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          SizedBox(height: 2),
                          Text('5 Hard Puzzles', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoCard(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      onTap: () => context.push('/modes'),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NeoIcon(type: NeoIconType.stopwatch, size: 24, color: AppColors.accentCyan),
                          SizedBox(height: 10),
                          Text('Timed Rush', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          SizedBox(height: 2),
                          Text('60s Blitz', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
                          Text('Day 3/7 Streak', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          SizedBox(height: 2),
                          Text('+50 Coins ready', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    NeoButton(
                      text: 'CLAIM',
                      height: 36,
                      variant: NeoButtonVariant.rewarded,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // 5. Bottom Navigation Dock
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.surfaceBorderSubtle),
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
            ],
          ),
        ),
      ),
    );
  }
}
