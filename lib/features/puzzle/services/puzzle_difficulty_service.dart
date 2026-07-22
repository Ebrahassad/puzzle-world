import '../models/puzzle_level_model.dart';



class PuzzleDifficultyService {


  static String getDifficultyName(

      PuzzleLevelModel level,

      ) {



    switch(level.gridSize){


      case 3:

        return "سهل";



      case 4:

        return "متوسط";



      case 5:

        return "صعب";



      case 6:

        return "خبير";



      default:

        return "تحدي";


    }


  }








  static int getDifficultyNumber(

      PuzzleLevelModel level,

      ) {



    if(level.gridSize <= 3){

      return 1;

    }



    if(level.gridSize <= 4){

      return 2;

    }



    if(level.gridSize <= 5){

      return 3;

    }



    return 4;


  }








  static int getRewardMultiplier(

      PuzzleLevelModel level,

      ) {



    return getDifficultyNumber(

      level,

    );


  }








  static int getRecommendedMoves(

      PuzzleLevelModel level,

      ) {



    final pieces =

    level.gridSize *

        level.gridSize;



    return pieces * 3;


  }








  static Duration getRecommendedTime(

      PuzzleLevelModel level,

      ) {



    switch(level.gridSize){


      case 3:

        return const Duration(

          seconds:60,

        );



      case 4:

        return const Duration(

          seconds:120,

        );



      case 5:

        return const Duration(

          seconds:180,

        );



      default:

        return const Duration(

          seconds:240,

        );


    }


  }








  static bool isHard(

      PuzzleLevelModel level,

      ) {



    return level.gridSize >= 5;


  }


}