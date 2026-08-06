  //==================================================
  // 🔄 إعادة ضبط التقدم
  //==================================================


  static Future<void> resetProgress() async {


    final prefs = await _prefs;



    await prefs.remove(progressKey);

    await prefs.remove(completedLevelsKey);

    await prefs.remove(unlockedLevelsKey);

    await prefs.remove(levelStarsKey);

    await prefs.remove(claimedRewardsKey);

    await prefs.remove(lastWorldKey);

    await prefs.remove(lastLevelKey);

    await prefs.remove(unlockedIslandsKey);

    await prefs.remove(gameStateKey);

    await prefs.remove(levelAdsKey);


  }
