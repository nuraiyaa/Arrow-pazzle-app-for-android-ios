import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/providers/backend_provider.dart';
import '../../../domain/models/leaderboard_entry_model.dart';
import '../../../domain/models/skin_model.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_icon.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWeekly = ref.watch(leaderboardModeProvider);
    final profile = ref.watch(playerProfileProvider);
    final entriesAsync = ref.watch(leaderboardEntriesProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: NeoButton.icon(
          icon: NeoIconType.chevronLeft,
          onPressed: () => context.pop(),
        ),
        title: const Text('LEADERBOARD', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Mode Tab Switcher
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.surfaceBorderSubtle),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      'Weekly League',
                      isSelected: isWeekly,
                      onTap: () => ref.read(leaderboardModeProvider.notifier).setMode(true),
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      'All-Time Stars',
                      isSelected: !isWeekly,
                      onTap: () => ref.read(leaderboardModeProvider.notifier).setMode(false),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Leaderboard Content
          Expanded(
            child: entriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary)),
              error: (err, _) => Center(child: Text('Error loading scores: $err')),
              data: (entries) {
                if (entries.isEmpty) return const SizedBox();

                final top1 = entries.isNotEmpty ? entries[0] : null;
                final top2 = entries.length > 1 ? entries[1] : null;
                final top3 = entries.length > 2 ? entries[2] : null;
                final remaining = entries.length > 3 ? entries.sublist(3) : <LeaderboardEntry>[];

                return Column(
                  children: [
                    // Top 3 Podium Showcase
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (top2 != null)
                            _buildPodiumRank(
                              rank: 2,
                              name: top2.displayName,
                              score: '${top2.stars} ★',
                              height: 110,
                              color: Colors.grey.shade300,
                              skinId: top2.avatarSkinId,
                            ),
                          const SizedBox(width: 14),
                          if (top1 != null)
                            _buildPodiumRank(
                              rank: 1,
                              name: top1.displayName,
                              score: '${top1.stars} ★',
                              height: 140,
                              color: AppColors.accentGold,
                              isWinner: true,
                              skinId: top1.avatarSkinId,
                            ),
                          const SizedBox(width: 14),
                          if (top3 != null)
                            _buildPodiumRank(
                              rank: 3,
                              name: top3.displayName,
                              score: '${top3.stars} ★',
                              height: 95,
                              color: Colors.amber.shade700,
                              skinId: top3.avatarSkinId,
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Scrollable List for ranks 4+
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: remaining.length,
                        itemBuilder: (context, index) {
                          final item = remaining[index];
                          return _buildPlayerRow(item);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Sticky Bottom "Your Rank" Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              border: Border(top: BorderSide(color: AppColors.brandPrimary, width: 1.5)),
            ),
            child: Row(
              children: [
                const Text(
                  '#42',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.brandPrimary),
                ),
                const SizedBox(width: 14),
                NeoIcon(type: NeoIconType.user, size: 24, color: AppColors.brandPrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.displayName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      Text('Top 5% • Level ${profile.level}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Text(
                  '${profile.totalStars} Stars',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.accentGold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodiumRank({
    required int rank,
    required String name,
    required String score,
    required double height,
    required Color color,
    required String skinId,
    bool isWinner = false,
  }) {
    final skin = ArrowSkin.getById(skinId);

    return Column(
      children: [
        if (isWinner)
          const NeoIcon(type: NeoIconType.star, size: 20, color: AppColors.accentGold),
        const SizedBox(height: 4),
        Container(
          width: 84,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surfaceCardElevated,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('#$rank', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
              const SizedBox(height: 2),
              NeoIcon(type: NeoIconType.arrowUp, size: 16, color: skin.primaryColor),
              const SizedBox(height: 2),
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(score, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerRow(LeaderboardEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorderSubtle),
      ),
      child: Row(
        children: [
          Text('#${entry.rank}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          const SizedBox(width: 14),
          const NeoIcon(type: NeoIconType.user, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(entry.displayName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceCardElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(entry.rankDelta, style: const TextStyle(fontSize: 10, color: AppColors.accentSecondary, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Text('${entry.stars} ★', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accentGold)),
        ],
      ),
    );
  }
}
