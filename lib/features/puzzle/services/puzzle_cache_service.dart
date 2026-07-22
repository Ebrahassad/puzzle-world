import '../models/puzzle_model.dart';

import '../models/puzzle_level_model.dart';



class PuzzleCacheService {


  static final Map<String, PuzzleModel> _worldCache = {};

  static final Map<String, List<PuzzleLevelModel>> _levelCache = {};








  static void cacheWorld(

      PuzzleModel world,

      ) {



    _worldCache[world.id] = world;


  }








  static PuzzleModel? getWorld(

      String worldId,

      ) {



    return _worldCache[worldId];


  }








  static void cacheLevels({

    required String worldId,

    required List<PuzzleLevelModel> levels,

  }) {



    _levelCache[worldId] = levels;


  }








  static List<PuzzleLevelModel>

  getLevels(

      String worldId,

      ) {



    return _levelCache[worldId] ?? [];


  }








  static bool hasWorld(

      String worldId,

      ) {



    return _worldCache.containsKey(

      worldId,

    );


  }








  static bool hasLevels(

      String worldId,

      ) {



    return _levelCache.containsKey(

      worldId,

    );


  }








  static void removeWorld(

      String worldId,

      ) {



    _worldCache.remove(

      worldId,

    );


    _levelCache.remove(

      worldId,

    );


  }








  static void clear() {



    _worldCache.clear();


    _levelCache.clear();


  }


}