import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';
import '../models/game_result_model.dart';

import '../data/puzzle_data.dart';
import '../data/puzzle_level_data.dart';

import '../managers/puzzle_progress_manager.dart';
import '../managers/reward_manager.dart';

import '../screens/puzzle_home_screen.dart';
import '../screens/wallet_screen.dart';

import '../services/puzzle_navigation_service.dart';



class PuzzleWorldService {


  const PuzzleWorldService._();




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

            (world)=> world.id == worldId,

      );

    } catch(_){

      return null;

    }

  }







  static Future<List<PuzzleLevelModel>> loadLevels(

      String worldId,

      ) async {

    try {

      return PuzzleLevelData.getLevels(worldId);

    } catch(_){

      return [];

    }

  }







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







  static Future<bool> isWorldUnlocked(

      PuzzleModel world,

      ) async {

    return true;

  }








  static Future<void> openLevel(

      BuildContext context, {

        required PuzzleModel world,

        required PuzzleLevelModel level,

      }) async {


    try {


      await PuzzleNavigationService.openGame(

        context,

        puzzle: world,

        level: level,

      );


    }catch(_){}


  }








  static Future<void> openWallet(

      BuildContext context,

      ) async {


    try {


      await Navigator.push(

        context,

        MaterialPageRoute(

          builder:(_)=> const WalletScreen(),

        ),

      );


    }catch(_){}


  }








  static Future<void> returnToHome(

      BuildContext context,

      ) async {


    try {


      await Navigator.pushAndRemoveUntil(

        context,

        MaterialPageRoute(

          builder:(_)=> const PuzzleHomeScreen(),

        ),

            (route)=>false,

      );


    }catch(_){}


  }









  static Future<void> completeLevel({

    required String worldId,

    required int level,

    required int stars,

  }) async {



    try {


      final key = "${worldId}_level_$level";




      await PuzzleProgressManager.completeLevel(

        key,

      );




      await PuzzleProgressManager.saveLevelStars(

        key,

        stars,

      );




      await PuzzleProgressManager.addStars(

        stars,

      );




      await PuzzleProgressManager.saveLastPuzzle(

        worldId,

        "level_$level",

      );


    }catch(_){}



  }








  static Future<void> goToNextLevel(

      BuildContext context, {

        required String worldId,

        required int currentLevel,

      }) async {


    try {


      await PuzzleNavigationService.openNextLevel(

        context,

        worldId: worldId,

        currentLevel: currentLevel,

      );


    }catch(_){}


  }








  static Future<void> replayLevel(

      BuildContext context, {

        required PuzzleModel world,

        required PuzzleLevelModel level,

      }) async {


    try {


      await PuzzleNavigationService.restartLevel(

        context,

        puzzle: world,

        level: level,

      );


    }catch(_){}


  }








  static Future<void> openWinScreen(

      BuildContext context, {

        required GameResultModel result,

        required int difficulty,

        required String worldId,

        required int level,

      }) async {


    try {


      await PuzzleNavigationService.openWin(

        context,

        result: result,

        difficulty: difficulty,

        worldId: worldId,

        level: level,

      );


    }catch(_){}


  }








  static Future<int> getWorldStars(

      String worldId,

      ) async {


    int total = 0;


    try {


      final levels = await loadLevels(worldId);


      for(final level in levels){


        total += await PuzzleProgressManager.getLevelStars(

          "${worldId}_level_${level.levelNumber}",

        );


      }


    }catch(_){}



    return total;


  }








  static Future<bool> isWorldCompleted(

      String worldId,

      ) async {


    try {


      final levels = await loadLevels(worldId);



      for(final level in levels){


        final done =

        await PuzzleProgressManager.isCompleted(

          "${worldId}_level_${level.levelNumber}",

        );


        if(!done){

          return false;

        }


      }


      return true;


    }catch(_){


      return false;


    }


  }








  static Future<void> resetWorld(

      String worldId,

      ) async {


    try {


      final levels = await loadLevels(worldId);



      for(final level in levels){


        final key =
        "${worldId}_level_${level.levelNumber}";



        await PuzzleProgressManager.removeLevel(key);


        await PuzzleProgressManager.removeLevelStars(key);



      }


    }catch(_){}



  }



}