import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';


import '../data/puzzle_world_data.dart';
import '../data/island_map_data.dart';


import '../models/puzzle_model.dart';
import '../models/island_map_model.dart';


import '../managers/puzzle_progress_manager.dart';
import '../managers/reward_manager.dart';


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



  final String mapImage =
      "assets/images/world/world_map.png";





  late List<PuzzleModel> islands;




  final Map<String, IslandMapModel>
      islandPositions =
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



    //==================================================
    // LOAD DATA
    //==================================================


    islands =
        puzzleWorldData;





    //==================================================
    // MAP ANIMATION
    //==================================================


    mapController =
        AnimationController(

          vsync: this,

          duration:
          const Duration(

            seconds: 18,

          ),

        )
          ..repeat(

            reverse: true,

          );





    mapScaleAnimation =
        Tween<double>(


          begin: 1.0,


          end: 1.08,


        ).animate(


          CurvedAnimation(

            parent:
            mapController,


            curve:
            Curves.easeInOut,


          ),


        );





    mapMoveAnimation =
        Tween<Offset>(


          begin:
          Offset.zero,


          end:
          const Offset(

            0.02,

            -0.02,

          ),


        ).animate(


          CurvedAnimation(

            parent:
            mapController,


            curve:
            Curves.easeInOut,


          ),


        );






    //==================================================
    // STARS ANIMATION
    //==================================================


    starsController =
        AnimationController(

          vsync: this,

          duration:
          const Duration(

            seconds: 8,

          ),

        )
          ..repeat();





    starsAnimation =
        Tween<double>(


          begin: 0,


          end: 1,


        ).animate(


          CurvedAnimation(

            parent:
            starsController,


            curve:
            Curves.linear,


          ),


        );






    //==================================================
    // SEA ANIMATION
    //==================================================


    seaController =
        AnimationController(

          vsync: this,

          duration:
          const Duration(

            seconds: 10,

          ),

        )
          ..repeat(

            reverse: true,

          );





    seaAnimation =
        Tween<double>(


          begin: 0.05,


          end: 0.15,


        ).animate(


          CurvedAnimation(

            parent:
            seaController,


            curve:
            Curves.easeInOut,


          ),


        );






    //==================================================
    // ISLAND FLOAT
    //==================================================


    for (final island in islands) {


      final controller =
          AnimationController(

            vsync: this,


            duration:
            Duration(

              seconds:
              3 +
                  math.Random()
                      .nextInt(4),


            ),


          )
            ..repeat(

              reverse: true,

            );





      islandControllers[island.id] =
          controller;





      islandAnimations[island.id] =
          Tween<double>(


            begin: -6,


            end: 6,


          ).animate(


            CurvedAnimation(

              parent:
              controller,


              curve:
              Curves.easeInOut,


            ),


          );


    }


  }


  //==================================================
  // DISPOSE
  //==================================================


  @override
  void dispose() {


    mapController.dispose();


    starsController.dispose();


    seaController.dispose();




    for (final controller
        in islandControllers.values) {


      controller.dispose();


    }




    super.dispose();


  }







  //==================================================
  // BUILD
  //==================================================


  @override
  Widget build(BuildContext context) {


    return Scaffold(


      extendBodyBehindAppBar: true,



      body: Stack(


        children: [





          //==================================================
          // BACKGROUND MAP
          //==================================================


          AnimatedBuilder(

            animation:
            mapController,


            builder:
                (
                context,
                child,
                ) {


              return Positioned.fill(


                child:
                Transform.translate(


                  offset:
                  mapMoveAnimation.value * 80,



                  child:
                  Transform.scale(


                    scale:
                    mapScaleAnimation.value,



                    child:
                    Image.asset(


                      mapImage,


                      fit:
                      BoxFit.cover,


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

            animation:
            starsController,


            builder:
                (
                context,
                child,
                ) {


              return Positioned.fill(


                child:
                IgnorePointer(


                  child:
                  CustomPaint(


                    painter:
                    StarFieldPainter(


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

            animation:
            seaController,


            builder:
                (
                context,
                child,
                ) {


              return Positioned.fill(


                child:
                IgnorePointer(


                  child:
                  Container(


                    decoration:
                    BoxDecoration(


                      gradient:
                      LinearGradient(


                        begin:
                        Alignment.topLeft,


                        end:
                        Alignment.bottomRight,



                        colors: [


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

            child:
            Stack(

              children: [


                ...islands.map(

                  (island) {


                    final mapData =
                        islandPositions[island.id];



                    if (mapData == null) {

                      return const SizedBox();

                    }




                    final animation =
                        islandAnimations[island.id];




                    return AnimatedBuilder(


                      animation:
                      animation!,



                      builder:
                          (
                          context,
                          child,
                          ) {



                        return Positioned(


                          left:
                          mapData.position.dx,



                          top:
                          mapData.position.dy +
                              animation.value,



                          child:
                          GestureDetector(



                            onTapDown:
                                (_) {


                              setState(() {

                                selectedIsland =
                                    island.id;


                              });


                            },



                            onTapCancel:
                                () {


                              setState(() {

                                selectedIsland =
                                    null;


                              });


                            },



                            onTap:
                                () {


                              setState(() {

                                selectedIsland =
                                    null;


                              });



                              openIsland(
                                island,
                              );


                            },



                            child:
                            AnimatedContainer(


                              duration:
                              const Duration(

                                milliseconds: 250,

                              ),



                              transform:
                              selectedIsland ==
                                  island.id

                                  ?

                              Matrix4.identity()
                                ..scale(1.08)


                                  :

                              Matrix4.identity(),




                              child:
                              Stack(


                                alignment:
                                Alignment.center,



                                children: [





                                  Image.asset(


                                    island.image,


                                    width:
                                    mapData.size,


                                    height:
                                    mapData.size,


                                  ),






                                  if(
                                  selectedIsland ==
                                      island.id
                                  )

                                    Container(


                                      width:
                                      mapData.size,


                                      height:
                                      mapData.size,



                                      decoration:
                                      BoxDecoration(


                                        shape:
                                        BoxShape.circle,



                                        boxShadow: [


                                          BoxShadow(


                                            color:
                                            Colors.yellow
                                                .withOpacity(
                                                0.75
                                            ),



                                            blurRadius:
                                            35,



                                            spreadRadius:
                                            8,


                                          ),


                                        ],


                                      ),


                                    ),






                                  if(
                                  !islandUnlocked(
                                      island
                                  )
                                  )

                                    Container(


                                      width:
                                      mapData.size * 0.35,


                                      height:
                                      mapData.size * 0.35,



                                      decoration:
                                      const BoxDecoration(


                                        color:
                                        Colors.black54,



                                        shape:
                                        BoxShape.circle,


                                      ),



                                      child:
                                      const Icon(


                                        Icons.lock,


                                        color:
                                        Colors.white,



                                        size:
                                        35,


                                      ),


                                    ),



                                ],

                              ),


                            ),


                          ),


                        );


                      },


                    );


                  },


                ),


              ],


            ),

          ),





          //==================================================
          // TOOLBAR
          //==================================================


          const Align(

            alignment:
            Alignment.topCenter,


            child:
            GameToolbar(),


          ),



        ],

      ),

    );


  }






  //==================================================
  // CHECK ISLAND UNLOCK
  //==================================================


  bool islandUnlocked(
      PuzzleModel island
      ) {


    return PuzzleProgressManager
        .isIslandUnlocked(
        island.id
    );


  }






  //==================================================
  // OPEN ISLAND
  //==================================================


  void openIsland(
      PuzzleModel island
      ) async {



    if (!islandUnlocked(island)) {



      await RewardManager
          .showUnlockIslandAd(
          island.id
      );



      return;


    }





    if (!mounted) {

      return;

    }




    Navigator.push(


      context,


      MaterialPageRoute(


        builder:
            (_) => IslandScreen(


          island:
          island,


        ),


      ),


    );


  }


}







//==================================================
// STAR FIELD PAINTER
//==================================================


class StarFieldPainter extends CustomPainter {


  final double animation;



  StarFieldPainter(
      this.animation,
      );





  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {



    final paint =
    Paint();




    final random =
    math.Random(10);





    for(
    int i = 0;
    i < 80;
    i++
    ) {



      final x =
          random.nextDouble()
              *
              size.width;



      final baseY =
          random.nextDouble()
              *
              size.height;



      final y =
          (
              baseY +
                  animation *
                      40 *
                      (i % 3 + 1)
          )
              %
              size.height;




      final radius =
          random.nextDouble()
              *
              1.8
              +
              0.5;





      paint.color =
          Colors.white.withOpacity(


            0.25 +
                (
                    math.sin(
                      animation *
                          math.pi *
                          2 +
                          i,
                    )
                        +
                        1
                )
                /
                4,


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
      ) {


    return oldDelegate.animation !=
        animation;


  }


}