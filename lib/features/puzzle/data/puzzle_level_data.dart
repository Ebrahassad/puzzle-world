import '../models/puzzle_level_model.dart';


class PuzzleLevelData {


  static const Map<String, List<PuzzleLevelModel>> levels = {


    //==================================================
    // جزيرة الحيوانات
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
        title: "الحيوانات الجميلة",
        gridSize: 4,
        requiredStars: 3,
      ),

      PuzzleLevelModel(
        id: "level_3",
        levelNumber: 3,
        title: "مغامرة الغابة",
        gridSize: 5,
        requiredStars: 6,
      ),

      PuzzleLevelModel(
        id: "level_4",
        levelNumber: 4,
        title: "تحدي الحيوانات",
        gridSize: 6,
        requiredStars: 9,
      ),

    ],



    //==================================================
    // جزيرة السيارات
    //==================================================

    "cars": [

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
        gridSize: 4,
        requiredStars: 3,
      ),

      PuzzleLevelModel(
        id: "level_3",
        levelNumber: 3,
        title: "سباق المدينة",
        gridSize: 5,
        requiredStars: 6,
      ),

      PuzzleLevelModel(
        id: "level_4",
        levelNumber: 4,
        title: "تحدي السيارات",
        gridSize: 6,
        requiredStars: 9,
      ),

    ],



    //==================================================
    // جزيرة الفضاء
    //==================================================

    "space": [

      PuzzleLevelModel(
        id: "level_1",
        levelNumber: 1,
        title: "رحلة البداية",
        gridSize: 3,
        requiredStars: 0,
        unlocked: true,
      ),

      PuzzleLevelModel(
        id: "level_2",
        levelNumber: 2,
        title: "الكواكب",
        gridSize: 4,
        requiredStars: 3,
      ),

      PuzzleLevelModel(
        id: "level_3",
        levelNumber: 3,
        title: "الصواريخ",
        gridSize: 5,
        requiredStars: 6,
      ),

      PuzzleLevelModel(
        id: "level_4",
        levelNumber: 4,
        title: "أسرار الفضاء",
        gridSize: 6,
        requiredStars: 9,
      ),

    ],



    //==================================================
    // جزيرة الطبيعة
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
        title: "الجبال والأنهار",
        gridSize: 4,
        requiredStars: 3,
      ),

      PuzzleLevelModel(
        id: "level_3",
        levelNumber: 3,
        title: "جمال الطبيعة",
        gridSize: 5,
        requiredStars: 6,
      ),

      PuzzleLevelModel(
        id: "level_4",
        levelNumber: 4,
        title: "تحدي الطبيعة",
        gridSize: 6,
        requiredStars: 9,
      ),

    ],



    //==================================================
    // جزيرة المعالم
    //==================================================

    "landmarks": [

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
        title: "معالم مشهورة",
        gridSize: 4,
        requiredStars: 3,
      ),

      PuzzleLevelModel(
        id: "level_3",
        levelNumber: 3,
        title: "حول العالم",
        gridSize: 5,
        requiredStars: 6,
      ),

      PuzzleLevelModel(
        id: "level_4",
        levelNumber: 4,
        title: "تحدي المعالم",
        gridSize: 6,
        requiredStars: 9,
      ),

    ],


  };




  static List<PuzzleLevelModel> getLevels(
      String puzzleId,
      ){

    return levels[puzzleId] ?? [];

  }




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