import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/achievement_model.dart';
import '../../domain/models/skin_model.dart';
import 'heart_timer_service.dart';

/// Comprehensive Offline Player Progress, Skins, Achievements, and Economy Service
class ProgressService {
  static const String _keyUnlockedLevel = 'unlocked_level_relaxed';
  static const String _keyLevelStars = 'level_stars_map';
  static const String _keyCoins = 'player_coins';
  static const String _keyTimedHighScore = 'timed_high_score';
  static const String _keyCompletedChallenges = 'completed_challenges';
  static const String _keyHints = 'player_hints';
  static const String _keyEquippedSkin = 'equipped_skin';
  static const String _keyUnlockedSkins = 'unlocked_skins';
  static const String _keyXp = 'player_xp';
  static const String _keyStreakDay = 'player_streak_day';
  static const String _keyLastDailyClaim = 'last_daily_claim_date';
  static const String _keyHearts = 'player_hearts';
  static const String _keyLastHeartTime = 'last_heart_timestamp';
  static const String _keyAchievements = 'unlocked_achievements';

  final SharedPreferences? _prefs;

  // In-memory state
  int _unlockedLevel = 1;
  final Map<int, int> _levelStars = {};
  int _coins = 2450;
  int _timedHighScore = 0;
  final Set<int> _completedChallenges = {};
  int _hints = 3;
  String _equippedSkinId = 'classic_obsidian';
  final Set<String> _unlockedSkinIds = {'classic_obsidian'};
  int _xp = 1420;
  int _streakDay = 3;
  DateTime? _lastDailyClaimDate;
  int _storedHearts = 3;
  DateTime _lastHeartTimestamp = DateTime.now();
  final Set<String> _unlockedAchievements = {'first_win'};

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
    _hints = _prefs.getInt(_keyHints) ?? 3;
    _equippedSkinId = _prefs.getString(_keyEquippedSkin) ?? 'classic_obsidian';
    _xp = _prefs.getInt(_keyXp) ?? 1420;
    _streakDay = _prefs.getInt(_keyStreakDay) ?? 3;
    _storedHearts = _prefs.getInt(_keyHearts) ?? 3;

    final heartTimeStr = _prefs.getString(_keyLastHeartTime);
    if (heartTimeStr != null) {
      _lastHeartTimestamp = DateTime.tryParse(heartTimeStr) ?? DateTime.now();
    }

    final dailyClaimStr = _prefs.getString(_keyLastDailyClaim);
    if (dailyClaimStr != null) {
      _lastDailyClaimDate = DateTime.tryParse(dailyClaimStr);
    }

    final starsJson = _prefs.getString(_keyLevelStars);
    if (starsJson != null) {
      try {
        final decoded = jsonDecode(starsJson) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          final level = int.tryParse(entry.key);
          if (level != null) _levelStars[level] = entry.value as int;
        }
      } catch (_) {}
    }

    final skinsList = _prefs.getStringList(_keyUnlockedSkins);
    if (skinsList != null) {
      _unlockedSkinIds.addAll(skinsList);
    }

    final achList = _prefs.getStringList(_keyAchievements);
    if (achList != null) {
      _unlockedAchievements.addAll(achList);
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
  int get hints => _hints;
  String get equippedSkinId => _equippedSkinId;
  Set<String> get unlockedSkinIds => Set.unmodifiable(_unlockedSkinIds);
  int get xp => _xp;
  int get playerLevel => (_xp ~/ 500) + 1; // 500 XP per level
  int get streakDay => _streakDay;
  Set<String> get unlockedAchievements => Set.unmodifiable(_unlockedAchievements);
  int get totalStars => _levelStars.values.fold(0, (sum, stars) => sum + stars);

  /// Computes current hearts dynamically based on regeneration timer
  HeartRegenResult getHeartStatus({DateTime? now}) {
    final result = HeartTimerService.calculateCurrentHearts(
      storedHearts: _storedHearts,
      lastTimestamp: _lastHeartTimestamp,
      now: now,
    );
    _storedHearts = result.hearts;
    _lastHeartTimestamp = result.lastHeartTimestamp;
    return result;
  }

  int getStarsForLevel(int level) => _levelStars[level] ?? 0;
  bool isLevelUnlocked(int level) => level <= _unlockedLevel;
  bool isChallengeCompleted(int challengeId) => _completedChallenges.contains(challengeId);
  bool isSkinUnlocked(String skinId) => _unlockedSkinIds.contains(skinId);

  Future<void> consumeHeart() async {
    final status = getHeartStatus();
    if (status.hearts > 0) {
      _storedHearts = status.hearts - 1;
      _lastHeartTimestamp = DateTime.now();
      await _saveToStorage();
    }
  }

  Future<void> refillHearts() async {
    _storedHearts = HeartTimerService.maxHearts;
    _lastHeartTimestamp = DateTime.now();
    await _saveToStorage();
  }

  Future<void> recordLevelComplete({
    required int levelNumber,
    required int stars,
    int coinsEarned = 50,
  }) async {
    final existingStars = _levelStars[levelNumber] ?? 0;
    if (stars > existingStars) {
      _levelStars[levelNumber] = stars;
    }

    if (levelNumber >= _unlockedLevel) {
      _unlockedLevel = levelNumber + 1;
    }

    _coins += coinsEarned;
    _xp += 150 * stars;

    // Check level achievements
    checkAndUnlockAchievement('first_win');
    if (_unlockedLevel >= 10) {
      checkAndUnlockAchievement('stage_10');
    }

    await _saveToStorage();
  }

  Future<void> recordTimedScore(int score) async {
    if (score > _timedHighScore) {
      _timedHighScore = score;
      await _prefs?.setInt(_keyTimedHighScore, _timedHighScore);
    }
    _xp += (score * 0.1).toInt();
    if (score >= 1500) {
      _unlockedSkinIds.add('solar_flare');
    }
    await _saveToStorage();
  }

  Future<bool> consumeHint() async {
    if (_hints > 0) {
      _hints--;
      await _saveToStorage();
      return true;
    }
    return false;
  }

  Future<void> addHints(int amount) async {
    _hints += amount;
    await _saveToStorage();
  }

  Future<bool> unlockSkin(String skinId) async {
    if (_unlockedSkinIds.contains(skinId)) return true;

    final skin = ArrowSkin.getById(skinId);
    if (skin.unlockType == SkinUnlockType.coins) {
      if (_coins >= skin.costCoins) {
        _coins -= skin.costCoins;
        _unlockedSkinIds.add(skinId);
        checkAndUnlockAchievement('skin_collector');
        await _saveToStorage();
        return true;
      }
      return false;
    } else if (skin.unlockType == SkinUnlockType.stage) {
      if (_unlockedLevel >= skin.requiredStage) {
        _unlockedSkinIds.add(skinId);
        checkAndUnlockAchievement('skin_collector');
        await _saveToStorage();
        return true;
      }
      return false;
    } else if (skin.unlockType == SkinUnlockType.timedScore) {
      if (_timedHighScore >= skin.requiredTimedScore) {
        _unlockedSkinIds.add(skinId);
        checkAndUnlockAchievement('skin_collector');
        await _saveToStorage();
        return true;
      }
      return false;
    }
    return false;
  }

  Future<void> equipSkin(String skinId) async {
    if (_unlockedSkinIds.contains(skinId)) {
      _equippedSkinId = skinId;
      checkAndUnlockAchievement('skin_collector');
      await _saveToStorage();
    }
  }

  Future<bool> claimDailyReward() async {
    final now = DateTime.now();
    if (_lastDailyClaimDate != null) {
      final diff = now.difference(_lastDailyClaimDate!);
      if (diff.inHours < 20) {
        return false; // Already claimed today
      }
      if (diff.inHours >= 48) {
        _streakDay = 1; // Streak reset
      } else {
        _streakDay = (_streakDay % 7) + 1; // Advance streak
      }
    } else {
      _streakDay = 1;
    }

    _lastDailyClaimDate = now;
    final rewardCoins = 50 * _streakDay;
    _coins += rewardCoins;
    _xp += 100;
    await _saveToStorage();
    return true;
  }

  bool checkAndUnlockAchievement(String achievementId) {
    if (!_unlockedAchievements.contains(achievementId)) {
      final ach = Achievement.getById(achievementId);
      _unlockedAchievements.add(achievementId);
      _coins += ach.rewardCoins;
      _saveToStorage();
      return true;
    }
    return false;
  }

  Future<void> addCoins(int amount) async {
    _coins += amount;
    await _saveToStorage();
  }

  Future<bool> spendCoins(int amount) async {
    if (_coins >= amount) {
      _coins -= amount;
      await _saveToStorage();
      return true;
    }
    return false;
  }

  Future<void> _saveToStorage() async {
    if (_prefs == null) return;
    await _prefs.setInt(_keyUnlockedLevel, _unlockedLevel);
    await _prefs.setInt(_keyCoins, _coins);
    await _prefs.setInt(_keyHints, _hints);
    await _prefs.setString(_keyEquippedSkin, _equippedSkinId);
    await _prefs.setStringList(_keyUnlockedSkins, _unlockedSkinIds.toList());
    await _prefs.setInt(_keyXp, _xp);
    await _prefs.setInt(_keyStreakDay, _streakDay);
    await _prefs.setInt(_keyHearts, _storedHearts);
    await _prefs.setString(_keyLastHeartTime, _lastHeartTimestamp.toIso8601String());
    if (_lastDailyClaimDate != null) {
      await _prefs.setString(_keyLastDailyClaim, _lastDailyClaimDate!.toIso8601String());
    }
    await _prefs.setStringList(_keyAchievements, _unlockedAchievements.toList());

    final starsMapString = <String, int>{};
    for (final entry in _levelStars.entries) {
      starsMapString[entry.key.toString()] = entry.value;
    }
    await _prefs.setString(_keyLevelStars, jsonEncode(starsMapString));

    final challengeStrings = _completedChallenges.map((e) => e.toString()).toList();
    await _prefs.setStringList(_keyCompletedChallenges, challengeStrings);
  }
}
