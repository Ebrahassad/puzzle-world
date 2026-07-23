import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';
import '../models/game_result_model.dart';

import '../screens/puzzle_home_screen.dart';
import '../screens/puzzle_level_screen.dart';
import '../screens/puzzle_game_screen.dart';
import '../screens/puzzle_win_screen.dart';
import '../screens/wallet_screen.dart';

import '../data/puzzle_data.dart';
import '../data/puzzle_level_data.dart';

import '../services/puzzle_level_unlock_service.dart';



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
  // 🧩 فتح اللعبة
  //==================================================

  static Future<void> openGame(

      BuildContext context, {

        required PuzzleModel puzzle,

        required PuzzleLevelModel level,

      }) async {



    final unlocked =

    await PuzzleLevelUnlockService.checkUnlocked(

      worldId: puzzle.id,

      level: level,

    );





    if(!unlocked){

      return;

    }







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
  // 🎉 الفوز
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
  // ➡️ المرحلة التالية
  //==================================================

  static Future<void> openNextLevel(

      BuildContext context, {

        required String worldId,

        required int currentLevel,

      }) async {



    PuzzleModel? world =

    PuzzleData.getById(

      worldId,

    );





    if(world == null){

      return;

    }







    final levels =

    PuzzleLevelData.getLevels(

      worldId,

    );





    PuzzleLevelModel? nextLevel;





    for(final level in levels){



      if(level.levelNumber == currentLevel + 1){


        nextLevel = level;


        break;


      }


    }







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
  // 🏠 العودة للجذر
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