import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../engine/puzzle_piece.dart';


class PuzzleProgressManager {

  PuzzleProgressManager._();



  //==================================================
  // 🔑 Keys
  //==================================================


  static const String progressKey =
      "puzzle_current_progress";


  static const String starsKey =
      "puzzle_total_stars";


  static const String coinsKey =
      "puzzle_coins";


  static const String gemsKey =
      "puzzle_gems";


  static const String hintsKey =
      "puzzle_hints";


  static const String lastWorldKey =
      "puzzle_last_world";


  static const String lastLevelKey =
      "puzzle_last_level";


  static const String completedLevelsKey =
      "puzzle_completed_levels";


  static const String claimedRewardsKey =
      "puzzle_claimed_rewards";


  static const String unlockedLevelsKey =
      "puzzle_unlocked_levels";


  static const String levelStarsKey =
      "puzzle_level_stars";



static const String gameStateKey =
      "puzzle_game_state";


  static const String gamesPlayedKey =
      "puzzle_games_played";


  static const String totalMovesKey =
      "puzzle_total_moves";


  static const String bestTimeKey =
      "puzzle_best_time";



  static const String achievementsKey =
      "puzzle_achievements";


  static const String experienceKey =
      "puzzle_experience";


  static const String dailyMissionKey =
      "puzzle_daily_missions";

static const String purchasedLevelsKey =
    "puzzle_purchased_levels";

static const String purchasedIslandsKey =
    "puzzle_purchased_islands";

static const String privateIslandKey =
    "private_island_unlocked";

static const String adsBalanceKey =
    "puzzle_ads_balance";


static const String purchasedStarsKey =
    "puzzle_star_unlocks";


static const String purchasedGemsKey =
    "puzzle_gem_unlocks";


static const String levelAdsKey =
    "puzzle_level_ads";




  //==================================================
  // Preferences
  //==================================================


  static Future<SharedPreferences> get _prefs async {

    return await SharedPreferences.getInstance();

  }




  //==================================================
  // 💾 حفظ حالة البازل الحالية
  //==================================================


  static Future<void> saveProgress({

    required String puzzleId,

    required String levelId,

    required List<PuzzlePiece> pieces,

    required int moves,

    required int seconds,

  }) async {


    final prefs = await _prefs;



    final data = {


      "puzzleId": puzzleId,


      "levelId": levelId,


      "moves": moves,


      "seconds": seconds,



      "pieces": pieces.map((piece){


        return {


          "id": piece.id,


          "row": piece.row,


          "column": piece.col,
"x": piece.currentPosition.dx,
"y": piece.currentPosition.dy,
"placed": piece.isPlaced,
        };


      }).toList(),


    };



    await prefs.setString(

      progressKey,

      jsonEncode(data),

    );


  }



static Future<void> saveGameState(
    Map<String,dynamic> state,
    ) async {

  final prefs = await _prefs;

  await prefs.setString(
    gameStateKey,
    jsonEncode(state),
  );

}

  //==================================================
  // 📖 قراءة حالة البازل
  //==================================================


  static Future<Map<String,dynamic>?>

  loadProgress() async {


    final prefs = await _prefs;


    final value = prefs.getString(progressKey);



    if(value == null){

      return null;

    }



    return Map<String,dynamic>.from(

      jsonDecode(value),

    );


  }





  //==================================================
  // 🗑️ حذف حالة البازل
  //==================================================


  static Future<void> clearProgress() async {


    final prefs = await _prefs;


    await prefs.remove(

      progressKey,

    );


  }





  //==================================================
  // ⭐ نظام النجوم Golden Star
  //==================================================


  static Future<int> getStars() async {


    final prefs = await _prefs;


    return prefs.getInt(starsKey) ?? 0;


  }

static Future<int> getTotalStars() async {

  final prefs = await _prefs;

  return prefs.getInt(starsKey) ?? 0;

}


  static Future<void> addStars(

      int amount,

      ) async {


    final prefs = await _prefs;


    final current =

    prefs.getInt(starsKey) ?? 0;



    int value = current + amount;



    if(value < 0){

      value = 0;

    }



    await prefs.setInt(

      starsKey,

      value,

    );


  }




  static Future<void> saveStars(

      int value,

      ) async {


    final prefs = await _prefs;


    await prefs.setInt(

      starsKey,

      value,

    );


  }


static Future<void> saveLevelStars(
    String levelId,
    int stars,
    ) async {

  final prefs = await _prefs;

  final data =
      jsonDecode(
        prefs.getString(levelStarsKey) ?? "{}",
      );

  data[levelId] = stars;

  await prefs.setString(
    levelStarsKey,
    jsonEncode(data),
  );


}

//==================================================
// ⭐ خصم النجوم
//==================================================

static Future<bool> spendStars(
    int amount,
) async {

  if(amount <= 0){
    return false;
  }


  final prefs = await _prefs;


  final current =
      prefs.getInt(starsKey) ?? 0;



  if(current < amount){

    return false;

  }



  await prefs.setInt(
    starsKey,
    current - amount,
  );


  return true;

}






  //==================================================
  // 🪙 العملات
  //==================================================


  static Future<int> getCoins() async {


    final prefs = await _prefs;


    return prefs.getInt(coinsKey) ?? 0;


  }




  static Future<void> addCoins(

      int amount,

      ) async {


    final prefs = await _prefs;


    final current =

    prefs.getInt(coinsKey) ?? 0;



    int value = current + amount;



    if(value < 0){

      value = 0;

    }



    await prefs.setInt(

      coinsKey,

      value,

    );


  }




  static Future<void> saveCoins(

      int value,

      ) async {


    final prefs = await _prefs;


    await prefs.setInt(

      coinsKey,

      value,

    );
}

//==================================================
// 🪙 خصم العملات
//==================================================

static Future<bool> spendCoins(
    int amount,
) async {

  if(amount <= 0){
    return false;
  }


  final prefs = await _prefs;


  final current =
      prefs.getInt(coinsKey) ?? 0;



  if(current < amount){

    return false;

  }



  await prefs.setInt(
    coinsKey,
    current - amount,
  );


  return true;



  }



  //==================================================
  // 💎 الجواهر
  //==================================================


  static Future<int> getGems() async {


    final prefs = await _prefs;


    return prefs.getInt(gemsKey) ?? 0;


  }




  static Future<void> addGems(

      int amount,

      ) async {


    final prefs = await _prefs;


    final current =

    prefs.getInt(gemsKey) ?? 0;



    int value = current + amount;



    if(value < 0){

      value = 0;

    }



    await prefs.setInt(

      gemsKey,

      value,

    );


  }




  static Future<void> saveGems(

      int value,

      ) async {


    final prefs = await _prefs;


    await prefs.setInt(

      gemsKey,

      value,

    );


  }

//==================================================
// 💎 خصم الجواهر
//==================================================

static Future<bool> spendGems(
    int amount,
) async {

  if(amount <= 0){
    return false;
  }


  final prefs = await _prefs;


  final current =
      prefs.getInt(gemsKey) ?? 0;



  if(current < amount){

    return false;

  }



  await prefs.setInt(
    gemsKey,
    current - amount,
  );


  return true;

}



  //==================================================
  // 💡 التلميحات
  //==================================================


  static Future<int> getHints() async {


    final prefs = await _prefs;


    return prefs.getInt(hintsKey) ?? 0;


  }




  static Future<void> addHints(

      int amount,

      ) async {


    final prefs = await _prefs;


    final current =

    prefs.getInt(hintsKey) ?? 0;



    int value = current + amount;



    if(value < 0){

      value = 0;

    }



    await prefs.setInt(

      hintsKey,

      value,

    );


  }





  static Future<bool> useHint() async {


    final prefs = await _prefs;


    final current =

    prefs.getInt(hintsKey) ?? 0;



    if(current <= 0){

      return false;

    }



    await prefs.setInt(

      hintsKey,

      current - 1,

    );



    return true;


  }





  //==================================================
  // 🏆 المراحل المكتملة
  //==================================================


  static Future<void> completeLevel(

      String levelKey,

      ) async {


    final prefs = await _prefs;



    final levels =

    prefs.getStringList(

      completedLevelsKey,

    ) ?? [];



    if(!levels.contains(levelKey)){


      levels.add(levelKey);



      await prefs.setStringList(

        completedLevelsKey,

        levels,

      );


    }


  }





  static Future<bool> isCompleted(

      String levelKey,

      ) async {


    final prefs = await _prefs;



    final levels =

    prefs.getStringList(

      completedLevelsKey,

    ) ?? [];



    return levels.contains(levelKey);


  }





  static Future<int> getCompletedCount() async {


    final prefs = await _prefs;



    return

    (prefs.getStringList(

      completedLevelsKey,

    ) ?? []).length;


  }





  //==================================================
  // 🎁 المكافآت المستلمة
  //==================================================


  static Future<void> markRewardClaimed(

      String rewardKey,

      ) async {


    final prefs = await _prefs;



    final rewards =

    prefs.getStringList(

      claimedRewardsKey,

    ) ?? [];



    if(!rewards.contains(rewardKey)){


      rewards.add(rewardKey);



      await prefs.setStringList(

        claimedRewardsKey,

        rewards,

      );


    }


  }





  static Future<bool> isRewardClaimed(

      String rewardKey,

      ) async {


    final prefs = await _prefs;



    final rewards =

    prefs.getStringList(

      claimedRewardsKey,

    ) ?? [];



    return rewards.contains(rewardKey);


  }



//==================================================
// 🪙 أسعار فتح المراحل بالعملات
//==================================================

static int getLevelCoinCost(
    int level,
) {

  if (level <= 1) {
    return 0;
  }

  // المرحلة 2 = 100
  // المرحلة 3 = 400
  // المرحلة 4 = 800
  // المرحلة 5 = 1600
  // ثم تتضاعف التكلفة تدريجياً

  switch (level) {

    case 2:
      return 100;

    case 3:
      return 400;

    case 4:
      return 800;

    case 5:
      return 1600;

    case 6:
      return 3200;

    case 7:
      return 6400;

    case 8:
      return 12800;

    case 9:
      return 25600;

    case 10:
      return 51200;

    default:
      return 51200;
  }
}



//==================================================
// 💰 أسعار الفتح
//==================================================





// ⭐ سعر فتح المرحلة بالنجوم

static int getLevelStarCost(
    int level,
) {

  if(level <= 1){

    return 0;

  }


  return 2 + ((level - 2) ~/ 3);

}



// 💎 سعر فتح المرحلة بالجواهر

static int getLevelGemCost(
    int level,
) {

  if(level <= 1){

    return 0;

  }


  return 1 + ((level - 2) ~/ 5);

}



//==================================================
// 🏝️ أسعار فتح الجزر بالنجوم
//==================================================

static int getIslandStarCost(
    String islandId,
) {

  switch (islandId) {

    case "animals":
      return 0;

    case "nature":
      return 50;

    case "cars":
      return 75;

    case "landmarks":
      return 100;

    case "space":
      return 150;

    default:
      return 999999;
  }
}



// ⭐ شراء / فتح الجزيرة بالنجوم
//==================================================

static Future<bool> buyIslandWithStars(
    String islandId,
) async {

  // الحيوانات مفتوحة تلقائياً
  if (islandId == "animals") {

    await unlockIsland(islandId);

    return true;
  }

  // إذا كانت الجزيرة مفتوحة مسبقاً
  final unlocked =
      await isIslandUnlocked(islandId);

  if (unlocked) {
    return true;
  }

  final cost =
      getIslandStarCost(islandId);

  if (cost <= 0) {
    return false;
  }

  // الخصم الثاني:
  // خصم النجوم عند فتح الجزيرة
  final paid =
      await spendStars(cost);

  if (!paid) {
    return false;
  }

  await unlockIsland(islandId);

  final prefs = await _prefs;

  final purchased =
      prefs.getStringList(
        purchasedIslandsKey,
      ) ?? [];

  if (!purchased.contains(islandId)) {

    purchased.add(islandId);

    await prefs.setStringList(
      purchasedIslandsKey,
      purchased,
    );
  }

  return true;
}

  //==================================================
  // 🔓 فتح المراحل
  //==================================================


  static Future<void> unlockLevel(

      String levelKey,

      ) async {


    final prefs = await _prefs;



    final levels =

    prefs.getStringList(

      unlockedLevelsKey,

    ) ?? [];



    if(!levels.contains(levelKey)){


      levels.add(levelKey);



      await prefs.setStringList(

        unlockedLevelsKey,

        levels,

      );


    }


  }





  static Future<bool> isLevelUnlocked(

      String levelKey,

      ) async {


    final prefs = await _prefs;



    final levels =

    prefs.getStringList(

      unlockedLevelsKey,

    ) ?? [];



    // المستوى الأول مفتوح تلقائياً

    if(levelKey.endsWith("_level_1")){
  return true;
}



    return levels.contains(levelKey);


  }





  static Future<void> unlockNextLevel(

      String worldId,

      int currentLevel,

      ) async {


    await unlockLevel(

      "${worldId}_level_${currentLevel + 1}",

    );


  }



//==================================================
// 🪙 شراء / فتح المرحلة بالعملات
//==================================================

static Future<bool> buyLevelWithCoins(
    String levelId,
    int levelNumber,
) async {

  // المرحلة الأولى مفتوحة دائماً
  if (levelNumber <= 1) {
    await unlockLevel(levelId);
    return true;
  }

  // إذا كانت مفتوحة مسبقاً لا نخصم شيئاً
  final unlocked =
      await isLevelUnlocked(levelId);

  if (unlocked) {
    return true;
  }

  final cost =
      getLevelCoinCost(levelNumber);

  if (cost <= 0) {
    return false;
  }

  // الخصم الثاني:
  // خصم العملات عند استخدام العملة لفتح المرحلة
  final paid =
      await spendCoins(cost);

  if (!paid) {
    return false;
  }

  await unlockLevel(levelId);

  final prefs = await _prefs;

  final purchased =
      prefs.getStringList(
        purchasedLevelsKey,
      ) ?? [];

  if (!purchased.contains(levelId)) {

    purchased.add(levelId);

    await prefs.setStringList(
      purchasedLevelsKey,
      purchased,
    );
  }

  return true;
}

//==================================================
// 🔍 هل المرحلة مشتراة
//==================================================

static Future<bool> isLevelPurchased(

    String levelId,

) async {


  final prefs =
      await _prefs;


  final levels =
      prefs.getStringList(
        purchasedLevelsKey,
      ) ?? [];


  return levels.contains(levelId);

}

  //==================================================
  // 🌍 فتح العوالم
  //==================================================


  static const String unlockedWorldsKey =

      "puzzle_unlocked_worlds";





  static Future<void> unlockWorld(

      String worldId,

      ) async {


    final prefs = await _prefs;



    final worlds =

    prefs.getStringList(

      unlockedWorldsKey,

    ) ?? [];



    if(!worlds.contains(worldId)){


      worlds.add(worldId);



      await prefs.setStringList(

        unlockedWorldsKey,

        worlds,

      );


    }


  }





  static Future<bool> isWorldUnlocked(

      String worldId,

      ) async {


    final prefs = await _prefs;



    final worlds =

    prefs.getStringList(

      unlockedWorldsKey,

    ) ?? [];



    if(worldId == "world_1"){

      return true;

    }



    return worlds.contains(worldId);


  }





  static Future<void> unlockAllLevels(

      String worldId,

      ) async {


    for(int i = 1; i <= 100; i++){


      await unlockLevel(

        "${worldId}_level_$i",

      );


    }


  }

//==================================================
// ⭐ حفظ فتح بالنجوم
//==================================================

static Future<void> saveStarPurchase(
    String id,
) async {

  final prefs = await _prefs;


  final list =
      prefs.getStringList(
        purchasedStarsKey,
      ) ?? [];


  if(!list.contains(id)){

    list.add(id);


    await prefs.setStringList(
      purchasedStarsKey,
      list,
    );

  }

}


//==================================================
// 💎 استخدام الجواهر
//==================================================

static Future<bool> useGemsForUnlock(

    int amount,

) async {


  final paid =
      await spendGems(
        amount,
      );


  if(!paid){

    return false;

  }


  return true;

}

  //==================================================
  // 🎮 آخر مستوى لعب
  //==================================================

  static Future<void> saveLastPuzzle(
      String worldId,
      String levelId,
      ) async {

    final prefs = await _prefs;

    await prefs.setString(
      lastWorldKey,
      worldId,
    );

    await prefs.setString(
      lastLevelKey,
      levelId,
    );
  }



  static Future<Map<String,String>?> getLastPuzzle() async {

    final prefs = await _prefs;

    final world =
        prefs.getString(lastWorldKey);

    final level =
        prefs.getString(lastLevelKey);


    if(world == null || level == null){

      return null;

    }


    return {

      "worldId": world,

      "levelId": level,

    };

  }



  //==================================================
  // 📊 إحصائيات اللاعب
  //==================================================


  static Future<int> getGamesPlayed() async {

    final prefs = await _prefs;

    return prefs.getInt(
      gamesPlayedKey,
    ) ?? 0;

  }



  static Future<int> getTotalMoves() async {

    final prefs = await _prefs;

    return prefs.getInt(
      totalMovesKey,
    ) ?? 0;

  }



  static Future<void> addTotalMoves(
      int moves,
      ) async {


    if(moves <= 0){

      return;

    }


    final prefs = await _prefs;


    final current =
        prefs.getInt(totalMovesKey) ?? 0;


    await prefs.setInt(
      totalMovesKey,
      current + moves,
    );

  }





  static Future<int> getBestTime() async {

    final prefs = await _prefs;

    return prefs.getInt(
      bestTimeKey,
    ) ?? 0;

  }





  static Future<void> addCompletedPuzzle({

    required int moves,

    required int seconds,

  }) async {


    final prefs = await _prefs;


    final oldMoves =
        prefs.getInt(totalMovesKey) ?? 0;


    await prefs.setInt(

      totalMovesKey,

      oldMoves + moves,

    );



    final oldGames =
        prefs.getInt(gamesPlayedKey) ?? 0;


    await prefs.setInt(

      gamesPlayedKey,

      oldGames + 1,

    );




    final best =
        prefs.getInt(bestTimeKey) ?? 0;



    if(best == 0 || seconds < best){

      await prefs.setInt(

        bestTimeKey,

        seconds,

      );

    }

  }





  //==================================================
  // 🏆 الإنجازات
  //==================================================


  static Future<void> saveAchievement(
      String id,
      ) async {


    final prefs = await _prefs;


    final list =
        prefs.getStringList(
          achievementsKey,
        ) ?? [];



    if(!list.contains(id)){


      list.add(id);


      await prefs.setStringList(

        achievementsKey,

        list,

      );

    }

  }




  static Future<bool> hasAchievement(
      String id,
      ) async {


    final prefs = await _prefs;


    final list =
        prefs.getStringList(
          achievementsKey,
        ) ?? [];


    return list.contains(id);

  }





  //==================================================
  // 🎯 المهام اليومية
  //==================================================


  static Future<List<Map<String,dynamic>>>
  getDailyMissions() async {


    final prefs = await _prefs;


    final data =
        jsonDecode(

          prefs.getString(
            dailyMissionKey,
          ) ?? "[]",

        );


    return List<Map<String,dynamic>>.from(
      data,
    );

  }




  static Future<void> saveDailyMissions(
      List<Map<String,dynamic>> missions,
      ) async {


    final prefs = await _prefs;


    await prefs.setString(

      dailyMissionKey,

      jsonEncode(
        missions,
      ),

    );

  }





  //==================================================
  // ⭐ الخبرة XP
  //==================================================


  static Future<void> addExperience(
      int amount,
      ) async {


    if(amount <= 0){

      return;

    }


    final prefs = await _prefs;


    final current =
        prefs.getInt(
          experienceKey,
        ) ?? 0;



    await prefs.setInt(

      experienceKey,

      current + amount,

    );

  }




  static Future<int> getExperience() async {

    final prefs = await _prefs;


    return prefs.getInt(
      experienceKey,
    ) ?? 0;

  }

  //==================================================
  // 💾 تصدير البيانات
  //==================================================


  static Future<Map<String,dynamic>> exportData() async {


    final prefs = await _prefs;


    final data = <String,dynamic>{};



    for(final key in prefs.getKeys()){


      data[key] = prefs.get(key);


    }



    return data;


  }





  //==================================================
  // 📥 استيراد البيانات
  //==================================================


  static Future<void> importData(

      Map<String,dynamic> data,

      ) async {


    final prefs = await _prefs;



    for(final item in data.entries){


      final value = item.value;



      if(value is int){


        await prefs.setInt(

          item.key,

          value,

        );


      }


      else if(value is String){


        await prefs.setString(

          item.key,

          value,

        );


      }


      else if(value is List<String>){


        await prefs.setStringList(

          item.key,

          value,

        );


      }


    }


  }





  //==================================================
  // 📺 رصيد الإعلانات العام
  //==================================================

  static Future<int> getAdsBalance() async {

    final prefs = await _prefs;

    return prefs.getInt(
      adsBalanceKey,
    ) ?? 0;

  }



  static Future<void> addAdsBalance(
      int amount,
  ) async {

    if(amount <= 0){
      return;
    }


    final prefs = await _prefs;


    final current =
        prefs.getInt(
          adsBalanceKey,
        ) ?? 0;


    await prefs.setInt(
      adsBalanceKey,
      current + amount,
    );

  }



  static Future<bool> spendAdsBalance(
      int amount,
  ) async {

    if(amount <= 0){
      return false;
    }


    final prefs = await _prefs;


    final current =
        prefs.getInt(
          adsBalanceKey,
        ) ?? 0;



    if(current < amount){

      return false;

    }



    await prefs.setInt(
      adsBalanceKey,
      current - amount,
    );


    return true;

  }


  //==================================================
  // 📺➡️🪙 شراء العملات برصيد الإعلانات
  //==================================================

  static const int coinsPurchaseAdsCost = 50;
  static const int coinsPurchaseAmount = 100;

  static Future<bool> buyCoinsWithAds() async {

    // الخصم الأول:
    // خصم 50 مشاهدة من رصيد الإعلانات
    final paid =
        await spendAdsBalance(
          coinsPurchaseAdsCost,
        );

    if (!paid) {
      return false;
    }

    // إضافة 100 عملة
    await addCoins(
      coinsPurchaseAmount,
    );

    return true;
  }


  //==================================================
  // 📺➡️⭐ شراء نجمة برصيد الإعلانات
  //==================================================

  static const int starPurchaseAdsCost = 50;
  static const int starPurchaseAmount = 1;

  static Future<bool> buyStarWithAds() async {

    // خصم 50 مشاهدة
    final paid =
        await spendAdsBalance(
          starPurchaseAdsCost,
        );

    if (!paid) {
      return false;
    }

    // إضافة نجمة واحدة
    await addStars(
      starPurchaseAmount,
    );

    return true;
  }


  //==================================================
  // 📺➡️💎 شراء جوهرة برصيد الإعلانات
  //==================================================

  static const int gemPurchaseAdsCost = 100;
  static const int gemPurchaseAmount = 1;

  static Future<bool> buyGemWithAds() async {

    // خصم 100 مشاهدة
    final paid =
        await spendAdsBalance(
          gemPurchaseAdsCost,
        );

    if (!paid) {
      return false;
    }

    // إضافة جوهرة واحدة
    await addGems(
      gemPurchaseAmount,
    );

    return true;
  }





  //==================================================
  // 🏝️ نظام الجزر
  //==================================================


  static const String unlockedIslandsKey =

      "puzzle_unlocked_islands";



  static Future<void> unlockIsland(

      String islandId,

      ) async {



    final prefs = await _prefs;



    final islands =

    prefs.getStringList(

      unlockedIslandsKey,

    ) ?? [];





    if(!islands.contains(islandId)){


      islands.add(islandId);



      await prefs.setStringList(

        unlockedIslandsKey,

        islands,

      );


    }


  }






  static Future<bool> isIslandUnlocked(
      String islandId,
  ) async {

    if(islandId == "animals"){
      return true;
    }

    final prefs = await _prefs;

    final islands =
        prefs.getStringList(
          unlockedIslandsKey,
        ) ?? [];

    return islands.contains(islandId);
  }


//==================================================
// 🏝️ فتح الجزيرة التالية بعد إنهاء آخر مرحلة
//==================================================

static Future<void> unlockNextIsland(
    String currentIsland,
) async {

  switch(currentIsland){

    case "animals":
      await unlockIsland("nature");
      break;

    case "nature":
      await unlockIsland("cars");
      break;

    case "cars":
      await unlockIsland("landmarks");
      break;

    case "landmarks":
      await unlockIsland("space");
      break;

    case "space":
      await unlockIsland("private_island");
      break;

  }

}





  //==================================================
  // 🏝️ الجزيرة الخاصة
  //==================================================

  static const int privateIslandGemCost = 100;

  static Future<bool> buyPrivateIslandWithGems() async {

    final prefs = await _prefs;

    final alreadyUnlocked =
        prefs.getBool(privateIslandKey) ?? false;

    if (alreadyUnlocked) {
      return true;
    }

    // خصم الجواهر عند الشراء
    final paid =
        await spendGems(privateIslandGemCost);

    if (!paid) {
      return false;
    }

    await prefs.setBool(
      privateIslandKey,
      true,
    );

    return true;
  }

  static Future<bool> isPrivateIslandUnlocked() async {

    final prefs = await _prefs;

    return prefs.getBool(
      privateIslandKey,
    ) ?? false;
  }





  //==================================================
  // ⚙️ الإعدادات
  //==================================================


  static const String soundKey =

      "puzzle_sound";


  static const String vibrationKey =

      "puzzle_vibration";


  static const String darkModeKey =

      "puzzle_dark_mode";





  static Future<bool> isSoundEnabled() async {


    return (await _prefs)

        .getBool(soundKey) ?? true;


  }





  static Future<void> saveSoundEnabled(

      bool value,

      ) async {


    await (await _prefs)

        .setBool(soundKey,value);


  }






  static Future<bool> isVibrationEnabled() async {


    return (await _prefs)

        .getBool(vibrationKey) ?? true;


  }





  static Future<void> saveVibrationEnabled(

      bool value,

      ) async {


    await (await _prefs)

        .setBool(

          vibrationKey,

          value,

        );


  }





  static Future<bool> isDarkMode() async {


    return (await _prefs)

        .getBool(darkModeKey) ?? false;


  }





  static Future<void> saveDarkMode(

      bool value,

      ) async {


    await (await _prefs)

        .setBool(

          darkModeKey,

          value,

        );


  }






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

    await prefs.remove(adsBalanceKey);

    await prefs.remove(gameStateKey);

    await prefs.remove(levelAdsKey);

    await prefs.remove(purchasedLevelsKey);

    await prefs.remove(purchasedIslandsKey);

    await prefs.remove(privateIslandKey);


  }





  //==================================================
  // 🗑️ حذف كل بيانات اللاعب
  //==================================================


  static Future<void> resetAll() async {


    final prefs = await _prefs;


    await prefs.clear();


  }


}
