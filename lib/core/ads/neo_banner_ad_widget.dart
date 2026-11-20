import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_colors.dart';
import '../../shared/widgets/neo_icon.dart';
import 'ad_constants.dart';

/// Clean Neo-styled Banner Ad Widget with AdMob integration & zero-jitter fallback
class NeoBannerAdWidget extends StatefulWidget {
  final AdSize adSize;

  const NeoBannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
  });

  @override
  State<NeoBannerAdWidget> createState() => _NeoBannerAdWidgetState();
}

class _NeoBannerAdWidgetState extends State<NeoBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  bool get _isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    _loadBanner();
  }

  void _loadBanner() {
    if (!_isMobile) return;

    _bannerAd = BannerAd(
      adUnitId: AdConstants.bannerUnitId,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('[NeoBannerAd] Failed to load: $error');
          ad.dispose();
          if (mounted) {
            setState(() {
              _bannerAd = null;
              _isLoaded = false;
            });
          }
        },
      ),
    );

    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.adSize.width.toDouble();
    final height = widget.adSize.height.toDouble();

    if (_isMobile && _isLoaded && _bannerAd != null) {
      return Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Polished Neo Test Banner placeholder (for Desktop/Simulators/Offline)
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceCard.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceBorderSubtle),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.brandPrimary.withValues(alpha: 0.4)),
            ),
            child: const Text(
              'Ad',
              style: TextStyle(
                color: AppColors.brandPrimary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const NeoIcon(
            type: NeoIconType.star,
            size: 14,
            color: AppColors.accentGold,
          ),
          const SizedBox(width: 6),
          const Flexible(
            child: Text(
              'Official AdMob Test Banner • Arrow Escape',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
