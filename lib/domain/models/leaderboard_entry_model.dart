class LeaderboardEntry {
  final int rank;
  final String playerId;
  final String displayName;
  final int stars;
  final int score;
  final String avatarSkinId;
  final String rankDelta; // e.g. "+2", "-", "-1"
  final int playerLevel;

  const LeaderboardEntry({
    required this.rank,
    required this.playerId,
    required this.displayName,
    this.stars = 0,
    this.score = 0,
    this.avatarSkinId = 'classic_obsidian',
    this.rankDelta = '—',
    this.playerLevel = 1,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int? ?? 1,
      playerId: json['playerId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Player',
      stars: json['stars'] as int? ?? 0,
      score: json['score'] as int? ?? 0,
      avatarSkinId: json['avatarSkinId'] as String? ?? 'classic_obsidian',
      rankDelta: json['rankDelta'] as String? ?? '—',
      playerLevel: json['playerLevel'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'playerId': playerId,
      'displayName': displayName,
      'stars': stars,
      'score': score,
      'avatarSkinId': avatarSkinId,
      'rankDelta': rankDelta,
      'playerLevel': playerLevel,
    };
  }
}
