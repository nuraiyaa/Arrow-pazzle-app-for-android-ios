import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_icon.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

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
        title: const Text('LEADERBOARD', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Top 3 Podium
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildPodiumRank(rank: 2, name: 'NeonBlade', score: '4,690', height: 110, color: Colors.grey.shade300),
                const SizedBox(width: 14),
                _buildPodiumRank(rank: 1, name: 'CipherMaster', score: '4,820', height: 140, color: AppColors.accentGold, isWinner: true),
                const SizedBox(width: 14),
                _buildPodiumRank(rank: 3, name: 'ArrowVortex', score: '4,510', height: 95, color: Colors.amber.shade700),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Scrollable List for ranks 4-10
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildPlayerRow(4, 'QuantumShift', '4,320 Stars'),
                _buildPlayerRow(5, 'AeroGrid', '4,180 Stars'),
                _buildPlayerRow(6, 'PulseVector', '3,950 Stars'),
                _buildPlayerRow(7, 'VortexChaser', '3,810 Stars'),
                _buildPlayerRow(8, 'EchoZenith', '3,640 Stars'),
              ],
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
            child: const Row(
              children: [
                Text(
                  '#42',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.brandPrimary),
                ),
                SizedBox(width: 14),
                NeoIcon(type: NeoIconType.user, size: 24, color: AppColors.brandPrimary),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Player_8492 (You)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      Text('Top 5% • Stage 42', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Text('1,450 Stars', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.accentGold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumRank({
    required int rank,
    required String name,
    required String score,
    required double height,
    required Color color,
    bool isWinner = false,
  }) {
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
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('#$rank', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
              const SizedBox(height: 4),
              Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(score, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerRow(int rank, String name, String score) {
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
          Text('#$rank', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
          const SizedBox(width: 14),
          const NeoIcon(type: NeoIconType.user, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          Text(score, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accentGold)),
        ],
      ),
    );
  }
}
