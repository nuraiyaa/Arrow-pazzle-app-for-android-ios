import 'dart:async';
import '../../domain/models/leaderboard_entry_model.dart';
import '../../domain/models/player_profile_model.dart';
import 'progress_service.dart';

enum SyncStatus {
  idle,
  syncing,
  success,
  offline,
  error,
}

abstract class IBackendSyncService {
  Future<PlayerProfile> syncProfile(PlayerProfile localProfile);
  Future<List<LeaderboardEntry>> fetchLeaderboard({required bool isWeekly});
  bool get isOnline;
}

/// Robust Offline-First Backend Service with graceful fallback
class BackendSyncService implements IBackendSyncService {
  final ProgressService progressService;
  bool _mockNetworkAvailable = true;
  DateTime _lastSyncTime = DateTime.now();
  SyncStatus _currentStatus = SyncStatus.idle;

  BackendSyncService(this.progressService);

  @override
  bool get isOnline => _mockNetworkAvailable;

  DateTime get lastSyncTime => _lastSyncTime;
  SyncStatus get status => _currentStatus;

  /// Used for testing offline simulation
  void setNetworkSimulation(bool isAvailable) {
    _mockNetworkAvailable = isAvailable;
  }

  @override
  Future<PlayerProfile> syncProfile(PlayerProfile localProfile) async {
    _currentStatus = SyncStatus.syncing;

    if (!_mockNetworkAvailable) {
      _currentStatus = SyncStatus.offline;
      // Graceful offline fallback: immediately return local profile without blocking
      return localProfile;
    }

    try {
      // Simulate non-blocking fast cloud synchronization
      await Future.delayed(const Duration(milliseconds: 50));

      final cloudProfile = PlayerProfile(
        id: localProfile.id,
        displayName: localProfile.displayName,
        level: localProfile.level,
        xp: localProfile.xp,
        coins: localProfile.coins,
        totalStars: localProfile.totalStars,
        timedHighScore: localProfile.timedHighScore,
        lastSyncTime: DateTime.now(),
        isAnonymous: localProfile.isAnonymous,
      );

      final merged = localProfile.mergeWith(cloudProfile);
      _lastSyncTime = DateTime.now();
      _currentStatus = SyncStatus.success;
      return merged;
    } catch (_) {
      _currentStatus = SyncStatus.error;
      return localProfile;
    }
  }

  @override
  Future<List<LeaderboardEntry>> fetchLeaderboard({required bool isWeekly}) async {
    if (!_mockNetworkAvailable) {
      // Offline fallback: returns cached local mock entries
      return _generateFallbackLeaderboard(isWeekly);
    }

    await Future.delayed(const Duration(milliseconds: 50));
    return _generateFallbackLeaderboard(isWeekly);
  }

  List<LeaderboardEntry> _generateFallbackLeaderboard(bool isWeekly) {
    if (isWeekly) {
      return const [
        LeaderboardEntry(rank: 1, playerId: 'p1', displayName: 'CipherMaster', stars: 4820, avatarSkinId: 'golden_royal', rankDelta: '▲ 1', playerLevel: 50),
        LeaderboardEntry(rank: 2, playerId: 'p2', displayName: 'NeonBlade', stars: 4690, avatarSkinId: 'cyber_neon', rankDelta: '—', playerLevel: 38),
        LeaderboardEntry(rank: 3, playerId: 'p3', displayName: 'ArrowVortex', stars: 4510, avatarSkinId: 'classic_obsidian', rankDelta: '▲ 3', playerLevel: 34),
        LeaderboardEntry(rank: 4, playerId: 'p4', displayName: 'QuantumShift', stars: 4320, avatarSkinId: 'void_amethyst', rankDelta: '▲ 2', playerLevel: 31),
        LeaderboardEntry(rank: 5, playerId: 'p5', displayName: 'AeroGrid', stars: 4180, avatarSkinId: 'solar_flare', rankDelta: '—', playerLevel: 29),
        LeaderboardEntry(rank: 6, playerId: 'p6', displayName: 'PulseVector', stars: 3950, avatarSkinId: 'emerald_matrix', rankDelta: '▼ 1', playerLevel: 28),
        LeaderboardEntry(rank: 7, playerId: 'p7', displayName: 'VortexChaser', stars: 3810, avatarSkinId: 'cyber_neon', rankDelta: '▲ 4', playerLevel: 26),
        LeaderboardEntry(rank: 8, playerId: 'p8', displayName: 'EchoZenith', stars: 3640, avatarSkinId: 'classic_obsidian', rankDelta: '—', playerLevel: 25),
        LeaderboardEntry(rank: 9, playerId: 'p9', displayName: 'GlitchRunner', stars: 3500, avatarSkinId: 'golden_royal', rankDelta: '▼ 2', playerLevel: 24),
        LeaderboardEntry(rank: 10, playerId: 'p10', displayName: 'StarWeaver', stars: 3380, avatarSkinId: 'void_amethyst', rankDelta: '▲ 1', playerLevel: 22),
      ];
    } else {
      return const [
        LeaderboardEntry(rank: 1, playerId: 'p1', displayName: 'ApexArrow', stars: 12450, avatarSkinId: 'void_amethyst', rankDelta: '—', playerLevel: 99),
        LeaderboardEntry(rank: 2, playerId: 'p2', displayName: 'CipherMaster', stars: 11800, avatarSkinId: 'golden_royal', rankDelta: '—', playerLevel: 50),
        LeaderboardEntry(rank: 3, playerId: 'p3', displayName: 'ZenithSolve', stars: 10920, avatarSkinId: 'cyber_neon', rankDelta: '▲ 1', playerLevel: 45),
        LeaderboardEntry(rank: 4, playerId: 'p4', displayName: 'NeonBlade', stars: 9800, avatarSkinId: 'cyber_neon', rankDelta: '▼ 1', playerLevel: 38),
        LeaderboardEntry(rank: 5, playerId: 'p5', displayName: 'ArrowMaster', stars: 9200, avatarSkinId: 'classic_obsidian', rankDelta: '—', playerLevel: 35),
      ];
    }
  }
}
