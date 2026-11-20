import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_puzzle_game/data/services/heart_timer_service.dart';
import 'package:arrow_puzzle_game/data/services/progress_service.dart';
import 'package:arrow_puzzle_game/data/services/audio_haptic_service.dart';
import 'package:arrow_puzzle_game/domain/models/skin_model.dart';
import 'package:arrow_puzzle_game/domain/models/achievement_model.dart';

void main() {
  group('Game Features - Heart Regeneration Timer Tests', () {
    test('HeartTimerService calculates full hearts correctly', () {
      final now = DateTime.now();
      final result = HeartTimerService.calculateCurrentHearts(
        storedHearts: 3,
        lastTimestamp: now.subtract(const Duration(hours: 2)),
        now: now,
      );

      expect(result.hearts, 3);
      expect(result.isFull, isTrue);
      expect(result.timeUntilNextHeart, Duration.zero);
    });

    test('HeartTimerService calculates elapsed regeneration', () {
      final now = DateTime.now();
      // 1 stored heart, 40 minutes have passed (2 hearts should regenerate -> total 3 max)
      final result40m = HeartTimerService.calculateCurrentHearts(
        storedHearts: 1,
        lastTimestamp: now.subtract(const Duration(minutes: 40)),
        now: now,
      );
      expect(result40m.hearts, 3);
      expect(result40m.isFull, isTrue);

      // 1 stored heart, 25 minutes have passed (1 heart regenerated -> total 2, 15m remaining)
      final result25m = HeartTimerService.calculateCurrentHearts(
        storedHearts: 1,
        lastTimestamp: now.subtract(const Duration(minutes: 25)),
        now: now,
      );
      expect(result25m.hearts, 2);
      expect(result25m.isFull, isFalse);
      expect(result25m.timeUntilNextHeart.inMinutes, 15);
    });
  });

  group('Game Features - Skins & Economy Tests', () {
    test('ArrowSkin definitions and lookup', () {
      expect(ArrowSkin.allSkins.length, 6);
      final obsidian = ArrowSkin.getById('classic_obsidian');
      expect(obsidian.name, 'Classic Obsidian');

      final cyber = ArrowSkin.getById('cyber_neon');
      expect(cyber.costCoins, 250);
    });

    test('ProgressService unlocks and equips skins', () async {
      final service = ProgressService();
      expect(service.equippedSkinId, 'classic_obsidian');
      expect(service.isSkinUnlocked('cyber_neon'), isFalse);

      final initialCoins = service.coins;
      // Unlock Cyber Neon (costs 250, unlocks 'skin_collector' achievement giving +100 coins)
      final unlockSuccess = await service.unlockSkin('cyber_neon');
      expect(unlockSuccess, isTrue);
      expect(service.coins, initialCoins - 250 + 100);
      expect(service.isSkinUnlocked('cyber_neon'), isTrue);

      // Equip skin
      await service.equipSkin('cyber_neon');
      expect(service.equippedSkinId, 'cyber_neon');
    });

    test('ProgressService fails to buy skin without enough coins', () async {
      final service = ProgressService();
      // Spend down coins
      await service.spendCoins(service.coins);
      expect(service.coins, 0);

      final bought = await service.unlockSkin('golden_royal');
      expect(bought, isFalse);
      expect(service.isSkinUnlocked('golden_royal'), isFalse);
    });
  });

  group('Game Features - Achievements & Daily Rewards Tests', () {
    test('Achievements can be unlocked and grant coin rewards', () {
      final service = ProgressService();
      final initialCoins = service.coins;

      final unlocked = service.checkAndUnlockAchievement('speed_demon');
      expect(unlocked, isTrue);
      expect(service.unlockedAchievements.contains('speed_demon'), isTrue);
      expect(service.coins, initialCoins + Achievement.getById('speed_demon').rewardCoins);

      // Second attempt doesn't grant duplicate coins
      final unlockedAgain = service.checkAndUnlockAchievement('speed_demon');
      expect(unlockedAgain, isFalse);
    });

    test('Daily Reward claims and streak advances', () async {
      final service = ProgressService();
      final initialCoins = service.coins;

      final firstClaim = await service.claimDailyReward();
      expect(firstClaim, isTrue);
      expect(service.coins, greaterThan(initialCoins));

      // Same day second claim fails (cooldown)
      final secondClaim = await service.claimDailyReward();
      expect(secondClaim, isFalse);
    });

    test('AudioHapticService handles feedback safely without throwing', () async {
      final audioHaptic = AudioHapticService();
      await audioHaptic.onArrowTap();
      await audioHaptic.onArrowEscape();
      await audioHaptic.onCollisionError();
      await audioHaptic.onVictory();
      expect(audioHaptic.isHapticsEnabled, isTrue);
    });
  });
}
