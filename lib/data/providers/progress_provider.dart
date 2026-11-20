import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/progress_service.dart';

final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService();
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

  int getStars(int level) => _service.getStarsForLevel(level);
  bool isUnlocked(int level) => _service.isLevelUnlocked(level);

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
}

final progressNotifierProvider = NotifierProvider<ProgressNotifier, int>(ProgressNotifier.new);
