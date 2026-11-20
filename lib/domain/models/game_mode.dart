/// Types of game modes supported by the game
enum GameModeType {
  relaxed,
  challenge,
  timed;

  String get displayName {
    switch (this) {
      case GameModeType.relaxed:
        return 'Relaxed Mode';
      case GameModeType.challenge:
        return 'Challenge Mode';
      case GameModeType.timed:
        return 'Timed Rush';
    }
  }

  String get description {
    switch (this) {
      case GameModeType.relaxed:
        return 'Zen puzzle solving with 3-heart safety';
      case GameModeType.challenge:
        return 'Larger grids with immovable obstacle blocks';
      case GameModeType.timed:
        return 'Fast-paced blitz against the clock';
    }
  }
}

/// Difficulty tiers
enum DifficultyTier {
  easy,
  hard,
  master;

  String get displayName {
    switch (this) {
      case DifficultyTier.easy:
        return 'Easy';
      case DifficultyTier.hard:
        return 'Hard';
      case DifficultyTier.master:
        return 'Master';
    }
  }

  int get boardWidth {
    switch (this) {
      case DifficultyTier.easy:
        return 5;
      case DifficultyTier.hard:
        return 6;
      case DifficultyTier.master:
        return 8;
    }
  }

  int get boardHeight => boardWidth;

  int get baseArrowCount {
    switch (this) {
      case DifficultyTier.easy:
        return 12;
      case DifficultyTier.hard:
        return 22;
      case DifficultyTier.master:
        return 38;
    }
  }
}
