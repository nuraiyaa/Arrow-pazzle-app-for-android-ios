import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_puzzle_game/core/ads/ad_constants.dart';
import 'package:arrow_puzzle_game/core/ads/ad_manager.dart';

void main() {
  group('AdConstants Configuration Tests', () {
    test('Official Google Test Ad Unit IDs are properly configured', () {
      expect(AdConstants.androidBannerUnitId, 'ca-app-pub-3940256099942544/6300978111');
      expect(AdConstants.androidInterstitialUnitId, 'ca-app-pub-3940256099942544/1033173712');
      expect(AdConstants.androidRewardedUnitId, 'ca-app-pub-3940256099942544/5224354917');

      expect(AdConstants.iosBannerUnitId, 'ca-app-pub-3940256099942544/2934735716');
      expect(AdConstants.iosInterstitialUnitId, 'ca-app-pub-3940256099942544/4411468910');
      expect(AdConstants.iosRewardedUnitId, 'ca-app-pub-3940256099942544/1712485313');

      expect(AdConstants.defaultInterstitialFrequency, 3);
      expect(AdConstants.interstitialCooldownSeconds, 45);
    });
  });

  group('AdManager Frequency Capping & Lifecycle Tests', () {
    late AdManager adManager;

    setUp(() {
      adManager = AdManager(mockMode: true);
      adManager.resetForTest();
    });

    test('AdManager initializes without errors in mock/fallback mode', () async {
      await adManager.initialize();
      expect(adManager.isInitialized, isTrue);
    });

    test('Interstitial frequency capping allows ads only after configured level completions', () {
      expect(adManager.completedLevelsSinceLastAd, 0);
      expect(adManager.canShowInterstitial(), isFalse);

      // Level 1 complete
      adManager.recordLevelCompleted();
      expect(adManager.completedLevelsSinceLastAd, 1);
      expect(adManager.canShowInterstitial(), isFalse);

      // Level 2 complete
      adManager.recordLevelCompleted();
      expect(adManager.completedLevelsSinceLastAd, 2);
      expect(adManager.canShowInterstitial(), isFalse);

      // Level 3 complete (Frequency threshold reached)
      adManager.recordLevelCompleted();
      expect(adManager.completedLevelsSinceLastAd, 3);
      expect(adManager.canShowInterstitial(), isTrue);
    });

    test('Showing interstitial resets level counter to 0', () async {
      adManager.recordLevelCompleted();
      adManager.recordLevelCompleted();
      adManager.recordLevelCompleted();
      expect(adManager.canShowInterstitial(), isTrue);

      bool dismissedCalled = false;
      final shown = await adManager.showInterstitialAd(
        onDismissed: () => dismissedCalled = true,
      );

      expect(shown, isTrue);
      expect(dismissedCalled, isTrue);
      expect(adManager.completedLevelsSinceLastAd, 0);
      expect(adManager.canShowInterstitial(), isFalse);
    });

    test('Rewarded ad awards reward exactly once', () async {
      int rewardCount = 0;
      int rewardAmountGiven = 0;

      final success = await adManager.showRewardedAd(
        onRewardEarned: (amount) {
          rewardCount++;
          rewardAmountGiven = amount;
        },
      );

      expect(success, isTrue);
      expect(rewardCount, 1); // Strictly single reward granted
      expect(rewardAmountGiven, 1);
    });
  });
}
