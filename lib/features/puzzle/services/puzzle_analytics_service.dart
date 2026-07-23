class PuzzleAnalyticsService {
  const PuzzleAnalyticsService._();

  static Future<void> levelStarted({
    required String worldId,
    required int level,
  }) async {
    // سيتم ربط Firebase Analytics لاحقاً
  }

  static Future<void> levelCompleted({
    required String worldId,
    required int level,
    required int stars,
    required int moves,
    required int seconds,
  }) async {
    // سيتم ربط Firebase Analytics لاحقاً
  }

  static Future<void> worldOpened({
    required String worldId,
  }) async {
    // سيتم ربط Firebase Analytics لاحقاً
  }

  static Future<void> rewardClaimed({
    required String rewardType,
    required int amount,
  }) async {
    // سيتم ربط Firebase Analytics لاحقاً
  }

  static Future<void> adWatched({
    required String adType,
  }) async {
    // سيتم ربط Firebase Analytics لاحقاً
  }

  static Future<void> hintUsed({
    required String worldId,
    required int level,
  }) async {
    // سيتم ربط Firebase Analytics لاحقاً
  }

  static Future<void> resetAnalytics() async {
    // لا شيء حالياً
  }
}