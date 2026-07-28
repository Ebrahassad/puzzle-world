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
    with TickerProviderStateMixin {



  late AnimationController floatController;

  late AnimationController backgroundController;


  late Animation<double> floatAnimation;

  late Animation<double> backgroundAnimation;



  String? pressedIsland;



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

  @override
  void initState() {

    super.initState();


    // حركة طفو الجزر

    floatController = AnimationController(

      vsync: this,

      duration: const Duration(
        seconds: 3,
      ),

    )..repeat(
      reverse: true,
    );



    floatAnimation = Tween<double>(

      begin: -8,

      end: 8,

    ).animate(

      CurvedAnimation(

        parent: floatController,

        curve: Curves.easeInOut,

      ),

    );





    // حركة خلفية الخريطة

    backgroundController = AnimationController(

      vsync: this,

      duration: const Duration(
        seconds: 25,
      ),

    )..repeat(
      reverse: true,
    );



    backgroundAnimation = Tween<double>(

      begin: -12,

      end: 12,

    ).animate(

      CurvedAnimation(

        parent: backgroundController,

        curve: Curves.easeInOut,

      ),

    );


  }







  void openWorld(PuzzleModel world){


    Navigator.push(

      context,


      PageRouteBuilder(


        transitionDuration:

        const Duration(
          milliseconds:700,
        ),



        pageBuilder:

            (_,animation,secondaryAnimation){



          return FadeTransition(


            opacity: animation,


            child: IslandScreen(

              island: world,

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

      {

      double size = 140,

      }

      ) {



    final world =

    PuzzleData.getById(id);



    if(world == null){

      return const SizedBox();

    }




    // الحيوانات فقط مفتوحة

    final bool unlocked =

        id == "animals";





    return Positioned(


      left: x - size / 2,


      top: y - size / 2,


      width: size,


      height: size,




      child: AnimatedBuilder(


        animation: floatAnimation,



        builder: (context,child){



          return Transform.translate(


            offset: Offset(

              0,

              floatAnimation.value,

            ),



            child: child,


          );


        },




        child: GestureDetector(



          onTapDown: unlocked

              ? (_) {

            setState(() {

              pressedIsland = id;

            });

          }

              : null,





          onTapUp: unlocked

              ? (_) {


            setState(() {

              pressedIsland = null;

            });


            openWorld(world);


          }

              : null,





          onTapCancel: unlocked

              ? () {

            setState(() {

              pressedIsland = null;

            });


          }

              : null,





          child: AnimatedScale(


            scale:

            pressedIsland == id

                ? 1.15

                : 1.0,



            duration:

            const Duration(
              milliseconds:180,
            ),




            child: Stack(


              alignment: Alignment.center,


              children: [



                Opacity(


                  opacity:

                  unlocked

                      ? 1.0

                      : 0.45,



                  child: Image.asset(


                    islandImages[id]!,


                    fit: BoxFit.contain,


                  ),


                ),





                if(!unlocked)


                  Image.asset(


                    "assets/images/ui/level_lock.png",


                    width: size * 0.35,


                  ),



              ],


            ),



          ),


        ),


      ),


    );


  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(


      body: Stack(


        fit: StackFit.expand,


        children: [



          // خلفية العالم بحركة بسيطة

          Positioned.fill(


            child: AnimatedBuilder(


              animation: backgroundAnimation,


              builder: (context, child){


                return Transform.translate(


                  offset: Offset(

                    backgroundAnimation.value,

                    0,

                  ),


                  child: child,


                );


              },



              child: Image.asset(


                "assets/images/world/world_map.png",


                fit: BoxFit.cover,


              ),


            ),


          ),






          // طبقة إضاءة خفيفة

          Container(

            color: Colors.black.withOpacity(0.08),

          ),






          SafeArea(


            child: LayoutBuilder(


              builder: (context, constraints){



                final width =

                constraints.maxWidth;



                final height =

                constraints.maxHeight;





                return Stack(



                  children: [





                    // جزيرة الفضاء - أعلى الشاشة في الوسط

                    islandButton(


                      "space",


                      width * 0.5,


                      height * 0.13,


                      size: 180,


                    ),






                    // جزيرة الحيوانات - العالم الأول المفتوح

                    islandButton(


                      "animals",


                      width * 0.35,


                      height * 0.48,


                      size: 150,


                    ),






                    // جزيرة المعالم - مقفلة

                    islandButton(


                      "landmarks",


                      width * 0.75,


                      height * 0.50,


                      size: 150,


                    ),






                    // جزيرة السيارات - مقفلة

                    islandButton(


                      "cars",


                      width * 0.25,


                      height * 0.75,


                      size: 150,


                    ),






                    // جزيرة الطبيعة - مقفلة

                    islandButton(


                      "nature",


                      width * 0.72,


                      height * 0.78,


                      size: 150,


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


    backgroundController.dispose();



    super.dispose();


  }
}