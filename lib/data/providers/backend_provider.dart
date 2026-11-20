import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/leaderboard_entry_model.dart';
import '../../domain/models/player_profile_model.dart';
import '../services/backend_sync_service.dart';
import 'progress_provider.dart';

final backendSyncServiceProvider = Provider<BackendSyncService>((ref) {
  final progress = ref.watch(progressServiceProvider);
  return BackendSyncService(progress);
});

class PlayerProfileNotifier extends Notifier<PlayerProfile> {
  BackendSyncService get _backend => ref.read(backendSyncServiceProvider);

  @override
  PlayerProfile build() {
    final progress = ref.watch(progressServiceProvider);
    return PlayerProfile(
      id: 'player_8492_guest',
      displayName: 'Player_8492 (You)',
      avatarSkinId: progress.equippedSkinId,
      level: progress.playerLevel,
      xp: progress.xp,
      coins: progress.coins,
      totalStars: progress.totalStars,
      timedHighScore: progress.timedHighScore,
      lastSyncTime: DateTime.now(),
      isAnonymous: true,
    );
  }

  Future<void> syncWithCloud() async {
    final updated = await _backend.syncProfile(state);
    state = updated;
  }
}

final playerProfileProvider = NotifierProvider<PlayerProfileNotifier, PlayerProfile>(
  PlayerProfileNotifier.new,
);

class LeaderboardModeNotifier extends Notifier<bool> {
  @override
  bool build() => true; // true = weekly, false = all-time

  void setMode(bool isWeekly) {
    state = isWeekly;
  }
}

final leaderboardModeProvider = NotifierProvider<LeaderboardModeNotifier, bool>(
  LeaderboardModeNotifier.new,
);

final leaderboardEntriesProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final backend = ref.watch(backendSyncServiceProvider);
  final isWeekly = ref.watch(leaderboardModeProvider);
  return backend.fetchLeaderboard(isWeekly: isWeekly);
});
