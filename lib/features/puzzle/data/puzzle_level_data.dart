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