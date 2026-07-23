import 'package:flutter/material.dart';

import '../screens/puzzle_game_screen.dart';
import '../screens/puzzle_level_screen.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

import '../services/puzzle_level_unlock_service.dart';



class PuzzleNavigationGuardService {


  const PuzzleNavigationGuardService._();




  //==================================================
  // 🔐 فحص إمكانية فتح المرحلة
  //==================================================

  static Future<bool> canOpenLevel({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {


    return await PuzzleLevelUnlockService.checkUnlocked(

      worldId: worldId,

      level: level,

    );


  }








  //==================================================
  // 🧩 فتح المرحلة
  //==================================================

  static Future<void> openLevel({

    required BuildContext context,

    required PuzzleModel puzzle,

    required PuzzleLevelModel level,

  }) async {



    final allowed =

    await canOpenLevel(

      worldId: puzzle.id,

      level: level,

    );





    if(!allowed){


      return;


    }







    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) => PuzzleGameScreen(

          puzzle: puzzle,

          level: level,

        ),

      ),

    );


  }








  //==================================================
  // 🔙 العودة للمراحل
  //==================================================

  static void backToLevels({

    required BuildContext context,

    required PuzzleModel puzzle,

  }) {



    Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder: (_) => PuzzleLevelScreen(

          puzzle: puzzle,

        ),

      ),

    );


  }








  //==================================================
  // ❌ إغلاق البازل
  //==================================================

  static void closePuzzle(

    BuildContext context,

  ) {


    Navigator.pop(

      context,

    );


  }





}