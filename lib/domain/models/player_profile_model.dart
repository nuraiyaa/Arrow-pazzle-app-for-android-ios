import 'dart:convert';

/// Represents player profile information for offline and cloud synchronization
class PlayerProfile {
  final String id;
  final String displayName;
  final String avatarSkinId;
  final int level;
  final int xp;
  final int coins;
  final int totalStars;
  final int timedHighScore;
  final DateTime lastSyncTime;
  final bool isAnonymous;

  const PlayerProfile({
    required this.id,
    required this.displayName,
    this.avatarSkinId = 'classic_obsidian',
    this.level = 1,
    this.xp = 0,
    this.coins = 2450,
    this.totalStars = 0,
    this.timedHighScore = 0,
    required this.lastSyncTime,
    this.isAnonymous = true,
  });

  PlayerProfile copyWith({
    String? id,
    String? displayName,
    String? avatarSkinId,
    int? level,
    int? xp,
    int? coins,
    int? totalStars,
    int? timedHighScore,
    DateTime? lastSyncTime,
    bool? isAnonymous,
  }) {
    return PlayerProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      avatarSkinId: avatarSkinId ?? this.avatarSkinId,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      totalStars: totalStars ?? this.totalStars,
      timedHighScore: timedHighScore ?? this.timedHighScore,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'avatarSkinId': avatarSkinId,
      'level': level,
      'xp': xp,
      'coins': coins,
      'totalStars': totalStars,
      'timedHighScore': timedHighScore,
      'lastSyncTime': lastSyncTime.toIso8601String(),
      'isAnonymous': isAnonymous,
    };
  }

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      id: json['id'] as String? ?? 'guest_player',
      displayName: json['displayName'] as String? ?? 'Player_8492',
      avatarSkinId: json['avatarSkinId'] as String? ?? 'classic_obsidian',
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      coins: json['coins'] as int? ?? 2450,
      totalStars: json['totalStars'] as int? ?? 0,
      timedHighScore: json['timedHighScore'] as int? ?? 0,
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.tryParse(json['lastSyncTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      isAnonymous: json['isAnonymous'] as bool? ?? true,
    );
  }

  /// Merges local progress with cloud progress using conflict-resolution rules
  PlayerProfile mergeWith(PlayerProfile cloud) {
    return PlayerProfile(
      id: cloud.id.isNotEmpty ? cloud.id : id,
      displayName: cloud.displayName.isNotEmpty ? cloud.displayName : displayName,
      avatarSkinId: avatarSkinId,
      level: level > cloud.level ? level : cloud.level,
      xp: xp > cloud.xp ? xp : cloud.xp,
      coins: coins > cloud.coins ? coins : cloud.coins,
      totalStars: totalStars > cloud.totalStars ? totalStars : cloud.totalStars,
      timedHighScore: timedHighScore > cloud.timedHighScore ? timedHighScore : cloud.timedHighScore,
      lastSyncTime: DateTime.now(),
      isAnonymous: isAnonymous && cloud.isAnonymous,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}
