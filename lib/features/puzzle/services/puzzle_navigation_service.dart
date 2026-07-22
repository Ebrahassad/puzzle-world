import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';
import '../models/game_result_model.dart';


import '../screens/puzzle_home_screen.dart';
import '../screens/puzzle_level_screen.dart';
import '../screens/puzzle_game_screen.dart';
import '../screens/puzzle_win_screen.dart';

import '../screens/wallet_screen.dart';

import '../screens/puzzle_settings_screen.dart';
import '../screens/puzzle_statistics_screen.dart';
import '../screens/puzzle_profile_screen.dart';
import '../screens/puzzle_achievement_screen.dart';
import '../screens/puzzle_shop_screen.dart';
import '../screens/puzzle_daily_reward_screen.dart';
import '../screens/puzzle_event_screen.dart';
import '../screens/puzzle_collection_screen.dart';


import '../data/puzzle_data.dart';
import '../data/puzzle_level_data.dart';





class PuzzleNavigationService {


  const PuzzleNavigationService._();






  //==================================================
  // 🏠 الرئيسية
  //==================================================


  static Future<void> openHome(

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
  // 🌍 فتح العالم
  //==================================================


  static Future<void> openWorld(

      BuildContext context, {

        required PuzzleModel puzzle,

      }) async {



    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>

            PuzzleLevelScreen(

              puzzle: puzzle,

            ),

      ),

    );



  }








  //==================================================
  // 🧩 فتح لعبة البازل
  //==================================================


  static Future<void> openGame(

      BuildContext context, {

        required PuzzleModel puzzle,

        required PuzzleLevelModel level,

      }) async {



    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>

            PuzzleGameScreen(

              puzzle: puzzle,

              level: level,

            ),

      ),

    );



  }








  //==================================================
  // 🎉 شاشة الفوز
  //==================================================


  static Future<void> openWin(

      BuildContext context, {

        required GameResultModel result,

        required int difficulty,

        required String worldId,

        required int level,

      }) async {



    await Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder: (_) =>

            PuzzleWinScreen(

              result: result,

              difficulty: difficulty,

              worldId: worldId,

              level: level,

            ),

      ),

    );



  }

  //==================================================
  // ➡️ فتح المرحلة التالية
  //==================================================


  static Future<void> openNextLevel(

      BuildContext context, {

        required String worldId,

        required int currentLevel,

      }) async {



    final world =

    PuzzleData.puzzles.firstWhere(

          (item) => item.id == worldId,

    );







    final nextLevelNumber =

        currentLevel + 1;







    final levels =

    PuzzleLevelData.getLevels(

      worldId,

    );







    PuzzleLevelModel? nextLevel;







    for(final level in levels){



      if(level.levelNumber == nextLevelNumber){



        nextLevel = level;


        break;



      }



    }







    // لا توجد مرحلة أخرى

    if(nextLevel == null){



      await openWorld(

        context,

        puzzle: world,

      );



      return;



    }







    await openGame(

      context,

      puzzle: world,

      level: nextLevel,

    );



  }








  //==================================================
  // 🔄 إعادة المرحلة
  //==================================================


  static Future<void> restartLevel(

      BuildContext context, {

        required PuzzleModel puzzle,

        required PuzzleLevelModel level,

      }) async {



    await Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder: (_) =>

            PuzzleGameScreen(

              puzzle: puzzle,

              level: level,

            ),

      ),

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
  // 🛒 المتجر
  //==================================================


  static Future<void> openShop(

      BuildContext context,

      ) async {



    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>

        const PuzzleShopScreen(),

      ),

    );



  }








  //==================================================
  // 🏆 الإنجازات
  //==================================================


  static Future<void> openAchievements(

      BuildContext context,

      ) async {



    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>

        const PuzzleAchievementScreen(),

      ),

    );



  }

  //==================================================
  // 📊 الإحصائيات
  //==================================================


  static Future<void> openStatistics(

      BuildContext context,

      ) async {



    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>

        const PuzzleStatisticsScreen(),

      ),

    );


  }








  //==================================================
  // 👤 الملف الشخصي
  //==================================================


  static Future<void> openProfile(

      BuildContext context,

      ) async {



    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>

        const PuzzleProfileScreen(),

      ),

    );


  }








  //==================================================
  // ⚙️ الإعدادات
  //==================================================


  static Future<void> openSettings(

      BuildContext context,

      ) async {



    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>

        const PuzzleSettingsScreen(),

      ),

    );


  }








  //==================================================
  // 🎁 المكافأة اليومية
  //==================================================


  static Future<void> openDailyReward(

      BuildContext context,

      ) async {



    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>

        const PuzzleDailyRewardScreen(),

      ),

    );


  }








  //==================================================
  // 🎯 الأحداث
  //==================================================


  static Future<void> openEvents(

      BuildContext context,

      ) async {



    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>

        const PuzzleEventScreen(),

      ),

    );


  }








  //==================================================
  // 🖼 المجموعة
  //==================================================


  static Future<void> openCollection(

      BuildContext context,

      ) async {



    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>

        const PuzzleCollectionScreen(),

      ),

    );


  }








  //==================================================
  // 🔙 رجوع
  //==================================================


  static void back(

      BuildContext context, {

        dynamic result,

      }) {



    Navigator.pop(

      context,

      result,

    );


  }








  //==================================================
  // 🏠 إغلاق كل الصفحات والعودة للرئيسية
  //==================================================


  static void popToRoot(

      BuildContext context,

      ) {



    Navigator.popUntil(

      context,

          (route) => route.isFirst,

    );


  }



}