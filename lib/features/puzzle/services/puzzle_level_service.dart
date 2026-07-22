import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

import '../data/puzzle_level_data.dart';

import '../managers/puzzle_progress_manager.dart';

import '../screens/puzzle_game_screen.dart';
import '../screens/puzzle_level_screen.dart';



class PuzzleLevelService {


  const PuzzleLevelService._();



  //==================================================
  // جلب مراحل العالم
  //==================================================


  static Future<List<PuzzleLevelModel>> getLevels(

      String worldId,

      ) async {


    return PuzzleLevelData.getLevels(

      worldId,

    );


  }






  //==================================================
  // عدد المراحل
  //==================================================


  static Future<int> getLevelCount(

      String worldId,

      ) async {


    final levels =

    await getLevels(worldId);



    return levels.length;


  }






  //==================================================
  // جلب مرحلة محددة
  //==================================================


  static Future<PuzzleLevelModel?>

  getLevel({

    required String worldId,

    required int levelNumber,

  }) async {



    final levels =

    await getLevels(worldId);




    if(levelNumber <= 0 ||

        levelNumber > levels.length){


      return null;


    }





    return levels[levelNumber - 1];


  }






  //==================================================
  // هل المرحلة موجودة
  //==================================================


  static Future<bool> levelExists({

    required String worldId,

    required int levelNumber,

  }) async {


    final level =

    await getLevel(

      worldId: worldId,

      levelNumber: levelNumber,

    );



    return level != null;


  }






  //==================================================
  // حالة فتح المرحلة
  //==================================================


  static Future<bool> isLevelUnlocked({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {



    if(level.unlocked){

      return true;

    }





    return PuzzleProgressManager

        .isLevelUnlocked(

      "${worldId}_${level.id}",

    );


  }






  //==================================================
  // هل يمكن لعب المرحلة
  //==================================================


  static Future<bool> canPlayLevel({

    required String worldId,

    required PuzzleLevelModel level,

  }) async {


    return await isLevelUnlocked(

      worldId: worldId,

      level: level,

    );


  }






  //==================================================
  // فتح شاشة المراحل
  //==================================================


  static Future<void> openWorldLevels(

      BuildContext context,

      PuzzleModel puzzle,

      ) async {



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
  // فتح اللعبة
  //==================================================


  static Future<void> openLevel(

      BuildContext context, {

        required PuzzleModel puzzle,

        required PuzzleLevelModel level,

      }) async {



    final allowed =

    await canPlayLevel(

      worldId: puzzle.id,

      level: level,

    );





    if(!allowed){

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
  // العودة للرئيسية
  //==================================================


  static Future<void> backToPuzzleHome(

      BuildContext context,

      ) async {


    Navigator.popUntil(

      context,

      (route) => route.isFirst,

    );


  }






  //==================================================
  // عدد النجوم الكلي
  //==================================================


  static Future<int> getTotalStars() async {


    return await PuzzleProgressManager

        .getTotalStars();


  }






  //==================================================
  // المراحل المفتوحة
  //==================================================


  static Future<List<PuzzleLevelModel>>

  getUnlockedLevels(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );



    final result =

    <PuzzleLevelModel>[];



    for(final level in levels){



      final unlocked =

      await isLevelUnlocked(

        worldId: worldId,

        level: level,

      );



      if(unlocked){

        result.add(level);

      }


    }



    return result;


  }






  //==================================================
  // عدد المراحل المكتملة
  //==================================================


  static Future<int> getCompletedCount(

      String worldId,

      ) async {


    final levels =

    await getLevels(

      worldId,

    );



    int count = 0;



    for(final level in levels){



      final completed =

      await PuzzleProgressManager

          .isCompleted(

        "${worldId}_${level.id}",

      );



      if(completed){

        count++;

      }


    }



    return count;


  }






  //==================================================
  // نسبة تقدم العالم
  //==================================================


  static Future<double> getProgress(

      String worldId,

      ) async {



    final total =

    await getLevelCount(

      worldId,

    );



    if(total == 0){

      return 0;

    }



    final completed =

    await getCompletedCount(

      worldId,

    );



    return completed / total;


  }






  //==================================================
  // هل العالم مكتمل
  //==================================================


  static Future<bool> isWorldCompleted(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );



    for(final level in levels){



      final done =

      await PuzzleProgressManager

          .isCompleted(

        "${worldId}_${level.id}",

      );



      if(!done){

        return false;

      }


    }



    return true;


  }

  //==================================================
  // نجوم العالم
  //==================================================


  static Future<int> getWorldStars(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );



    int stars = 0;



    for(final level in levels){



      stars +=

      await PuzzleProgressManager

          .getLevelStars(

        "${worldId}_${level.id}",

      );



    }



    return stars;


  }








  //==================================================
  // حفظ نجوم المرحلة
  //==================================================


  static Future<void> saveLevelStars({

    required String worldId,

    required String levelId,

    required int stars,

  }) async {



    await PuzzleProgressManager

        .saveLevelStars(

      "${worldId}_$levelId",

      stars,

    );


  }








  //==================================================
  // نجوم مرحلة معينة
  //==================================================


  static Future<int> getLevelStars({

    required String worldId,

    required String levelId,

  }) async {



    return await PuzzleProgressManager

        .getLevelStars(

      "${worldId}_$levelId",

    );


  }








  //==================================================
  // إنهاء المرحلة من مكان واحد
  //==================================================


  static Future<void> finishLevel({

    required String worldId,

    required int levelNumber,

    required int stars,

  }) async {



    final levelKey =

    "${worldId}_level_$levelNumber";





    final completed =

    await PuzzleProgressManager

        .isCompleted(

      levelKey,

    );





    if(completed){

      return;

    }







    await PuzzleProgressManager

        .completeLevel(

      levelKey,

    );







    await PuzzleProgressManager

        .saveLevelStars(

      levelKey,

      stars,

    );







    await PuzzleProgressManager

        .addStars(

      stars,

    );







    await PuzzleProgressManager

        .unlockNextLevel(

      worldId,

      levelNumber,

    );


  }







  //==================================================
  // فتح مرحلة يدوياً
  //==================================================


  static Future<void> unlockLevel({

    required String worldId,

    required String levelId,

  }) async {



    await PuzzleProgressManager

        .unlockLevel(

      "${worldId}_$levelId",

    );


  }



  //==================================================
  // إنهاء المرحلة وحفظ التقدم
  //==================================================


  static Future<void> finishLevel({

    required String worldId,

    required int levelNumber,

    required int stars,

    required int difficulty,

  }) async {



    final levelKey =

        "${worldId}_level_$levelNumber";





    final completed =

    await PuzzleProgressManager

        .isCompleted(

      levelKey,

    );






    // إذا كانت المرحلة مكتملة مسبقاً لا نكرر المكافأة

    if(completed){

      return;

    }







    // حفظ إكمال المرحلة

    await PuzzleProgressManager

        .completeLevel(

      levelKey,

    );







    // حفظ نجوم المرحلة

    await PuzzleProgressManager

        .saveLevelStars(

      levelKey,

      stars,

    );







    // إضافة النجوم للمجموع العام

    await PuzzleProgressManager

        .addStars(

      stars,

    );







    // فتح المرحلة التالية

    await PuzzleProgressManager

        .unlockNextLevel(

      worldId,

      levelNumber,

    );



  }


  //==================================================
  // حفظ نتيجة المرحلة كاملة
  //==================================================


  static Future<void> saveLevelResult({

    required String worldId,

    required int levelNumber,

    required int stars,

    required int moves,

    required int seconds,

  }) async {



    await finishLevel(

      worldId: worldId,

      levelNumber: levelNumber,

      stars: stars,

      difficulty: levelNumber,

    );





    await PuzzleProgressManager

        .addCompletedPuzzle(

      moves: moves,

      seconds: seconds,

    );



  }







  //==================================================
  // التحقق من إكمال المرحلة
  //==================================================


  static Future<bool> isCompleted({

    required String worldId,

    required int levelNumber,

  }) async {



    return await PuzzleProgressManager

        .isCompleted(

      "${worldId}_level_$levelNumber",

    );


  }







  //==================================================
  // الحصول على نجوم مرحلة
  //==================================================


  static Future<int> getLevelStars({

    required String worldId,

    required int levelNumber,

  }) async {



    return await PuzzleProgressManager

        .getLevelStars(

      "${worldId}_level_$levelNumber",

    );


  }







  //==================================================
  // عدد نجوم العالم
  //==================================================


  static Future<int> getWorldStars(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );



    int total = 0;




    for(final level in levels){



      final number =

      int.tryParse(

        level.id.replaceAll(

          "level_",

          "",

        ),

      );



      if(number != null){



        total += await getLevelStars(

          worldId: worldId,

          levelNumber: number,

        );


      }



    }





    return total;


  }

  //==================================================
  // فتح المرحلة التالية
  //==================================================


  static Future<void> unlockNextLevel({

    required String worldId,

    required int currentLevel,

  }) async {



    final nextLevel = currentLevel + 1;




    final levels =

    await getLevels(

      worldId,

    );





    if(nextLevel > levels.length){

      return;

    }





    await PuzzleProgressManager

        .unlockNextLevel(

      worldId,

      currentLevel,

    );


  }







  //==================================================
  // فتح كل المراحل (للاختبار)
  //==================================================


  static Future<void> unlockAllLevels({

    required String worldId,

  }) async {



    final levels =

    await getLevels(

      worldId,

    );





    for(final level in levels){



      await PuzzleProgressManager

          .unlockLevel(

        "${worldId}_${level.id}",

      );



    }


  }







  //==================================================
  // نسبة تقدم العالم
  //==================================================


  static Future<double> getProgress(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );



    if(levels.isEmpty){

      return 0;

    }





    int completed = 0;





    for(final level in levels){



      final number =

      int.tryParse(

        level.id.replaceAll(

          "level_",

          "",

        ),

      );



      if(number != null){



        final done =

        await isCompleted(

          worldId: worldId,

          levelNumber: number,

        );



        if(done){

          completed++;

        }



      }


    }






    return completed / levels.length;


  }


  //==================================================
  // المرحلة الأولى مفتوحة تلقائياً
  //==================================================


  static Future<void> initializeWorld({

    required String worldId,

  }) async {



    final levels =

    await getLevels(

      worldId,

    );



    if(levels.isEmpty){

      return;

    }




    final firstLevel =

    "${worldId}_${levels.first.id}";





    await PuzzleProgressManager

        .unlockLevel(

      firstLevel,

    );


  }







  //==================================================
  // التحقق من إمكانية الانتقال للمرحلة
  //==================================================


  static Future<bool> canOpenLevel({

    required String worldId,

    required int levelNumber,

  }) async {



    final level =

    await getLevel(

      worldId: worldId,

      levelNumber: levelNumber,

    );





    if(level == null){

      return false;

    }





    return await isLevelUnlocked(

      worldId: worldId,

      level: level,

    );


  }







  //==================================================
  // الحصول على المرحلة التالية
  //==================================================


  static Future<PuzzleLevelModel?>

  getNextLevel({

    required String worldId,

    required int currentLevel,

  }) async {



    return await getLevel(

      worldId: worldId,

      levelNumber: currentLevel + 1,

    );


  }







  //==================================================
  // هل العالم مكتمل
  //==================================================


  static Future<bool> isWorldCompleted(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );





    if(levels.isEmpty){

      return false;

    }





    for(final level in levels){



      final number =

      int.tryParse(

        level.id.replaceAll(

          "level_",

          "",

        ),

      );





      if(number != null){



        final completed =

        await isCompleted(

          worldId: worldId,

          levelNumber: number,

        );



        if(!completed){

          return false;

        }



      }


    }




    return true;


  }

  //==================================================
  // إعادة ضبط تقدم عالم واحد
  //==================================================


  static Future<void> resetWorld({

    required String worldId,

  }) async {



    final levels =

    await getLevels(

      worldId,

    );





    for(final level in levels){



      final key =

      "${worldId}_${level.id}";





      // حذف حالة الإكمال

      await PuzzleProgressManager

          .removeCompletedLevel(

        key,

      );





      // حذف نجوم المرحلة

      await PuzzleProgressManager

          .removeLevelStars(

        key,

      );



    }



  }







  //==================================================
  // عدد النجوم المطلوبة لفتح المرحلة
  //==================================================


  static Future<int> getRequiredStars({

    required String worldId,

    required int levelNumber,

  }) async {



    final level =

    await getLevel(

      worldId: worldId,

      levelNumber: levelNumber,

    );





    if(level == null){

      return 0;

    }




    return level.requiredStars;


  }







  //==================================================
  // نسبة النجوم المكتسبة
  //==================================================


  static Future<double> getStarProgress(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );





    if(levels.isEmpty){

      return 0;

    }





    int earned = 0;


    int maximum = 0;





    for(final level in levels){



      maximum += 3;





      final number =

      int.tryParse(

        level.id.replaceAll(

          "level_",

          "",

        ),

      );





      if(number != null){



        earned += await getLevelStars(

          worldId: worldId,

          levelNumber: number,

        );



      }



    }





    if(maximum == 0){

      return 0;

    }





    return earned / maximum;


  }


  //==================================================
  // عدد النجوم المتبقية للعالم
  //==================================================


  static Future<int> getMissingStars(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );





    int maxStars =

        levels.length * 3;





    final current =

    await getWorldStars(

      worldId,

    );





    final missing =

        maxStars - current;





    return missing < 0 ? 0 : missing;


  }







  //==================================================
  // المرحلة المفتوحة حالياً
  //==================================================


  static Future<int> getLastUnlockedLevel({

    required String worldId,

  }) async {



    final levels =

    await getLevels(

      worldId,

    );





    int last = 1;





    for(int i = 0; i < levels.length; i++){



      final unlocked =

      await isLevelUnlocked(

        worldId: worldId,

        level: levels[i],

      );





      if(unlocked){

        last = i + 1;

      }



    }





    return last;


  }







  //==================================================
  // الانتقال للمرحلة التالية أو إنهاء العالم
  //==================================================


  static Future<bool> hasNextLevel({

    required String worldId,

    required int currentLevel,

  }) async {



    final levels =

    await getLevels(

      worldId,

    );





    return currentLevel < levels.length;


  }







  //==================================================
  // معلومات العالم
  //==================================================


  static Future<Map<String,dynamic>>

  getWorldInfo(

      String worldId,

      ) async {



    final levels =

    await getLevels(

      worldId,

    );





    final stars =

    await getWorldStars(

      worldId,

    );





    final completed =

    await isWorldCompleted(

      worldId,

    );





    return {



      "worldId": worldId,


      "levels": levels.length,


      "stars": stars,


      "completed": completed,



    };


  }

}
