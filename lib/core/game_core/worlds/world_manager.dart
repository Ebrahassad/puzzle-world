import 'world_progress.dart';



class WorldManager {


  final List<WorldProgress> worlds;



  WorldManager({

    required this.worlds,

  });





  WorldProgress? getWorld(String id){


    try{


      return worlds.firstWhere(

        (world)=>world.worldId == id,

      );


    }catch(e){


      return null;


    }


  }





  bool isUnlocked(String id){


    final world = getWorld(id);


    return world?.unlocked ?? false;


  }





  void completeLevel(String id){



    final index = worlds.indexWhere(

          (world)=>world.worldId == id,

    );




    if(index == -1){

      return;

    }




    final world = worlds[index];




    worlds[index] = world.copyWith(



      completedLevels:

      world.completedLevels + 1,



      unlocked:true,



    );



  }





}