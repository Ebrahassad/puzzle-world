import 'package:flutter/material.dart';

import '../screens/puzzle_game_screen.dart';

import '../screens/puzzle_level_screen.dart';

import '../models/puzzle_model.dart';

import '../models/puzzle_level_model.dart';



class PuzzleNavigationGuardService {


  static Future<bool> canOpenLevel({

    required BuildContext context,

    required PuzzleModel puzzle,

    required PuzzleLevelModel level,

  }) async {



    if(level.unlocked){

      return true;

    }





    return false;


  }








  static Future<void> openLevel({

    required BuildContext context,

    required PuzzleModel puzzle,

    required PuzzleLevelModel level,

  }) async {



    final allowed =

    await canOpenLevel(

      context: context,

      puzzle: puzzle,

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








  static void closePuzzle(

      BuildContext context,

      ) {



    Navigator.pop(

      context,

    );


  }


}