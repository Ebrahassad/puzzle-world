import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';



class PuzzleImageService {


  static ImageProvider getImage(

      PuzzleModel puzzle,

      ) {


    if(puzzle.image.isEmpty){


      return const AssetImage(

        "assets/images/Puzzle/puzzle_placeholder.png",

      );


    }





    return AssetImage(

      puzzle.image,

    );


  }








  static ImageProvider getImageFromPath(

      String path,

      ) {


    if(path.isEmpty){


      return const AssetImage(

        "assets/images/Puzzle/puzzle_placeholder.png",

      );


    }





    return AssetImage(

      path,

    );


  }








  static bool isValidImage(

      String path,

      ) {


    return path.isNotEmpty;


  }








  static String getWorldImagePath(

      String worldId,

      ) {



    switch(worldId){



      case "animals":

        return "assets/images/Puzzle/animals.png";





      case "nature":

        return "assets/images/Puzzle/nature.png";





      case "vehicles":

        return "assets/images/Puzzle/vehicles.png";





      case "fruits":

        return "assets/images/Puzzle/fruits.png";





      default:

        return "assets/images/Puzzle/puzzle_placeholder.png";



    }


  }








  static ImageProvider getWorldImage(

      String worldId,

      ) {


    return AssetImage(

      getWorldImagePath(

        worldId,

      ),

    );


  }

}