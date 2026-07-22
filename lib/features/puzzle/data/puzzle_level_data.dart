import '../models/puzzle_level_model.dart';


class PuzzleLevelData {


  static const Map<String, List<PuzzleLevelModel>> levels = {


    "animals":[

      PuzzleLevelModel(
        id:"level_1",
        gridSize:3,
        requiredStars:0,
        unlocked:true,
      ),

      PuzzleLevelModel(
        id:"level_2",
        gridSize:4,
        requiredStars:3,
      ),

      PuzzleLevelModel(
        id:"level_3",
        gridSize:5,
        requiredStars:6,
      ),

      PuzzleLevelModel(
        id:"level_4",
        gridSize:6,
        requiredStars:9,
      ),

    ],





    "nature":[

      PuzzleLevelModel(
        id:"level_1",
        gridSize:3,
        requiredStars:0,
        unlocked:true,
      ),

      PuzzleLevelModel(
        id:"level_2",
        gridSize:4,
        requiredStars:3,
      ),

      PuzzleLevelModel(
        id:"level_3",
        gridSize:5,
        requiredStars:6,
      ),

    ],





    "vehicles":[

      PuzzleLevelModel(
        id:"level_1",
        gridSize:3,
        requiredStars:0,
        unlocked:true,
      ),

      PuzzleLevelModel(
        id:"level_2",
        gridSize:5,
        requiredStars:3,
      ),

      PuzzleLevelModel(
        id:"level_3",
        gridSize:6,
        requiredStars:6,
      ),

    ],





    "fruits":[

      PuzzleLevelModel(
        id:"level_1",
        gridSize:3,
        requiredStars:0,
        unlocked:true,
      ),

      PuzzleLevelModel(
        id:"level_2",
        gridSize:4,
        requiredStars:3,
      ),

      PuzzleLevelModel(
        id:"level_3",
        gridSize:5,
        requiredStars:6,
      ),

      PuzzleLevelModel(
        id:"level_4",
        gridSize:6,
        requiredStars:9,
      ),

    ],


  };





  static List<PuzzleLevelModel> getLevels(

      String puzzleId,

      ){

    return levels[puzzleId] ?? [];

  }


}