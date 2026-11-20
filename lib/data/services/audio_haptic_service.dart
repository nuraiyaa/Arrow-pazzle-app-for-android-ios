import 'package:flutter/services.dart';

class AudioHapticService {
  bool isHapticsEnabled = true;
  bool isSfxEnabled = true;
  bool isMusicEnabled = true;

  AudioHapticService({
    this.isHapticsEnabled = true,
    this.isSfxEnabled = true,
    this.isMusicEnabled = true,
  });

  Future<void> onArrowTap() async {
    if (!isHapticsEnabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  Future<void> onArrowEscape() async {
    if (!isHapticsEnabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  Future<void> onCollisionError() async {
    if (!isHapticsEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  Future<void> onVictory() async {
    if (!isHapticsEnabled) return;
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }
}
