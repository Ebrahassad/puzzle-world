import '../data/puzzle_data.dart';

import '../data/puzzle_level_data.dart';

import '../models/puzzle_model.dart';

import '../models/puzzle_level_model.dart';

import '../services/puzzle_cache_service.dart';



class PuzzleLoadingService {


  static Future<List<PuzzleModel>>

  loadWorlds() async {



    final worlds =

    PuzzleData.puzzles;





    for(final world in worlds){


      PuzzleCacheService

          .cacheWorld(

        world,

      );


    }





    return worlds;


  }








  static Future<PuzzleModel?>

  loadWorld({

    required String worldId,

  }) async {



    final cached =

    PuzzleCacheService

        .getWorld(

      worldId,

    );





    if(cached != null){

      return cached;

    }





    for(final world in PuzzleData.puzzles){


      if(world.id == worldId){


        PuzzleCacheService

            .cacheWorld(

          world,

        );


        return world;


      }


    }





    return null;


  }








  static Future<List<PuzzleLevelModel>>

  loadLevels({

    required String worldId,

  }) async {



    final cached =

    PuzzleCacheService

        .getLevels(

      worldId,

    );





    if(cached.isNotEmpty){


      return cached;


    }





    final levels =

    PuzzleLevelData

        .getLevels(

      worldId,

    );





    PuzzleCacheService

        .cacheLevels(

      worldId: worldId,

      levels: levels,

    );





    return levels;


  }








  static Future<PuzzleLevelModel?>

  loadLevel({

    required String worldId,

    required String levelId,

  }) async {



    final levels =

    await loadLevels(

      worldId: worldId,

    );





    for(final level in levels){


      if(level.id == levelId){


        return level;


      }


    }





    return null;


  }








  static void clearCache(){


    PuzzleCacheService

        .clear();


  }


}