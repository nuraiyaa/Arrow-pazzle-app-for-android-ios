import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/providers/progress_provider.dart';
import '../../../domain/models/game_mode.dart';
import '../../../shared/widgets/neo_badge.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_icon.dart';

class GameModesScreen extends ConsumerStatefulWidget {
  const GameModesScreen({super.key});

  @override
  ConsumerState<GameModesScreen> createState() => _GameModesScreenState();
}

class _GameModesScreenState extends ConsumerState<GameModesScreen> {
  DifficultyTier _selectedDifficulty = DifficultyTier.hard;

  @override
  Widget build(BuildContext context) {
    final currentLevel = ref.watch(progressNotifierProvider);
    final coins = ref.watch(progressNotifierProvider.notifier).coins;
    final timedBest = ref.watch(progressNotifierProvider.notifier).timedHighScore;

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
            child: NeoBadge.coins(coins),
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
                          color: AppColors.accentSecondary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.accentSecondary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    GameModeType.relaxed.description,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildDifficultyPill(DifficultyTier.easy),
                      const SizedBox(width: 8),
                      _buildDifficultyPill(DifficultyTier.hard),
                      const SizedBox(width: 8),
                      _buildDifficultyPill(DifficultyTier.master),
                    ],
                  ),
                  const SizedBox(height: 20),
                  NeoButton(
                    text: 'CONTINUE STAGE $currentLevel',
                    subtext: '${_selectedDifficulty.displayName} Tier (${_selectedDifficulty.boardWidth}x${_selectedDifficulty.boardHeight})',
                    icon: NeoIconType.play,
                    width: double.infinity,
                    onPressed: () => context.push(
                      '/gameplay?mode=relaxed&level=$currentLevel&diff=${_selectedDifficulty.name}',
                    ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          NeoIcon(type: NeoIconType.trophy, size: 24, color: AppColors.accentPurple),
                          SizedBox(width: 10),
                          Text('Challenge Mode', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      Text('WEEKLY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.accentPurple)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    GameModeType.challenge.description,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  NeoButton(
                    text: 'ENTER CHALLENGE #1',
                    subtext: '7x7 Matrix • 2 Rock Obstacles',
                    variant: NeoButtonVariant.secondary,
                    width: double.infinity,
                    onPressed: () => context.push('/gameplay?mode=challenge&level=1'),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          NeoIcon(type: NeoIconType.stopwatch, size: 24, color: AppColors.accentCyan),
                          SizedBox(width: 10),
                          Text('Timed Rush', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      if (timedBest > 0)
                        Text(
                          'Best: $timedBest pts',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.accentGold),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    GameModeType.timed.description,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  NeoButton(
                    text: 'START 60s BLITZ',
                    subtext: '+1.5s per clear • Combo Multipliers',
                    variant: NeoButtonVariant.secondary,
                    width: double.infinity,
                    onPressed: () => context.push('/gameplay?mode=timed&level=1'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyPill(DifficultyTier tier) {
    final isSelected = _selectedDifficulty == tier;
    return GestureDetector(
      onTap: () => setState(() => _selectedDifficulty = tier),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary : AppColors.surfaceBorder,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.brandPrimary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          tier.displayName,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
