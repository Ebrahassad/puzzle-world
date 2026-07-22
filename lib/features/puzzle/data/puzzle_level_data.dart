import '../models/puzzle_level_model.dart';



class PuzzleLevelData {


  static const Map<String, List<PuzzleLevelModel>> levels = {



    //==================================================
    // 🐻 عالم الحيوانات
    //==================================================

    "animals": [

      PuzzleLevelModel(

        id: "level_1",

        levelNumber: 1,

        title: "البداية",

        gridSize: 3,

        requiredStars: 0,

        unlocked: true,

      ),



      PuzzleLevelModel(

        id: "level_2",

        levelNumber: 2,

        title: "المستوى السهل",

        gridSize: 4,

        requiredStars: 3,

      ),



      PuzzleLevelModel(

        id: "level_3",

        levelNumber: 3,

        title: "المستوى المتوسط",

        gridSize: 5,

        requiredStars: 6,

      ),



      PuzzleLevelModel(

        id: "level_4",

        levelNumber: 4,

        title: "التحدي الكبير",

        gridSize: 6,

        requiredStars: 9,

      ),

    ],





    //==================================================
    // 🌳 عالم الطبيعة
    //==================================================

    "nature": [

      PuzzleLevelModel(

        id: "level_1",

        levelNumber: 1,

        title: "البداية",

        gridSize: 3,

        requiredStars: 0,

        unlocked: true,

      ),



      PuzzleLevelModel(

        id: "level_2",

        levelNumber: 2,

        title: "استكشاف الطبيعة",

        gridSize: 4,

        requiredStars: 3,

      ),



      PuzzleLevelModel(

        id: "level_3",

        levelNumber: 3,

        title: "تحدي الطبيعة",

        gridSize: 5,

        requiredStars: 6,

      ),

    ],





    //==================================================
    // 🚗 عالم السيارات
    //==================================================

    "vehicles": [

      PuzzleLevelModel(

        id: "level_1",

        levelNumber: 1,

        title: "البداية",

        gridSize: 3,

        requiredStars: 0,

        unlocked: true,

      ),



      PuzzleLevelModel(

        id: "level_2",

        levelNumber: 2,

        title: "السيارات السريعة",

        gridSize: 5,

        requiredStars: 3,

      ),



      PuzzleLevelModel(

        id: "level_3",

        levelNumber: 3,

        title: "التحدي المروري",

        gridSize: 6,

        requiredStars: 6,

      ),

    ],





    //==================================================
    // 🍎 عالم الفواكه
    //==================================================

    "fruits": [

      PuzzleLevelModel(

        id: "level_1",

        levelNumber: 1,

        title: "البداية",

        gridSize: 3,

        requiredStars: 0,

        unlocked: true,

      ),



      PuzzleLevelModel(

        id: "level_2",

        levelNumber: 2,

        title: "الفواكه الملونة",

        gridSize: 4,

        requiredStars: 3,

      ),



      PuzzleLevelModel(

        id: "level_3",

        levelNumber: 3,

        title: "سلة الفواكه",

        gridSize: 5,

        requiredStars: 6,

      ),



      PuzzleLevelModel(

        id: "level_4",

        levelNumber: 4,

        title: "تحدي الفواكه",

        gridSize: 6,

        requiredStars: 9,

      ),

    ],



  };





  //==================================================
  // جلب مراحل عالم
  //==================================================

  static List<PuzzleLevelModel> getLevels(

      String puzzleId,

      ){

    return levels[puzzleId] ?? [];

  }





  //==================================================
  // جلب مرحلة محددة
  //==================================================

  static PuzzleLevelModel? getLevel({

    required String puzzleId,

    required String levelId,

  }) {


    final worldLevels = getLevels(puzzleId);


    try {

      return worldLevels.firstWhere(

            (level) => level.id == levelId,

      );

    } catch (_) {

      return null;

    }

  }


}