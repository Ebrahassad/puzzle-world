class PlayerProfile {
  final int coins;
  final int gems;
  final int hints;

  final int adsWatched;
  final int completedPuzzles;

  final int unlockedWorlds;

  const PlayerProfile({
    this.coins = 0,
    this.gems = 0,
    this.hints = 3,
    this.adsWatched = 0,
    this.completedPuzzles = 0,
    this.unlockedWorlds = 1,
  });

  PlayerProfile copyWith({
    int? coins,
    int? gems,
    int? hints,
    int? adsWatched,
    int? completedPuzzles,
    int? unlockedWorlds,
  }) {
    return PlayerProfile(
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      hints: hints ?? this.hints,
      adsWatched: adsWatched ?? this.adsWatched,
      completedPuzzles:
          completedPuzzles ?? this.completedPuzzles,
      unlockedWorlds:
          unlockedWorlds ?? this.unlockedWorlds,
    );
  }
}
