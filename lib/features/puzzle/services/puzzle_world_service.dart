import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

import '../data/puzzle_data.dart';
import '../data/puzzle_level_data.dart';

import '../managers/puzzle_progress_manager.dart';
import '../managers/reward_manager.dart';

import '../screens/puzzle_home_screen.dart';
import '../screens/puzzle_level_screen.dart';
import '../screens/puzzle_win_screen.dart';
import '../screens/wallet_screen.dart';

import '../services/puzzle_navigation_service.dart';



class PuzzleWorldService {


  const PuzzleWorldService._();




  //==================================================
  // 🌍 العوالم
  //==================================================


  static List<PuzzleModel> get worlds =>

      PuzzleData.puzzles;





  static Future<List<PuzzleModel>> loadWorlds() async {


    return PuzzleData.puzzles;


  }






  static Future<PuzzleModel?> getWorld(

      String worldId,

      ) async {



    try {



      return PuzzleData.puzzles.firstWhere(

            (world) => world.id == worldId,

      );



    } catch(_){



      return null;



    }


  }







  //==================================================
  // 🧩 المراحل
  //==================================================


  static Future<List<PuzzleLevelModel>> loadLevels(

      String worldId,

      ) async {



    return PuzzleLevelData.getLevels(

      worldId,

    );


  }







  //==================================================
  // 💰 الموارد
  //==================================================


  static Future<int> getTotalStars() async {


    return await PuzzleProgressManager.getTotalStars();


  }






  static Future<int> getCoins() async {


    return await RewardManager.getCoins();


  }






  static Future<int> getGems() async {


    return await RewardManager.getGems();


  }






  static Future<int> getHints() async {


    return await PuzzleProgressManager.getHints();


  }







  //==================================================
  // 🔓 فتح العالم
  //==================================================


  static Future<bool> isWorldUnlocked(

      PuzzleModel world,

      ) async {



    // مؤقتاً العالم الأول مفتوح

    // نظام فتح العوالم يضاف لاحقاً



    return true;



  }







  //==================================================
  // فتح شاشة العالم
  //==================================================


  static Future<void> openWorld(

      BuildContext context,

      PuzzleModel world,

      ) async {



    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>

            PuzzleLevelScreen(

              puzzle: world,

            ),

      ),

    );


  }


  //==================================================
  // 🧩 فتح المرحلة
  //==================================================


  static Future<void> openLevel(

      BuildContext context, {

        required PuzzleModel world,

        required PuzzleLevelModel level,

      }) async {



    await PuzzleNavigationService.openGame(

      context,

      puzzle: world,

      level: level,

    );


  }







  //==================================================
  // 💰 المحفظة
  //==================================================


  static Future<void> openWallet(

      BuildContext context,

      ) async {



    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>

        const WalletScreen(),

      ),

    );


  }







  //==================================================
  // 🏠 العودة للرئيسية
  //==================================================


  static Future<void> returnToHome(

      BuildContext context,

      ) async {



    await Navigator.pushAndRemoveUntil(

      context,

      MaterialPageRoute(

        builder: (_) =>

        const PuzzleHomeScreen(),

      ),

          (route) => false,

    );


  }







  //==================================================
  // ✅ إكمال المرحلة
  //==================================================


  static Future<void> completeLevel({

    required String worldId,

    required int level,

    required int stars,

  }) async {



    final levelKey =

        "${worldId}_level_$level";





    // حفظ إكمال المرحلة

    await PuzzleProgressManager.completeLevel(

      levelKey,

    );






    // حفظ نجوم المرحلة

    await PuzzleProgressManager.saveLevelStars(

      levelKey,

      stars,

    );






    // إضافة النجوم للمجموع

    await PuzzleProgressManager.addStars(

      stars,

    );






    // فتح المرحلة التالية

    await PuzzleProgressManager.unlockNextLevel(

      worldId,

      level,

    );






    // حفظ آخر مرحلة لعب

    await PuzzleProgressManager.saveLastPuzzle(

      worldId,

      "level_$level",

    );


  }







  //==================================================
  // ➡️ الانتقال للمرحلة التالية
  //==================================================


  static Future<void> goToNextLevel(

      BuildContext context, {

        required String worldId,

        required int currentLevel,

      }) async {



    await PuzzleNavigationService.openNextLevel(

      context,

      worldId: worldId,

      currentLevel: currentLevel,

    );


  }

  //==================================================
  // 🔄 إعادة المرحلة
  //==================================================


  static Future<void> replayLevel(

      BuildContext context, {

        required PuzzleModel world,

        required PuzzleLevelModel level,

      }) async {



    await PuzzleNavigationService.restartLevel(

      context,

      puzzle: world,

      level: level,

    );


  }







  //==================================================
  // 🎉 فتح شاشة الفوز
  //==================================================


  static Future<void> openWinScreen(

      BuildContext context, {

        required GameResultModel result,

        required int difficulty,

        required String worldId,

        required int level,

      }) async {



    await PuzzleNavigationService.openWin(

      context,

      result: result,

      difficulty: difficulty,

      worldId: worldId,

      level: level,

    );


  }







  //==================================================
  // ⭐ نجوم العالم
  //==================================================


  static Future<int> getWorldStars(

      String worldId,

      ) async {



    final levels =

    await loadLevels(

      worldId,

    );



    int total = 0;





    for(final level in levels){



      total +=

      await PuzzleProgressManager.getLevelStars(

        "${worldId}_${level.id}",

      );


    }





    return total;


  }







  //==================================================
  // 🏆 هل العالم مكتمل
  //==================================================


  static Future<bool> isWorldCompleted(

      String worldId,

      ) async {



    final levels =

    await loadLevels(

      worldId,

    );





    for(final level in levels){



      final completed =

      await PuzzleProgressManager.isCompleted(

        "${worldId}_${level.id}",

      );





      if(!completed){

        return false;

      }


    }





    return true;


  }







  //==================================================
  // 🧹 إعادة ضبط عالم
  //==================================================


  static Future<void> resetWorld(

      String worldId,

      ) async {



    final levels =

    await loadLevels(

      worldId,

    );





    for(final level in levels){



      await PuzzleProgressManager.removeLevel(

        "${worldId}_${level.id}",

      );


    }


  }






}