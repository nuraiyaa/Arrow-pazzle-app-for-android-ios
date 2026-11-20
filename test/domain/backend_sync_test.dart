import 'package:flutter_test/flutter_test.dart';
import 'package:arrow_puzzle_game/domain/models/player_profile_model.dart';
import 'package:arrow_puzzle_game/data/services/backend_sync_service.dart';
import 'package:arrow_puzzle_game/data/services/progress_service.dart';

void main() {
  group('Backend & Cloud Sync - Player Profile & Merging Tests', () {
    test('PlayerProfile JSON serialization and deserialization', () {
      final now = DateTime.now();
      final profile = PlayerProfile(
        id: 'user_123',
        displayName: 'NeoMaster',
        level: 5,
        xp: 2400,
        coins: 1500,
        totalStars: 42,
        timedHighScore: 2800,
        lastSyncTime: now,
      );

      final json = profile.toJson();
      final restored = PlayerProfile.fromJson(json);

      expect(restored.id, 'user_123');
      expect(restored.displayName, 'NeoMaster');
      expect(restored.level, 5);
      expect(restored.coins, 1500);
      expect(restored.totalStars, 42);
      expect(restored.timedHighScore, 2800);
    });

    test('PlayerProfile conflict resolution picks highest progress metrics', () {
      final now = DateTime.now();
      // Local has higher stars and coins, but cloud has higher timed score
      final local = PlayerProfile(
        id: 'user_123',
        displayName: 'NeoMaster',
        level: 8,
        xp: 3800,
        coins: 3000,
        totalStars: 60,
        timedHighScore: 1500,
        lastSyncTime: now.subtract(const Duration(hours: 1)),
      );

      final cloud = PlayerProfile(
        id: 'user_123',
        displayName: 'NeoMaster',
        level: 7,
        xp: 3500,
        coins: 2500,
        totalStars: 50,
        timedHighScore: 3200, // Higher
        lastSyncTime: now.subtract(const Duration(minutes: 10)),
      );

      final merged = local.mergeWith(cloud);

      expect(merged.level, 8); // Max of (8, 7)
      expect(merged.totalStars, 60); // Max of (60, 50)
      expect(merged.coins, 3000); // Max of (3000, 2500)
      expect(merged.timedHighScore, 3200); // Max of (1500, 3200)
    });
  });

  group('Backend & Cloud Sync - Offline Resilience & Leaderboard Tests', () {
    test('BackendSyncService online sync succeeds', () async {
      final progress = ProgressService();
      final backend = BackendSyncService(progress);

      final profile = PlayerProfile(
        id: 'test_user',
        displayName: 'Player 1',
        level: 3,
        lastSyncTime: DateTime.now(),
      );

      final synced = await backend.syncProfile(profile);
      expect(backend.status, SyncStatus.success);
      expect(synced.id, 'test_user');
    });

    test('BackendSyncService offline fallback never crashes or blocks execution', () async {
      final progress = ProgressService();
      final backend = BackendSyncService(progress);

      // Simulate offline / disconnected network
      backend.setNetworkSimulation(false);
      expect(backend.isOnline, isFalse);

      final profile = PlayerProfile(
        id: 'test_user_offline',
        displayName: 'Offline Player',
        level: 2,
        lastSyncTime: DateTime.now(),
      );

      // Should return local profile without throwing
      final result = await backend.syncProfile(profile);
      expect(backend.status, SyncStatus.offline);
      expect(result.displayName, 'Offline Player');

      // Leaderboard offline call also returns cached fallback without crashing
      final offlineLeaderboard = await backend.fetchLeaderboard(isWeekly: true);
      expect(offlineLeaderboard.isNotEmpty, isTrue);
      expect(offlineLeaderboard.first.rank, 1);
    });

    test('Leaderboard entries fetch returns structured ranking', () async {
      final progress = ProgressService();
      final backend = BackendSyncService(progress);

      final weekly = await backend.fetchLeaderboard(isWeekly: true);
      expect(weekly.length, 10);
      expect(weekly.first.displayName, 'CipherMaster');
      expect(weekly.first.rank, 1);

      final allTime = await backend.fetchLeaderboard(isWeekly: false);
      expect(allTime.length, 5);
      expect(allTime.first.displayName, 'ApexArrow');
    });
  });
}
