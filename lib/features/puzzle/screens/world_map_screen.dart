import 'package:flutter/material.dart';

import '../data/puzzle_data.dart';
import '../models/puzzle_model.dart';

import 'island_screen.dart';



class WorldMapScreen extends StatefulWidget {

  const WorldMapScreen({
    super.key,
  });


  @override
  State<WorldMapScreen> createState() =>
      _WorldMapScreenState();

}





class _WorldMapScreenState
    extends State<WorldMapScreen>
    with SingleTickerProviderStateMixin {


  late AnimationController floatController;

  late Animation<double> floatAnimation;


  final Map<String,String> islandImages = {


    "animals":
    "assets/images/islands/animals_island.png",


    "cars":
    "assets/images/islands/cars_island.png",


    "space":
    "assets/images/islands/space_island.png",


    "landmarks":
    "assets/images/islands/world_landmarks_island.png",


    "nature":
    "assets/images/islands/nature_island.png",


  };




  String? pressedIsland;




  @override
  void initState(){

    super.initState();


    floatController = AnimationController(

      vsync:this,

      duration:
      const Duration(seconds:3),

    )..repeat(
      reverse:true,
    );



    floatAnimation = Tween<double>(

      begin:-8,

      end:8,

    ).animate(

      CurvedAnimation(

        parent:floatController,

        curve:Curves.easeInOut,

      ),

    );


  }






  void openWorld(PuzzleModel world){


    Navigator.push(

      context,

      PageRouteBuilder(

        transitionDuration:
        const Duration(milliseconds:700),


        pageBuilder:
            (_,animation,secondaryAnimation){


          return FadeTransition(

            opacity:animation,

            child:

            IslandScreen(

              island:world,

            ),

          );


        },

      ),

    );


  }
Widget islandButton(
    String id,
    double x,
    double y,
) {


  final world =
  PuzzleData.getById(id);


  if(world == null){
    return const SizedBox();
  }



  return Positioned(


    left:x-70,

    top:y-70,


    width:140,

    height:140,



    child: AnimatedBuilder(


      animation:floatAnimation,


      builder:(context,child){


        return Transform.translate(


          offset:Offset(
            0,
            floatAnimation.value,
          ),


          child:child,


        );


      },



      child: GestureDetector(


        onTapDown:(_){


          setState((){

            pressedIsland=id;

          });


        },



        onTapUp:(_){


          setState((){

            pressedIsland=null;

          });



          openWorld(world);


        },



        onTapCancel:(){


          setState((){

            pressedIsland=null;

          });


        },



        child: AnimatedScale(


          scale:

          pressedIsland==id
              ?1.18
              :1.0,


          duration:

          const Duration(
              milliseconds:180
          ),



          child: Hero(


            tag:id,


            child: Image.asset(


              islandImages[id]!,


              fit:BoxFit.contain,


            ),


          ),


        ),


      ),


    ),


  );

}
@override
Widget build(BuildContext context){


return Scaffold(


body:Stack(


children:[



Positioned.fill(


child:Image.asset(


"assets/images/world/world_map.png",


fit:BoxFit.cover,


),


),




SafeArea(


child:LayoutBuilder(


builder:(context,constraints){



final width =
constraints.maxWidth;


final height =
constraints.maxHeight;



return Stack(


children:[



// جزيرة الفضاء أعلى اليسار

islandButton(

"space",

width*0.22,

height*0.14,

),




// الحيوانات

islandButton(

"animals",

width*0.28,

height*0.32,

),




// المعالم

islandButton(

"landmarks",

width*0.75,

height*0.38,

),




// السيارات أسفل

islandButton(

"cars",

width*0.22,

height*0.70,

),




// الطبيعة

islandButton(

"nature",

width*0.55,

height*0.78,

),



],



);



},


),


),



],


),


);


}




@override
void dispose(){

floatController.dispose();

super.dispose();

}
}