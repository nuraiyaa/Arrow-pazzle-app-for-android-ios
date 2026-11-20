import 'package:flutter/foundation.dart';

/// Official Google AdMob Test Ad Unit IDs
/// Documentation: https://developers.google.com/admob/android/test-ads
class AdConstants {
  // Application IDs (Official Google Test IDs)
  static const String androidAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String iosAppId = 'ca-app-pub-3940256099942544~1458002511';

  // Android Test Ad Units
  static const String androidBannerUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String androidInterstitialUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String androidRewardedUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // iOS Test Ad Units
  static const String iosBannerUnitId = 'ca-app-pub-3940256099942544/2934735716';
  static const String iosInterstitialUnitId = 'ca-app-pub-3940256099942544/4411468910';
  static const String iosRewardedUnitId = 'ca-app-pub-3940256099942544/1712485313';

  /// Platform-aware banner unit ID
  static String get bannerUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return androidBannerUnitId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iosBannerUnitId;
    }
    return androidBannerUnitId;
  }

  /// Platform-aware interstitial unit ID
  static String get interstitialUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return androidInterstitialUnitId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iosInterstitialUnitId;
    }
    return androidInterstitialUnitId;
  }

  /// Platform-aware rewarded unit ID
  static String get rewardedUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return androidRewardedUnitId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iosRewardedUnitId;
    }
    return androidRewardedUnitId;
  }

  // Frequency controls
  /// Number of completed levels between interstitial ads
  static const int defaultInterstitialFrequency = 3;

  /// Cooldown seconds between interstitial ads
  static const int interstitialCooldownSeconds = 45;
}
