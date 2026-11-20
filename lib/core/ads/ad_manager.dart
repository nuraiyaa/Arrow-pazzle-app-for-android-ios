import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_constants.dart';

enum AdType {
  banner,
  interstitial,
  rewarded,
}

abstract class IAdManager {
  Future<void> initialize();
  bool canShowInterstitial();
  void recordLevelCompleted();
  Future<bool> showInterstitialAd({VoidCallback? onDismissed});
  Future<bool> showRewardedAd({
    required void Function(int rewardAmount) onRewardEarned,
    VoidCallback? onFailed,
  });
  void dispose();
}

/// Centralized AdManager handling AdMob lifecycle, frequency capping,
/// duplicate reward prevention, and offline/test resilience.
class AdManager implements IAdManager {
  static AdManager? _instance;
  static AdManager get instance => _instance ??= AdManager();

  bool _isInitialized = false;
  bool _mockMode = false;
  int _completedLevelsSinceLastAd = 0;
  DateTime? _lastInterstitialTime;

  // Interstitial Ad Caching
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;

  // Rewarded Ad Caching
  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  // Frequency Configuration
  int interstitialFrequency = AdConstants.defaultInterstitialFrequency;
  int interstitialCooldownSeconds = AdConstants.interstitialCooldownSeconds;

  AdManager({bool mockMode = false}) {
    _mockMode = mockMode;
  }

  bool get isInitialized => _isInitialized;
  int get completedLevelsSinceLastAd => _completedLevelsSinceLastAd;
  bool get isMobilePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (!isMobilePlatform || _mockMode) {
      _isInitialized = true;
      return;
    }

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      // Preload ads in background
      preloadInterstitial();
      preloadRewarded();
    } catch (e) {
      debugPrint('[AdManager] Initialization error (graceful fallback): $e');
      _isInitialized = true; // Still allow app to function smoothly
    }
  }

  /// Increments the level counter for frequency capping
  @override
  void recordLevelCompleted() {
    _completedLevelsSinceLastAd++;
  }

  /// Checks if an interstitial ad is eligible to be shown based on level frequency & cooldown
  @override
  bool canShowInterstitial() {
    if (_completedLevelsSinceLastAd < interstitialFrequency) {
      return false;
    }

    if (_lastInterstitialTime != null) {
      final elapsedSeconds =
          DateTime.now().difference(_lastInterstitialTime!).inSeconds;
      if (elapsedSeconds < interstitialCooldownSeconds) {
        return false;
      }
    }

    return true;
  }

  /// Preloads an interstitial ad for seamless display
  void preloadInterstitial() {
    if (!isMobilePlatform || _mockMode || _isInterstitialLoading || _interstitialAd != null) {
      return;
    }

    _isInterstitialLoading = true;
    InterstitialAd.load(
      adUnitId: AdConstants.interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdManager] Interstitial failed to load: $error');
          _interstitialAd = null;
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  /// Shows an interstitial ad between level transitions with frequency capping
  @override
  Future<bool> showInterstitialAd({VoidCallback? onDismissed}) async {
    if (!canShowInterstitial()) {
      onDismissed?.call();
      return false;
    }

    _completedLevelsSinceLastAd = 0;
    _lastInterstitialTime = DateTime.now();

    if (!isMobilePlatform || _mockMode) {
      // Mock/desktop fast-forward for smooth development and testing
      onDismissed?.call();
      return true;
    }

    if (_interstitialAd == null) {
      preloadInterstitial();
      onDismissed?.call();
      return false;
    }

    final completer = Completer<bool>();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        preloadInterstitial();
        onDismissed?.call();
        if (!completer.isCompleted) completer.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        preloadInterstitial();
        onDismissed?.call();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await _interstitialAd!.show();
    return completer.future;
  }

  /// Preloads a rewarded ad
  void preloadRewarded() {
    if (!isMobilePlatform || _mockMode || _isRewardedLoading || _rewardedAd != null) {
      return;
    }

    _isRewardedLoading = true;
    RewardedAd.load(
      adUnitId: AdConstants.rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdManager] Rewarded ad failed to load: $error');
          _rewardedAd = null;
          _isRewardedLoading = false;
        },
      ),
    );
  }

  /// Shows a rewarded ad. Rewards are verified and awarded ONCE.
  @override
  Future<bool> showRewardedAd({
    required void Function(int rewardAmount) onRewardEarned,
    VoidCallback? onFailed,
  }) async {
    if (!isMobilePlatform || _mockMode) {
      // In mock/test/desktop mode, simulate successful ad view with 1x reward
      onRewardEarned(1);
      return true;
    }

    if (_rewardedAd == null) {
      preloadRewarded();
      onFailed?.call();
      return false;
    }

    final completer = Completer<bool>();
    bool rewardGiven = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        preloadRewarded();
        if (!completer.isCompleted) completer.complete(rewardGiven);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        preloadRewarded();
        onFailed?.call();
        if (!completer.isCompleted) completer.complete(false);
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        if (!rewardGiven) {
          rewardGiven = true;
          onRewardEarned(reward.amount.toInt());
        }
      },
    );

    return completer.future;
  }

  /// Reset internal counters (useful for unit tests)
  void resetForTest() {
    _completedLevelsSinceLastAd = 0;
    _lastInterstitialTime = null;
    _interstitialAd = null;
    _rewardedAd = null;
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
  }
}
