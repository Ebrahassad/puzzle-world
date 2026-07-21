import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game_core/worlds/world_progress.dart';
import '../game_core/worlds/world_data.dart';



class WorldNotifier extends StateNotifier<List<WorldProgress>> {


  WorldNotifier()

      : super(

          WorldData.createWorlds(),

        );





  WorldProgress? getWorld(String id){


    try{


      return state.firstWhere(

        (world)=>world.worldId == id,

      );


    }catch(e){


      return null;


    }


  }






  void completeLevel(String worldId){



    final index = state.indexWhere(

          (world)=>world.worldId == worldId,

    );





    if(index == -1){

      return;

    }




    final world = state[index];





    final completed =

    world.completedLevels + 1;





    state = [


      ...state.sublist(0,index),



      world.copyWith(


        completedLevels: completed,


        unlocked:true,


      ),



      ...state.sublist(index + 1),


    ];



    unlockNextWorld();

  }







  void unlockNextWorld(){


    for(int i = 0; i < state.length - 1; i++){



      if(state[i].completed){



        final next = state[i + 1];



        if(!next.unlocked){



          state = [



            ...state.sublist(0,i + 1),



            next.copyWith(

              unlocked:true,

            ),



            ...state.sublist(i + 2),



          ];



        }



      }



    }


  }



}






final worldProvider =

StateNotifierProvider<WorldNotifier,List<WorldProgress>>(

  (ref)=>WorldNotifier(),

);
