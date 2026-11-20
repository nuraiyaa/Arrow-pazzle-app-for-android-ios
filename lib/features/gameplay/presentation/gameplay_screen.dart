import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/ads/neo_banner_ad_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/providers/ad_provider.dart';
import '../../../data/providers/progress_provider.dart';
import '../../../domain/engine/game_session.dart';
import '../../../domain/engine/reverse_puzzle_generator.dart';
import '../../../domain/models/game_mode.dart';
import '../../../domain/models/level_model.dart';
import '../../../shared/widgets/neo_badge.dart';
import '../../../shared/widgets/neo_button.dart';
import '../../../shared/widgets/neo_card.dart';
import '../../../shared/widgets/neo_icon.dart';
import 'widgets/arrow_board_canvas.dart';

class GameplayScreen extends ConsumerStatefulWidget {
  final GameModeType mode;
  final int levelNumber;
  final DifficultyTier difficulty;

  const GameplayScreen({
    super.key,
    this.mode = GameModeType.relaxed,
    this.levelNumber = 1,
    this.difficulty = DifficultyTier.hard,
  });

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen> {
  late GameSession _session;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startNewGame() {
    _timer?.cancel();

    final config = LevelConfig.forLevel(
      levelNumber: widget.levelNumber,
      mode: widget.mode,
      difficulty: widget.difficulty,
    );

    final genConfig = PuzzleGenerationConfig(
      width: config.gridWidth,
      height: config.gridHeight,
      arrowCount: config.arrowCount,
      obstacleCount: config.obstacleCount,
      seed: config.levelNumber * 100 + config.mode.index * 10 + config.difficulty.index,
    );

    final board = ReversePuzzleGenerator.generate(genConfig);
    _session = GameSession(board: board, config: config);

    // If Timed Mode, start periodic ticker
    if (_session.isTimedMode) {
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (!mounted) return;
        setState(() {
          final justEnded = _session.tick(0.1);
          if (justEnded) {
            timer.cancel();
            _showDefeatDialog(isTimeOut: true);
          }
        });
      });
    }
  }

  void _onArrowTapped(String arrowId) {
    final audioHaptic = ref.read(audioHapticServiceProvider);
    audioHaptic.onArrowTap();

    setState(() {
      final result = _session.tapArrow(arrowId);
      if (result.outcome == TapOutcome.levelWon) {
        _timer?.cancel();
        audioHaptic.onVictory();
        // Give 480ms for the final arrow to complete its satisfying glide off-screen
        Future.delayed(const Duration(milliseconds: 480), () {
          if (mounted) _onVictory();
        });
      } else if (result.outcome == TapOutcome.arrowEscaped) {
        audioHaptic.onArrowEscape();
      } else if (result.outcome == TapOutcome.collisionError) {
        audioHaptic.onCollisionError();
      } else if (result.outcome == TapOutcome.outOfHearts) {
        _timer?.cancel();
        audioHaptic.onCollisionError();
        // Give 350ms for bump & shake recoil animation before showing defeat modal
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) _showDefeatDialog(isTimeOut: false);
        });
      } else if (result.outcome == TapOutcome.outOfTime) {
        _timer?.cancel();
        _showDefeatDialog(isTimeOut: true);
      }
    });
  }

  void _onVictory() {
    final stars = _session.calculateStars();
    if (widget.mode == GameModeType.timed) {
      ref.read(progressNotifierProvider.notifier).saveTimedScore(_session.score);
    } else {
      ref.read(progressNotifierProvider.notifier).completeLevel(widget.levelNumber, stars);
    }
    _showVictoryDialog(stars);
  }

  void _onHintRequested() async {
    final hasHint = await ref.read(progressNotifierProvider.notifier).consumeHint();
    if (hasHint) {
      setState(() {
        _session.requestHint();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hints left! Watch an ad or buy with coins.')),
        );
      }
    }
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
    final coins = ref.watch(progressNotifierProvider.notifier).coins;
    final equippedSkin = ref.watch(progressNotifierProvider.notifier).equippedSkin;
    final hintsCount = ref.watch(progressNotifierProvider.notifier).hints;

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
                    onPressed: _showPauseDialog,
                    height: 42,
                    width: 42,
                  ),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getModeColor().withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _getModeColor().withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          _getModeHeader(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: _getModeColor(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.mode.displayName.toUpperCase()} • ${_session.board.remainingCount} LEFT',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (!_session.isTimedMode) ...[
                        NeoBadge.hearts(_session.hearts, maxHearts: _session.maxHearts),
                        const SizedBox(width: 8),
                      ],
                      NeoBadge.coins(coins),
                    ],
                  ),
                ],
              ),
            ),

            // Timed Mode Header: Countdown Bar & Score
            if (_session.isTimedMode) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const NeoIcon(type: NeoIconType.stopwatch, size: 16, color: AppColors.accentCyan),
                            const SizedBox(width: 6),
                            Text(
                              '${_session.remainingTimeSeconds.toStringAsFixed(1)}s',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.accentCyan),
                            ),
                          ],
                        ),
                        if (_session.comboStreak > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentGold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.accentGold),
                            ),
                            child: Text(
                              '${_session.comboStreak}x COMBO',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.accentGold),
                            ),
                          ),
                        Text(
                          'Score: ${_session.score}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_session.remainingTimeSeconds / 60.0).clamp(0.0, 1.0),
                        backgroundColor: AppColors.surfaceCardElevated,
                        valueColor: AlwaysStoppedAnimation(
                          _session.remainingTimeSeconds < 10 ? AppColors.accentWarning : AppColors.accentCyan,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Spacer(),

            // CustomPainter Arrow Board Canvas
            Center(
              child: ArrowBoardCanvas(
                board: _session.board,
                skin: equippedSkin,
                activeHintId: _session.activeHintArrowId,
                collidingArrowId: _session.lastCollidingArrowId,
                onArrowTapped: _onArrowTapped,
                size: widget.mode == GameModeType.challenge ? 340 : 320,
              ),
            ),

            const Spacer(),

            // Tactical Action Controls Dock
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
                    badge: 'x$hintsCount',
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

            const SizedBox(height: 16),

            // AdMob Banner Dock (Non-intrusive bottom placement)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: NeoBannerAdWidget(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Color _getModeColor() {
    switch (widget.mode) {
      case GameModeType.relaxed:
        return AppColors.brandPrimary;
      case GameModeType.challenge:
        return AppColors.accentPurple;
      case GameModeType.timed:
        return AppColors.accentCyan;
    }
  }

  String _getModeHeader() {
    switch (widget.mode) {
      case GameModeType.relaxed:
        return 'STAGE ${widget.levelNumber}';
      case GameModeType.challenge:
        return 'CHALLENGE #${widget.levelNumber}';
      case GameModeType.timed:
        return 'TIMED RUSH';
    }
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

  void _showVictoryDialog(int stars) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  NeoIcon(type: NeoIconType.star, size: 30, color: stars >= 1 ? AppColors.accentGold : AppColors.textMuted),
                  const SizedBox(width: 8),
                  NeoIcon(type: NeoIconType.star, size: 40, color: stars >= 2 ? AppColors.accentGold : AppColors.textMuted),
                  const SizedBox(width: 8),
                  NeoIcon(type: NeoIconType.star, size: 30, color: stars >= 3 ? AppColors.accentGold : AppColors.textMuted),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                AppStrings.stageComplete,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              Text(
                widget.mode == GameModeType.timed
                    ? 'Final Score: ${_session.score} Points!'
                    : 'Solved in ${_session.movesCount} Moves! Accuracy: 100%',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              NeoButton(
                text: AppStrings.claimDouble,
                subtext: '+100 Coins (Watch Short Video)',
                variant: NeoButtonVariant.rewarded,
                width: double.infinity,
                onPressed: () async {
                  final adManager = ref.read(adManagerProvider);
                  await adManager.showRewardedAd(
                    onRewardEarned: (reward) {
                      ref.read(progressNotifierProvider.notifier).addCoins(100);
                    },
                    onFailed: () {
                      // Graceful fallback for offline / test
                      ref.read(progressNotifierProvider.notifier).addCoins(50);
                    },
                  );
                  if (ctx.mounted) ctx.pop();
                  _advanceNextLevel();
                },
              ),
              const SizedBox(height: 12),
              NeoButton(
                text: AppStrings.nextLevel,
                width: double.infinity,
                onPressed: () {
                  ctx.pop();
                  _advanceNextLevel();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _advanceNextLevel() {
    final adManager = ref.read(adManagerProvider);
    adManager.recordLevelCompleted();

    if (adManager.canShowInterstitial()) {
      adManager.showInterstitialAd(
        onDismissed: () => _navigateToNextLevel(),
      );
    } else {
      _navigateToNextLevel();
    }
  }

  void _navigateToNextLevel() {
    if (!mounted) return;
    if (widget.mode == GameModeType.timed) {
      _startNewGame();
    } else {
      context.go('/gameplay?mode=${widget.mode.name}&level=${widget.levelNumber + 1}&diff=${widget.difficulty.name}');
    }
  }

  void _showDefeatDialog({required bool isTimeOut}) {
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
              NeoIcon(
                type: isTimeOut ? NeoIconType.stopwatch : NeoIconType.heart,
                size: 48,
                color: AppColors.accentWarning,
              ),
              const SizedBox(height: 16),
              Text(
                isTimeOut ? 'Time Ran Out!' : AppStrings.outOfMoves,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.accentWarning),
              ),
              const SizedBox(height: 8),
              Text(
                'Only ${_session.board.remainingCount} arrows were left to escape!',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              NeoButton(
                text: isTimeOut ? 'WATCH AD (+15s TIME)' : 'WATCH AD (+1 LIFE)',
                variant: NeoButtonVariant.primary,
                width: double.infinity,
                onPressed: () async {
                  final adManager = ref.read(adManagerProvider);
                  await adManager.showRewardedAd(
                    onRewardEarned: (reward) {
                      if (ctx.mounted) ctx.pop();
                      setState(() {
                        if (isTimeOut) {
                          _session.remainingTimeSeconds = 15;
                        } else {
                          _session.hearts = 1;
                        }
                      });
                    },
                    onFailed: () {
                      if (ctx.mounted) ctx.pop();
                      setState(() {
                        if (isTimeOut) {
                          _session.remainingTimeSeconds = 15;
                        } else {
                          _session.hearts = 1;
                        }
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              NeoButton(
                text: 'RESTART',
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
