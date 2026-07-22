import '../managers/puzzle_progress_manager.dart';



class PuzzleFavoriteService {


  static Future<List<String>>

  getFavorites() async {



    return await PuzzleProgressManager

        .getFavoritePuzzles();


  }








  static Future<bool> isFavorite({

    required String puzzleId,

  }) async {



    final favorites =

    await getFavorites();





    return favorites.contains(

      puzzleId,

    );


  }








  static Future<void> addFavorite({

    required String puzzleId,

  }) async {



    final favorites =

    await getFavorites();





    if(!favorites.contains(puzzleId)){



      favorites.add(

        puzzleId,

      );





      await PuzzleProgressManager

          .saveFavoritePuzzles(

        favorites,

      );


    }


  }








  static Future<void> removeFavorite({

    required String puzzleId,

  }) async {



    final favorites =

    await getFavorites();





    favorites.remove(

      puzzleId,

    );





    await PuzzleProgressManager

        .saveFavoritePuzzles(

      favorites,

    );


  }








  static Future<void> toggleFavorite({

    required String puzzleId,

  }) async {



    if(await isFavorite(

      puzzleId: puzzleId,

    )){



      await removeFavorite(

        puzzleId: puzzleId,

      );



    }else{



      await addFavorite(

        puzzleId: puzzleId,

      );


    }


  }


}