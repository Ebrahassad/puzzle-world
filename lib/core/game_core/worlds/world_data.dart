import 'world_progress.dart';


class WorldData {


  static List<WorldProgress> createWorlds(){


    return [


      const WorldProgress(

        worldId: "animals",

        completedLevels: 0,

        totalLevels: 24,

        unlocked: true,

      ),




      const WorldProgress(

        worldId: "nature",

        completedLevels: 0,

        totalLevels: 20,

      ),




      const WorldProgress(

        worldId: "cars",

        completedLevels: 0,

        totalLevels: 18,

      ),




      const WorldProgress(

        worldId: "space",

        completedLevels: 0,

        totalLevels: 20,

      ),




      const WorldProgress(

        worldId: "cities",

        completedLevels: 0,

        totalLevels: 20,

      ),




      const WorldProgress(

        worldId: "custom",

        completedLevels: 0,

        totalLevels: 999,

      ),


    ];


  }


}