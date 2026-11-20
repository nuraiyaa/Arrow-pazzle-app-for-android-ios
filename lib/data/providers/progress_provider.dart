import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/skin_model.dart';
import '../services/audio_haptic_service.dart';
import '../services/heart_timer_service.dart';
import '../services/progress_service.dart';

final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService();
});

final audioHapticServiceProvider = Provider<AudioHapticService>((ref) {
  return AudioHapticService();
});

class ProgressNotifier extends Notifier<int> {
  ProgressService get _service => ref.read(progressServiceProvider);

  @override
  int build() {
    return _service.unlockedLevel;
  }

  int get coins => _service.coins;
  int get totalStars => _service.totalStars;
  int get timedHighScore => _service.timedHighScore;
  int get hints => _service.hints;
  int get xp => _service.xp;
  int get playerLevel => _service.playerLevel;
  int get streakDay => _service.streakDay;
  String get equippedSkinId => _service.equippedSkinId;
  ArrowSkin get equippedSkin => ArrowSkin.getById(_service.equippedSkinId);
  Set<String> get unlockedSkinIds => _service.unlockedSkinIds;

  HeartRegenResult getHeartStatus() => _service.getHeartStatus();
  int getStars(int level) => _service.getStarsForLevel(level);
  bool isUnlocked(int level) => _service.isLevelUnlocked(level);
  bool isSkinUnlocked(String id) => _service.isSkinUnlocked(id);

  Future<void> completeLevel(int level, int stars, {int coins = 50}) async {
    await _service.recordLevelComplete(levelNumber: level, stars: stars, coinsEarned: coins);
    state = _service.unlockedLevel;
  }

  Future<void> saveTimedScore(int score) async {
    await _service.recordTimedScore(score);
    state = _service.unlockedLevel;
  }

  Future<void> addCoins(int amount) async {
    await _service.addCoins(amount);
    state = _service.unlockedLevel;
  }

  Future<bool> unlockSkin(String skinId) async {
    final success = await _service.unlockSkin(skinId);
    if (success) state = _service.unlockedLevel;
    return success;
  }

  Future<void> equipSkin(String skinId) async {
    await _service.equipSkin(skinId);
    state = _service.unlockedLevel;
  }

  Future<bool> consumeHint() async {
    final success = await _service.consumeHint();
    if (success) state = _service.unlockedLevel;
    return success;
  }

  Future<void> addHints(int amount) async {
    await _service.addHints(amount);
    state = _service.unlockedLevel;
  }

  Future<bool> claimDailyReward() async {
    final success = await _service.claimDailyReward();
    if (success) state = _service.unlockedLevel;
    return success;
  }

  Future<void> consumeHeart() async {
    await _service.consumeHeart();
    state = _service.unlockedLevel;
  }

  Future<void> refillHearts() async {
    await _service.refillHearts();
    state = _service.unlockedLevel;
  }
}

final progressNotifierProvider = NotifierProvider<ProgressNotifier, int>(ProgressNotifier.new);
