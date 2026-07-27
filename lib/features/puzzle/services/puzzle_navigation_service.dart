import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';
import '../models/game_result_model.dart';

import '../screens/puzzle_home_screen.dart';
import '../screens/island_screen.dart';
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

    try {

      await Navigator.pushAndRemoveUntil(

        context,

        MaterialPageRoute(

          builder: (_) =>
          const PuzzleHomeScreen(),

        ),

            (route)=>false,

      );

    } catch (_) {}

  }







  //==================================================
  // 🌍 فتح الجزيرة
  //==================================================

  static Future<void> openWorld(

      BuildContext context, {

        required PuzzleModel puzzle,

      }) async {


    try {

      await Navigator.push(

        context,

        MaterialPageRoute(

          builder: (_) =>

              IslandScreen(

                island:puzzle,

              ),

        ),

      );

    } catch (_) {}

  }








  //==================================================
  // 🧩 فتح اللعبة
  //==================================================

  static Future<void> openGame(

      BuildContext context, {

        required PuzzleModel puzzle,

        required PuzzleLevelModel level,

      }) async {


    try {


      bool unlocked = false;


      try {


        unlocked =
        await PuzzleLevelUnlockService.checkUnlocked(

          worldId:puzzle.id,

          level:level,

        );


      } catch(_){

        return;

      }






      if(!unlocked){

        return;

      }







      await Navigator.push(

        context,

        MaterialPageRoute(

          builder: (_) =>

              PuzzleGameScreen(

                puzzle:puzzle,

                level:level,

              ),

        ),

      );



    } catch (_) {}

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


    try {


      await Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (_) =>

              PuzzleWinScreen(

                result:result,

                difficulty:difficulty,

                worldId:worldId,

                level:level,

              ),

        ),

      );


    } catch (_) {}

  }








  //==================================================
  // ➡️ المرحلة التالية
  //==================================================

  static Future<void> openNextLevel(

      BuildContext context, {

        required String worldId,

        required int currentLevel,

      }) async {


    try {


      final world =

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







      PuzzleLevelModel? next;





      for(final item in levels){


        if(item.levelNumber == currentLevel + 1){

          next = item;

          break;

        }

      }







      if(next == null){


        await openWorld(

          context,

          puzzle:world,

        );


        return;


      }








      await openGame(

        context,

        puzzle:world,

        level:next,

      );





    } catch (_) {}

  }








  //==================================================
  // 🔄 إعادة المرحلة
  //==================================================

  static Future<void> restartLevel(

      BuildContext context, {

        required PuzzleModel puzzle,

        required PuzzleLevelModel level,

      }) async {


    try {


      await Navigator.pushReplacement(

        context,

        MaterialPageRoute(

          builder: (_) =>

              PuzzleGameScreen(

                puzzle:puzzle,

                level:level,

              ),

        ),

      );


    } catch (_) {}

  }








  //==================================================
  // 💰 المحفظة
  //==================================================

  static Future<void> openWallet(

      BuildContext context,

      ) async {


    try {


      await Navigator.push(

        context,

        MaterialPageRoute(

          builder: (_) =>

          const WalletScreen(),

        ),

      );


    } catch (_) {}

  }








  //==================================================
  // 🔙 رجوع
  //==================================================

  static void back(

      BuildContext context, {

        dynamic result,

      }) {


    try {


      Navigator.pop(

        context,

        result,

      );


    } catch (_) {}

  }








  //==================================================
  // 🏠 العودة للجذر
  //==================================================

  static void popToRoot(

      BuildContext context,

      ) {


    try {


      Navigator.popUntil(

        context,

            (route)=>route.isFirst,

      );


    } catch (_) {}

  }



}