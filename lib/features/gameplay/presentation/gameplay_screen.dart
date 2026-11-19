import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/engine/game_session.dart';
import '../../../domain/engine/reverse_puzzle_generator.dart';
import '../../../shared/widgets/neo_badge.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_icon.dart';
import 'widgets/arrow_board_canvas.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  late GameSession _session;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    // Generate a guaranteed 100% solvable puzzle
    final board = ReversePuzzleGenerator.generate(
      const PuzzleGenerationConfig(width: 6, height: 6, arrowCount: 20),
    );
    _session = GameSession(board: board);
  }

  void _onArrowTapped(String arrowId) {
    setState(() {
      final result = _session.tapArrow(arrowId);
      if (result.outcome == TapOutcome.levelWon) {
        _showVictoryDialog();
      } else if (result.outcome == TapOutcome.outOfHearts) {
        _showDefeatDialog();
      }
    });
  }

  void _onHintRequested() {
    setState(() {
      _session.requestHint();
    });
  }

  void _onUndo() {
    setState(() {
      _session.undo();
    });
  }

  void _onRestart() {
    setState(() {
      _startNewGame();
    });
  }

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
                    onPressed: () => _showPauseDialog(),
                    height: 42,
                    width: 42,
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.brandPrimary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          'STAGE 42 (${_session.board.remainingCount} LEFT)',
                          style: const TextStyle(
                            fontSize: 13,
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
                      NeoBadge.hearts(_session.hearts, maxHearts: _session.maxHearts),
                      const SizedBox(width: 8),
                      NeoBadge.coins(2450),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // CustomPainter Interactive Arrow Board Canvas
            Center(
              child: ArrowBoardCanvas(
                board: _session.board,
                activeHintId: _session.activeHintArrowId,
                collidingArrowId: _session.lastCollidingArrowId,
                onArrowTapped: _onArrowTapped,
                size: 330,
              ),
            ),

            const Spacer(),

            // Tactical Control Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildToolButton(
                    icon: NeoIconType.undo,
                    label: AppStrings.undo,
                    badge: _session.canUndo ? '✓' : null,
                    onTap: _session.canUndo ? _onUndo : () {},
                  ),
                  _buildToolButton(
                    icon: NeoIconType.hint,
                    label: AppStrings.hint,
                    badge: 'x2',
                    isGold: true,
                    onTap: _onHintRequested,
                  ),
                  _buildToolButton(
                    icon: NeoIconType.refresh,
                    label: AppStrings.restart,
                    onTap: _onRestart,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Non-intrusive Banner Placement
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.surfaceBorderSubtle),
              ),
              child: const Center(
                child: Text(
                  'ADVERTISEMENT (ADMOB BANNER DOCK)',
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

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: NeoCard(
          hasGlow: true,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NeoIcon(type: NeoIconType.star, size: 32, color: AppColors.accentGold),
                  SizedBox(width: 8),
                  NeoIcon(type: NeoIconType.star, size: 40, color: AppColors.accentGold),
                  SizedBox(width: 8),
                  NeoIcon(type: NeoIconType.star, size: 32, color: AppColors.accentGold),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                AppStrings.stageComplete,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              Text(
                'Solved in ${_session.movesCount} Moves! Accuracy: 100%',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              NeoButton(
                text: AppStrings.claimDouble,
                subtext: '+240 Coins (Watch Short Video)',
                variant: NeoButtonVariant.rewarded,
                width: double.infinity,
                onPressed: () {
                  ctx.pop();
                  _onRestart();
                },
              ),
              const SizedBox(height: 12),
              NeoButton(
                text: AppStrings.nextLevel,
                width: double.infinity,
                onPressed: () {
                  ctx.pop();
                  _onRestart();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDefeatDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: NeoCard(
          borderColor: AppColors.accentWarning,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const NeoIcon(type: NeoIconType.heart, size: 48, color: AppColors.accentWarning),
              const SizedBox(height: 16),
              const Text(
                AppStrings.outOfMoves,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.accentWarning),
              ),
              const SizedBox(height: 8),
              Text(
                'Only ${_session.board.remainingCount} arrows were left to escape!',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              NeoButton(
                text: 'WATCH AD (+1 LIFE)',
                variant: NeoButtonVariant.primary,
                width: double.infinity,
                onPressed: () {
                  ctx.pop();
                  setState(() {
                    _session.hearts = 1;
                  });
                },
              ),
              const SizedBox(height: 12),
              NeoButton(
                text: 'RESTART STAGE',
                variant: NeoButtonVariant.secondary,
                width: double.infinity,
                onPressed: () {
                  ctx.pop();
                  _onRestart();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPauseDialog() {
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
