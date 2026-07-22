import '../managers/puzzle_progress_manager.dart';

import '../models/puzzle_level_model.dart';



class PuzzleLevelProgressService {


  static Future<bool> isLevelCompleted(

      String levelId,

      ) async {


    return await PuzzleProgressManager

        .isCompleted(

      levelId,

    );


  }








  static Future<void> completeLevel(

      String levelId,

      ) async {



    await PuzzleProgressManager

        .completeLevel(

      levelId,

    );


  }








  static Future<bool> isLevelUnlocked(

      String levelId,

      ) async {


    return await PuzzleProgressManager

        .isLevelUnlocked(

      levelId,

    );


  }








  static Future<void> unlockLevel(

      String levelId,

      ) async {



    await PuzzleProgressManager

        .unlockLevel(

      levelId,

    );


  }








  static Future<void> unlockNextLevel({

    required String worldId,

    required int currentLevel,

  }) async {



    await PuzzleProgressManager

        .unlockNextLevel(

      worldId,

      currentLevel,

    );


  }








  static Future<List<PuzzleLevelModel>>

  prepareLevels({

    required List<PuzzleLevelModel> levels,

  }) async {



    final result = <PuzzleLevelModel>[];



    for(final level in levels){


      final unlocked =

      await isLevelUnlocked(

        level.id,

      );



      result.add(

        PuzzleLevelModel(

          id: level.id,

          gridSize: level.gridSize,

          requiredStars: level.requiredStars,

          unlocked: unlocked,

        ),

      );


    }



    return result;


  }








  static Future<int> getCompletedLevelsCount(

      List<PuzzleLevelModel> levels,

      ) async {



    int count = 0;



    for(final level in levels){


      final completed =

      await isLevelCompleted(

        level.id,

      );



      if(completed){

        count++;

      }


    }



    return count;


  }








  static Future<double> getProgressPercent(

      List<PuzzleLevelModel> levels,

      ) async {



    if(levels.isEmpty){

      return 0;

    }





    final completed =

    await getCompletedLevelsCount(

      levels,

    );





    return completed / levels.length;


  }


}