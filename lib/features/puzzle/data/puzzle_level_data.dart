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

      PuzzleLevelModel(
        id: "level_5",
        levelNumber: 5,
        title: "حيوانات المزرعة",
        gridSize: 6,
        requiredStars: 15,
      ),

      PuzzleLevelModel(
        id: "level_6",
        levelNumber: 6,
        title: "عالم البحار",
        gridSize: 7,
        requiredStars: 20,
      ),

      PuzzleLevelModel(
        id: "level_7",
        levelNumber: 7,
        title: "الحيوانات البرية",
        gridSize: 7,
        requiredStars: 30,
      ),

      PuzzleLevelModel(
        id: "level_8",
        levelNumber: 8,
        title: "أسرار الغابة",
        gridSize: 8,
        requiredStars: 40,
      ),

      PuzzleLevelModel(
        id: "level_9",
        levelNumber: 9,
        title: "أبطال الحيوانات",
        gridSize: 8,
        requiredStars: 50,
      ),

      PuzzleLevelModel(
        id: "level_10",
        levelNumber: 10,
        title: "التحدي النهائي",
        gridSize: 9,
        requiredStars: 70,
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

      PuzzleLevelModel(
        id: "level_5",
        levelNumber: 5,
        title: "السيارات الرياضية",
        gridSize: 6,
        requiredStars: 15,
      ),

      PuzzleLevelModel(
        id: "level_6",
        levelNumber: 6,
        title: "طريق السرعة",
        gridSize: 7,
        requiredStars: 20,
      ),

      PuzzleLevelModel(
        id: "level_7",
        levelNumber: 7,
        title: "سباق الأبطال",
        gridSize: 7,
        requiredStars: 30,
      ),

      PuzzleLevelModel(
        id: "level_8",
        levelNumber: 8,
        title: "تحدي المدينة",
        gridSize: 8,
        requiredStars: 40,
      ),

      PuzzleLevelModel(
        id: "level_9",
        levelNumber: 9,
        title: "أسطورة السيارات",
        gridSize: 8,
        requiredStars: 50,
      ),

      PuzzleLevelModel(
        id: "level_10",
        levelNumber: 10,
        title: "السباق النهائي",
        gridSize: 9,
        requiredStars: 70,
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

  PuzzleLevelModel(
    id: "level_5",
    levelNumber: 5,
    title: "المجرات",
    gridSize: 6,
    requiredStars: 15,
  ),

  PuzzleLevelModel(
    id: "level_6",
    levelNumber: 6,
    title: "رحلة القمر",
    gridSize: 7,
    requiredStars: 20,
  ),

  PuzzleLevelModel(
    id: "level_7",
    levelNumber: 7,
    title: "النجوم البعيدة",
    gridSize: 7,
    requiredStars: 30,
  ),

  PuzzleLevelModel(
    id: "level_8",
    levelNumber: 8,
    title: "أسرار الكون",
    gridSize: 8,
    requiredStars: 40,
  ),

  PuzzleLevelModel(
    id: "level_9",
    levelNumber: 9,
    title: "مغامرة الفضاء",
    gridSize: 8,
    requiredStars: 50,
  ),

  PuzzleLevelModel(
    id: "level_10",
    levelNumber: 10,
    title: "نهاية الرحلة",
    gridSize: 9,
    requiredStars: 70,
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

  PuzzleLevelModel(
    id: "level_5",
    levelNumber: 5,
    title: "الغابات الخضراء",
    gridSize: 6,
    requiredStars: 15,
  ),

  PuzzleLevelModel(
    id: "level_6",
    levelNumber: 6,
    title: "الشلالات",
    gridSize: 7,
    requiredStars: 20,
  ),

  PuzzleLevelModel(
    id: "level_7",
    levelNumber: 7,
    title: "عالم النباتات",
    gridSize: 7,
    requiredStars: 30,
  ),

  PuzzleLevelModel(
    id: "level_8",
    levelNumber: 8,
    title: "روعة الطبيعة",
    gridSize: 8,
    requiredStars: 40,
  ),

  PuzzleLevelModel(
    id: "level_9",
    levelNumber: 9,
    title: "سر الطبيعة",
    gridSize: 8,
    requiredStars: 50,
  ),

  PuzzleLevelModel(
    id: "level_10",
    levelNumber: 10,
    title: "التحدي النهائي",
    gridSize: 9,
    requiredStars: 70,
  ),

],

//==================================================
// جزيرة المعالم العالمية
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

  PuzzleLevelModel(
    id: "level_5",
    levelNumber: 5,
    title: "عجائب العالم",
    gridSize: 6,
    requiredStars: 15,
  ),

  PuzzleLevelModel(
    id: "level_6",
    levelNumber: 6,
    title: "مدن عالمية",
    gridSize: 7,
    requiredStars: 20,
  ),

  PuzzleLevelModel(
    id: "level_7",
    levelNumber: 7,
    title: "آثار قديمة",
    gridSize: 7,
    requiredStars: 30,
  ),

  PuzzleLevelModel(
    id: "level_8",
    levelNumber: 8,
    title: "رحلة حول العالم",
    gridSize: 8,
    requiredStars: 40,
  ),

  PuzzleLevelModel(
    id: "level_9",
    levelNumber: 9,
    title: "أشهر المعالم",
    gridSize: 8,
    requiredStars: 50,
  ),

  PuzzleLevelModel(
    id: "level_10",
    levelNumber: 10,
    title: "النهائي العالمي",
    gridSize: 9,
    requiredStars: 70,
  ),

],


  };



  //==================================================
  // جلب مستويات جزيرة
  //==================================================

  static List<PuzzleLevelModel> getLevels(
      String puzzleId,
      ) {

    return levels[puzzleId] ?? [];

  }



  //==================================================
  // جلب مستوى محدد
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