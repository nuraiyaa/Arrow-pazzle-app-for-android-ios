import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for offline player progress, unlocks, and high scores
class ProgressService {
  static const String _keyUnlockedLevel = 'unlocked_level_relaxed';
  static const String _keyLevelStars = 'level_stars_map';
  static const String _keyCoins = 'player_coins';
  static const String _keyTimedHighScore = 'timed_high_score';
  static const String _keyCompletedChallenges = 'completed_challenges';

  final SharedPreferences? _prefs;

  // In-memory cache for fast access and testing
  int _unlockedLevel = 1;
  final Map<int, int> _levelStars = {};
  int _coins = 2450;
  int _timedHighScore = 0;
  final Set<int> _completedChallenges = {};

  ProgressService([this._prefs]) {
    _loadFromStorage();
  }

  static Future<ProgressService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ProgressService(prefs);
  }

  void _loadFromStorage() {
    if (_prefs == null) return;
    _unlockedLevel = _prefs.getInt(_keyUnlockedLevel) ?? 1;
    _coins = _prefs.getInt(_keyCoins) ?? 2450;
    _timedHighScore = _prefs.getInt(_keyTimedHighScore) ?? 0;

    final starsJson = _prefs.getString(_keyLevelStars);
    if (starsJson != null) {
      try {
        final decoded = jsonDecode(starsJson) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          final level = int.tryParse(entry.key);
          if (level != null) {
            _levelStars[level] = entry.value as int;
          }
        }
      } catch (_) {}
    }

    final challengesList = _prefs.getStringList(_keyCompletedChallenges);
    if (challengesList != null) {
      for (final id in challengesList) {
        final parsed = int.tryParse(id);
        if (parsed != null) _completedChallenges.add(parsed);
      }
    }
  }

  int get unlockedLevel => _unlockedLevel;
  int get coins => _coins;
  int get timedHighScore => _timedHighScore;
  int get totalStars => _levelStars.values.fold(0, (sum, stars) => sum + stars);

  int getStarsForLevel(int level) => _levelStars[level] ?? 0;
  bool isLevelUnlocked(int level) => level <= _unlockedLevel;
  bool isChallengeCompleted(int challengeId) => _completedChallenges.contains(challengeId);

  Future<void> recordLevelComplete({
    required int levelNumber,
    required int stars,
    int coinsEarned = 50,
  }) async {
    // Record stars (keep best)
    final existingStars = _levelStars[levelNumber] ?? 0;
    if (stars > existingStars) {
      _levelStars[levelNumber] = stars;
    }

    // Unlock next level
    if (levelNumber >= _unlockedLevel) {
      _unlockedLevel = levelNumber + 1;
    }

    // Add coins
    _coins += coinsEarned;

    // Save
    await _saveToStorage();
  }

  Future<void> recordTimedScore(int score) async {
    if (score > _timedHighScore) {
      _timedHighScore = score;
      await _prefs?.setInt(_keyTimedHighScore, _timedHighScore);
    }
  }

  Future<void> recordChallengeComplete(int challengeId, {int coinsEarned = 100}) async {
    _completedChallenges.add(challengeId);
    _coins += coinsEarned;
    await _saveToStorage();
  }

  Future<void> addCoins(int amount) async {
    _coins += amount;
    await _prefs?.setInt(_keyCoins, _coins);
  }

  Future<bool> spendCoins(int amount) async {
    if (_coins >= amount) {
      _coins -= amount;
      await _prefs?.setInt(_keyCoins, _coins);
      return true;
    }
    return false;
  }

  Future<void> _saveToStorage() async {
    if (_prefs == null) return;
    await _prefs.setInt(_keyUnlockedLevel, _unlockedLevel);
    await _prefs.setInt(_keyCoins, _coins);

    final starsMapString = <String, int>{};
    for (final entry in _levelStars.entries) {
      starsMapString[entry.key.toString()] = entry.value;
    }
    await _prefs.setString(_keyLevelStars, jsonEncode(starsMapString));

    final challengeStrings = _completedChallenges.map((e) => e.toString()).toList();
    await _prefs.setStringList(_keyCompletedChallenges, challengeStrings);
  }

  Future<void> resetAll() async {
    _unlockedLevel = 1;
    _levelStars.clear();
    _coins = 250;
    _timedHighScore = 0;
    _completedChallenges.clear();
    await _prefs?.clear();
  }
}
