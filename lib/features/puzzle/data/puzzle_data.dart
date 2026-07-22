import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';



class PuzzleData {



  static final List<PuzzleModel> puzzles = [



    PuzzleModel(

      id: "animals",

      title: "عالم الحيوانات 🐻",

      image: "assets/images/Puzzle/animals.png",

      levels: animalLevels,

    ),




    PuzzleModel(

      id: "nature",

      title: "عالم الطبيعة 🌳",

      image: "assets/images/Puzzle/nature.png",

      levels: natureLevels,

    ),




    PuzzleModel(

      id: "vehicles",

      title: "عالم السيارات 🚗",

      image: "assets/images/Puzzle/vehicles.png",

      levels: vehicleLevels,

    ),




  ];









  // =========================
  // مستويات الحيوانات
  // =========================


  static final List<PuzzleLevelModel> animalLevels = [



    PuzzleLevelModel(

      id:"level_1",

      gridSize:3,

      stars:3,

    ),



    PuzzleLevelModel(

      id:"level_2",

      gridSize:4,

      stars:3,

    ),



    PuzzleLevelModel(

      id:"level_3",

      gridSize:5,

      stars:3,

    ),



  ];









  // =========================
  // مستويات الطبيعة
  // =========================


  static final List<PuzzleLevelModel> natureLevels = [



    PuzzleLevelModel(

      id:"level_1",

      gridSize:3,

      stars:3,

    ),



    PuzzleLevelModel(

      id:"level_2",

      gridSize:4,

      stars:3,

    ),



    PuzzleLevelModel(

      id:"level_3",

      gridSize:6,

      stars:3,

    ),



  ];









  // =========================
  // مستويات السيارات
  // =========================


  static final List<PuzzleLevelModel> vehicleLevels = [



    PuzzleLevelModel(

      id:"level_1",

      gridSize:3,

      stars:3,

    ),



    PuzzleLevelModel(

      id:"level_2",

      gridSize:5,

      stars:3,

    ),



    PuzzleLevelModel(

      id:"level_3",

      gridSize:6,

      stars:3,

    ),



  ];



}
