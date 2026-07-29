import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/puzzle_data.dart';
import '../data/island_map_data.dart';

import '../models/puzzle_model.dart';
import '../models/island_map_model.dart';

import '../widgets/game_toolbar.dart';

import 'island_screen.dart';



class WorldMapScreen extends StatefulWidget {

  const WorldMapScreen({
    super.key,
  });


  @override
  State<WorldMapScreen> createState() =>
      _WorldMapScreenState();

}



class _WorldMapScreenState extends State<WorldMapScreen>
    with TickerProviderStateMixin {



  static const String mapImage =
      "assets/images/world/world_map.png";



  late final List<PuzzleModel> islands;



  final Map<String, IslandMapModel> islandPositions =
      IslandMapData.positions;



  String? selectedIsland;



  late AnimationController mapController;

  late Animation<double> mapScaleAnimation;

  late Animation<Offset> mapMoveAnimation;



  late AnimationController starsController;

  late Animation<double> starsAnimation;



  late AnimationController seaController;

  late Animation<double> seaAnimation;



  final Map<String, AnimationController>
      islandControllers = {};



  final Map<String, Animation<double>>
      islandAnimations = {};





  @override
  void initState() {

    super.initState();

islands = PuzzleData.puzzles;


    mapController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 18,
      ),
    )..repeat(
      reverse:true,
    );



    mapScaleAnimation =
        Tween<double>(
          begin:1.0,
          end:1.08,
        ).animate(
          CurvedAnimation(
            parent:mapController,
            curve:Curves.easeInOut,
          ),
        );



    mapMoveAnimation =
        Tween<Offset>(
          begin:Offset.zero,
          end:const Offset(
            0.02,
            -0.02,
          ),
        ).animate(
          CurvedAnimation(
            parent:mapController,
            curve:Curves.easeInOut,
          ),
        );



    starsController = AnimationController(
      vsync:this,
      duration:const Duration(
        seconds:8,
      ),
    )..repeat();



    starsAnimation =
        Tween<double>(
          begin:0,
          end:1,
        ).animate(
          CurvedAnimation(
            parent:starsController,
            curve:Curves.linear,
          ),
        );



    seaController = AnimationController(
      vsync:this,
      duration:const Duration(
        seconds:10,
      ),
    )..repeat(
      reverse:true,
    );



    seaAnimation =
        Tween<double>(
          begin:0.05,
          end:0.15,
        ).animate(
          CurvedAnimation(
            parent:seaController,
            curve:Curves.easeInOut,
          ),
        );



    for(final island in islands){

      final controller =
      AnimationController(
        vsync:this,
        duration:Duration(
          seconds:3 + math.Random().nextInt(4),
        ),
      );



      final animation =
      Tween<double>(
        begin:-8,
        end:8,
      ).animate(
        CurvedAnimation(
          parent:controller,
          curve:Curves.easeInOut,
        ),
      );



      islandControllers[island.id] =
          controller;


      islandAnimations[island.id] =
          animation;



      controller.repeat(
        reverse:true,
      );

    }


  }

  //==================================================
  // BUILD
  //==================================================


  @override
  Widget build(BuildContext context) {


    return Scaffold(

      extendBodyBehindAppBar:true,


      body:Stack(

        children:[



          //==================================================
          // BACKGROUND MAP
          //==================================================


          AnimatedBuilder(

            animation:mapController,


            builder:(context,child){


              return Positioned.fill(


                child:Transform.translate(

                  offset:
                  mapMoveAnimation.value * 80,


                  child:Transform.scale(

                    scale:
                    mapScaleAnimation.value,


                    child:Image.asset(

                      mapImage,

                      fit:BoxFit.cover,

                    ),

                  ),

                ),

              );


            },

          ),




          //==================================================
          // STAR FIELD
          //==================================================


          AnimatedBuilder(

            animation:starsController,


            builder:(context,child){


              return Positioned.fill(


                child:IgnorePointer(

                  child:CustomPaint(

                    painter:StarFieldPainter(

                      starsAnimation.value,

                    ),

                  ),

                ),

              );


            },

          ),





          //==================================================
          // SEA EFFECT
          //==================================================


          AnimatedBuilder(

            animation:seaController,


            builder:(context,child){


              return Positioned.fill(


                child:IgnorePointer(

                  child:Container(

                    decoration:BoxDecoration(

                      gradient:LinearGradient(

                        begin:Alignment.topLeft,

                        end:Alignment.bottomRight,


                        colors:[


                          Colors.white.withOpacity(
                            seaAnimation.value,
                          ),


                          Colors.transparent,


                          Colors.blue.withOpacity(
                            seaAnimation.value,
                          ),


                        ],

                      ),

                    ),

                  ),

                ),

              );


            },

          ),






          //==================================================
          // ISLANDS
          //==================================================


          SafeArea(

            child:Stack(

              children:[


                ...islands.map((island){


                  final mapData =
                      islandPositions[island.id];



                  if(mapData == null){

                    return const SizedBox();

                  }




                  final animation =
                      islandAnimations[island.id]!;




                  return AnimatedBuilder(

                    animation:animation,


                    builder:(context,child){


                      return Positioned(

                        left:
                        mapData.position.dx,


                        top:
                        mapData.position.dy +
                            animation.value,



                        child:GestureDetector(



                          onTapDown:(_){


                            setState((){

                              selectedIsland =
                                  island.id;

                            });


                          },



                          onTapCancel:(){


                            setState((){

                              selectedIsland = null;

                            });


                          },



                          onTap:(){


                            setState((){

                              selectedIsland = null;

                            });



                            openIsland(island);


                          },




                          child:AnimatedContainer(


                            duration:
                            const Duration(
                              milliseconds:250,
                            ),



                            transform:
                            selectedIsland == island.id

                                ? (Matrix4.identity()
                              ..scale(1.08))

                                : Matrix4.identity(),




                            child:Image.asset(


                              island.image,


                              width:
                              mapData.size,


                              height:
                              mapData.size,


                              fit:BoxFit.contain,


                            ),


                          ),

                        ),

                      );


                    },

                  );


                }),


              ],

            ),

          ),




//==================================================
// TOOLBAR
//==================================================

Align(

  alignment: Alignment.topCenter,

  child: GameToolbar(

    logo: "assets/images/ui/puzzle_logo.png",

  ),

),
        ],

      ),

    );


  }






  //==================================================
  // OPEN ISLAND
  //==================================================


  void openIsland(
      PuzzleModel island,
      ) {


    Navigator.push(

      context,


      MaterialPageRoute(

        builder:(_)=>IslandScreen(

          island:island,

        ),

      ),

    );


  }

  //==================================================
  // DISPOSE
  //==================================================


  @override
  void dispose(){


    mapController.dispose();


    starsController.dispose();


    seaController.dispose();




    for(final controller in islandControllers.values){


      controller.dispose();


    }



    super.dispose();


  }


}








//==================================================
// STAR FIELD PAINTER
//==================================================


class StarFieldPainter extends CustomPainter {



  final double animation;




  const StarFieldPainter(

      this.animation,

      );





  @override
  void paint(

      Canvas canvas,

      Size size,

      ){



    final paint = Paint();



    final random = math.Random(10);





    for(int i = 0; i < 80; i++){



      final x =

      random.nextDouble() *

          size.width;





      final baseY =

      random.nextDouble() *

          size.height;






      final y =

      (baseY +

          animation *

              40 *

              (i % 3 + 1))

          %

          size.height;







      final radius =

          random.nextDouble() *

              1.8 +

              0.5;







      paint.color =

          Colors.white.withOpacity(


            0.25 +


                (math.sin(

                  animation *

                      math.pi *

                      2 +

                      i,

                ) + 1) / 4,



          );







      canvas.drawCircle(


        Offset(

          x,

          y,

        ),


        radius,


        paint,


      );



    }


  }






  @override
  bool shouldRepaint(

      covariant StarFieldPainter oldDelegate,

      ){



    return oldDelegate.animation != animation;


  }


}