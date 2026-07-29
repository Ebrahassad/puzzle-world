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
        image: "assets/images/Puzzle/animals/level_1.png",
        gridSize: 3,
        requiredStars: 0,
        unlocked: true,
      ),

      PuzzleLevelModel(
        id: "level_2",
        levelNumber: 2,
        title: "الحيوانات الجميلة",
        image: "assets/images/Puzzle/animals/level_2.png",
        gridSize: 4,
        requiredStars: 3,
      ),

      PuzzleLevelModel(
        id: "level_3",
        levelNumber: 3,
        title: "مغامرة الغابة",
        image: "assets/images/Puzzle/animals/level_3.png",
        gridSize: 5,
        requiredStars: 6,
      ),

      PuzzleLevelModel(
        id: "level_4",
        levelNumber: 4,
        title: "تحدي الحيوانات",
        image: "assets/images/Puzzle/animals/level_4.png",
        gridSize: 6,
        requiredStars: 9,
      ),

      PuzzleLevelModel(
        id: "level_5",
        levelNumber: 5,
        title: "حيوانات المزرعة",
        image: "assets/images/Puzzle/animals/level_5.png",
        gridSize: 6,
        requiredStars: 15,
      ),

      PuzzleLevelModel(
        id: "level_6",
        levelNumber: 6,
        title: "عالم البحار",
        image: "assets/images/Puzzle/animals/level_6.png",
        gridSize: 7,
        requiredStars: 20,
      ),

      PuzzleLevelModel(
        id: "level_7",
        levelNumber: 7,
        title: "الحيوانات البرية",
        image: "assets/images/Puzzle/animals/level_7.png",
        gridSize: 7,
        requiredStars: 30,
      ),

      PuzzleLevelModel(
        id: "level_8",
        levelNumber: 8,
        title: "أسرار الغابة",
        image: "assets/images/Puzzle/animals/level_8.png",
        gridSize: 8,
        requiredStars: 40,
      ),

      PuzzleLevelModel(
        id: "level_9",
        levelNumber: 9,
        title: "أبطال الحيوانات",
        image: "assets/images/Puzzle/animals/level_9.png",
        gridSize: 8,
        requiredStars: 50,
      ),

      PuzzleLevelModel(
        id: "level_10",
        levelNumber: 10,
        title: "التحدي النهائي",
        image: "assets/images/Puzzle/animals/level_10.png",
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
        image: "assets/images/Puzzle/cars/level_1.png",
        gridSize: 3,
        requiredStars: 0,
        unlocked: true,
      ),

      PuzzleLevelModel(
        id: "level_2",
        levelNumber: 2,
        title: "السيارات السريعة",
        image: "assets/images/Puzzle/cars/level_2.png",
        gridSize: 4,
        requiredStars: 3,
      ),

      PuzzleLevelModel(
        id: "level_3",
        levelNumber: 3,
        title: "سباق المدينة",
        image: "assets/images/Puzzle/cars/level_3.png",
        gridSize: 5,
        requiredStars: 6,
      ),

      PuzzleLevelModel(
        id: "level_4",
        levelNumber: 4,
        title: "تحدي السيارات",
        image: "assets/images/Puzzle/cars/level_4.png",
        gridSize: 6,
        requiredStars: 9,
      ),

      PuzzleLevelModel(
        id: "level_5",
        levelNumber: 5,
        title: "السيارات الرياضية",
        image: "assets/images/Puzzle/cars/level_5.png",
        gridSize: 6,
        requiredStars: 15,
      ),

      PuzzleLevelModel(
        id: "level_6",
        levelNumber: 6,
        title: "طريق السرعة",
        image: "assets/images/Puzzle/cars/level_6.png",
        gridSize: 7,
        requiredStars: 20,
      ),

      PuzzleLevelModel(
        id: "level_7",
        levelNumber: 7,
        title: "سباق الأبطال",
        image: "assets/images/Puzzle/cars/level_7.png",
        gridSize: 7,
        requiredStars: 30,
      ),

      PuzzleLevelModel(
        id: "level_8",
        levelNumber: 8,
        title: "تحدي المدينة",
        image: "assets/images/Puzzle/cars/level_8.png",
        gridSize: 8,
        requiredStars: 40,
      ),

      PuzzleLevelModel(
        id: "level_9",
        levelNumber: 9,
        title: "أسطورة السيارات",
        image: "assets/images/Puzzle/cars/level_9.png",
        gridSize: 8,
        requiredStars: 50,
      ),

      PuzzleLevelModel(
        id: "level_10",
        levelNumber: 10,
        title: "السباق النهائي",
        image: "assets/images/Puzzle/cars/level_10.png",
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
    image: "assets/images/Puzzle/space/level_1.png",
    gridSize: 3,
    requiredStars: 0,
    unlocked: true,
  ),

  PuzzleLevelModel(
    id: "level_2",
    levelNumber: 2,
    title: "الكواكب",
    image: "assets/images/Puzzle/space/level_2.png",
    gridSize: 4,
    requiredStars: 3,
  ),

  PuzzleLevelModel(
    id: "level_3",
    levelNumber: 3,
    title: "الصواريخ",
    image: "assets/images/Puzzle/space/level_3.png",
    gridSize: 5,
    requiredStars: 6,
  ),

  PuzzleLevelModel(
    id: "level_4",
    levelNumber: 4,
    title: "أسرار الفضاء",
    image: "assets/images/Puzzle/space/level_4.png",
    gridSize: 6,
    requiredStars: 9,
  ),

  PuzzleLevelModel(
    id: "level_5",
    levelNumber: 5,
    title: "المجرات",
    image: "assets/images/Puzzle/space/level_5.png",
    gridSize: 6,
    requiredStars: 15,
  ),

  PuzzleLevelModel(
    id: "level_6",
    levelNumber: 6,
    title: "رحلة القمر",
    image: "assets/images/Puzzle/space/level_6.png",
    gridSize: 7,
    requiredStars: 20,
  ),

  PuzzleLevelModel(
    id: "level_7",
    levelNumber: 7,
    title: "النجوم البعيدة",
    image: "assets/images/Puzzle/space/level_7.png",
    gridSize: 7,
    requiredStars: 30,
  ),

  PuzzleLevelModel(
    id: "level_8",
    levelNumber: 8,
    title: "أسرار الكون",
    image: "assets/images/Puzzle/space/level_8.png",
    gridSize: 8,
    requiredStars: 40,
  ),

  PuzzleLevelModel(
    id: "level_9",
    levelNumber: 9,
    title: "مغامرة الفضاء",
    image: "assets/images/Puzzle/space/level_9.png",
    gridSize: 8,
    requiredStars: 50,
  ),

  PuzzleLevelModel(
    id: "level_10",
    levelNumber: 10,
    title: "نهاية الرحلة",
    image: "assets/images/Puzzle/space/level_10.png",
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
    image: "assets/images/Puzzle/nature/level_1.png",
    gridSize: 3,
    requiredStars: 0,
    unlocked: true,
  ),

  PuzzleLevelModel(
    id: "level_2",
    levelNumber: 2,
    title: "الجبال والأنهار",
    image: "assets/images/Puzzle/nature/level_2.png",
    gridSize: 4,
    requiredStars: 3,
  ),

  PuzzleLevelModel(
    id: "level_3",
    levelNumber: 3,
    title: "جمال الطبيعة",
    image: "assets/images/Puzzle/nature/level_3.png",
    gridSize: 5,
    requiredStars: 6,
  ),

  PuzzleLevelModel(
    id: "level_4",
    levelNumber: 4,
    title: "تحدي الطبيعة",
    image: "assets/images/Puzzle/nature/level_4.png",
    gridSize: 6,
    requiredStars: 9,
  ),

  PuzzleLevelModel(
    id: "level_5",
    levelNumber: 5,
    title: "الغابات الخضراء",
    image: "assets/images/Puzzle/nature/level_5.png",
    gridSize: 6,
    requiredStars: 15,
  ),

  PuzzleLevelModel(
    id: "level_6",
    levelNumber: 6,
    title: "الشلالات",
    image: "assets/images/Puzzle/nature/level_6.png",
    gridSize: 7,
    requiredStars: 20,
  ),

  PuzzleLevelModel(
    id: "level_7",
    levelNumber: 7,
    title: "عالم النباتات",
    image: "assets/images/Puzzle/nature/level_7.png",
    gridSize: 7,
    requiredStars: 30,
  ),

  PuzzleLevelModel(
    id: "level_8",
    levelNumber: 8,
    title: "روعة الطبيعة",
    image: "assets/images/Puzzle/nature/level_8.png",
    gridSize: 8,
    requiredStars: 40,
  ),

  PuzzleLevelModel(
    id: "level_9",
    levelNumber: 9,
    title: "سر الطبيعة",
    image: "assets/images/Puzzle/nature/level_9.png",
    gridSize: 8,
    requiredStars: 50,
  ),

  PuzzleLevelModel(
    id: "level_10",
    levelNumber: 10,
    title: "التحدي النهائي",
    image: "assets/images/Puzzle/nature/level_10.png",
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
    image: "assets/images/Puzzle/landmarks/level_1.png",
    gridSize: 3,
    requiredStars: 0,
    unlocked: true,
  ),

  PuzzleLevelModel(
    id: "level_2",
    levelNumber: 2,
    title: "معالم مشهورة",
    image: "assets/images/Puzzle/landmarks/level_2.png",
    gridSize: 4,
    requiredStars: 3,
  ),

  PuzzleLevelModel(
    id: "level_3",
    levelNumber: 3,
    title: "حول العالم",
    image: "assets/images/Puzzle/landmarks/level_3.png",
    gridSize: 5,
    requiredStars: 6,
  ),

  PuzzleLevelModel(
    id: "level_4",
    levelNumber: 4,
    title: "تحدي المعالم",
    image: "assets/images/Puzzle/landmarks/level_4.png",
    gridSize: 6,
    requiredStars: 9,
  ),

  PuzzleLevelModel(
    id: "level_5",
    levelNumber: 5,
    title: "عجائب العالم",
    image: "assets/images/Puzzle/landmarks/level_5.png",
    gridSize: 6,
    requiredStars: 15,
  ),

  PuzzleLevelModel(
    id: "level_6",
    levelNumber: 6,
    title: "مدن عالمية",
    image: "assets/images/Puzzle/landmarks/level_6.png",
    gridSize: 7,
    requiredStars: 20,
  ),

  PuzzleLevelModel(
    id: "level_7",
    levelNumber: 7,
    title: "آثار قديمة",
    image: "assets/images/Puzzle/landmarks/level_7.png",
    gridSize: 7,
    requiredStars: 30,
  ),

  PuzzleLevelModel(
    id: "level_8",
    levelNumber: 8,
    title: "رحلة حول العالم",
    image: "assets/images/Puzzle/landmarks/level_8.png",
    gridSize: 8,
    requiredStars: 40,
  ),

  PuzzleLevelModel(
    id: "level_9",
    levelNumber: 9,
    title: "أشهر المعالم",
    image: "assets/images/Puzzle/landmarks/level_9.png",
    gridSize: 8,
    requiredStars: 50,
  ),

  PuzzleLevelModel(
    id: "level_10",
    levelNumber: 10,
    title: "النهائي العالمي",
    image: "assets/images/Puzzle/landmarks/level_10.png",
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


  for (final level in worldLevels) {

    if (level.id == levelId ||
        "level_${level.levelNumber}" == levelId) {

      return level;

    }

  }


  return null;

}
}