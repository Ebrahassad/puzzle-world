import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/puzzle_data.dart';
import '../models/puzzle_model.dart';

import 'island_screen.dart';

import '../managers/puzzle_progress_manager.dart';
import '../managers/reward_manager.dart';

import '../widgets/game_toolbar.dart';



class WorldMapScreen extends StatefulWidget {

  const WorldMapScreen({
    super.key,
  });


  @override
  State<WorldMapScreen> createState() =>
      _WorldMapScreenState();

}




class _WorldMapScreenState extends State<WorldMapScreen>
    with
        TickerProviderStateMixin {



  //==================================================
  // IMAGE
  //==================================================

  final String mapImage =
      "assets/images/world/world_map.png";



  //==================================================
  // MAP ANIMATION
  //==================================================

  late AnimationController mapController;

  late Animation<double> mapScaleAnimation;

  late Animation<Offset> mapMoveAnimation;



  //==================================================
  // STAR FIELD ANIMATION
  //==================================================

  late AnimationController starsController;

  late Animation<double> starsAnimation;



  //==================================================
  // SEA EFFECT ANIMATION
  //==================================================

  late AnimationController seaController;

  late Animation<double> seaAnimation;



  //==================================================
  // ISLAND FLOAT ANIMATIONS
  //==================================================

  final Map<String, AnimationController>
      islandControllers = {};

  final Map<String, Animation<double>>
      islandAnimations = {};



  //==================================================
  // TAP EFFECT
  //==================================================

  String? selectedIsland;



  //==================================================
  // DATA
  //==================================================

  late List<PuzzleModel> islands;



  //==================================================
  // TIMER
  //==================================================

  Timer? refreshTimer;



  @override
  void initState() {

    super.initState();



    islands = puzzleWorld;



    //==============================
    // BACKGROUND MAP ZOOM + MOVE
    //==============================

    mapController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 18,
      ),
    )..repeat(
      reverse: true,
    );


    mapScaleAnimation =
        Tween<double>(
          begin: 1.0,
          end: 1.08,
        ).animate(
          CurvedAnimation(
            parent: mapController,
            curve: Curves.easeInOut,
          ),
        );



    mapMoveAnimation =
        Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(
            0.02,
            -0.02,
          ),
        ).animate(
          CurvedAnimation(
            parent: mapController,
            curve: Curves.easeInOut,
          ),
        );



    //==============================
    // STARS
    //==============================

    starsController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 8,
      ),
    )..repeat();



    starsAnimation =
        Tween<double>(
          begin: 0,
          end: 1,
        ).animate(
          CurvedAnimation(
            parent: starsController,
            curve: Curves.linear,
          ),
        );



    //==============================
    // SEA MOVEMENT
    //==============================

    seaController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 10,
      ),
    )..repeat(
      reverse: true,
    );


    seaAnimation =
        Tween<double>(
          begin: 0.05,
          end: 0.15,
        ).animate(
          CurvedAnimation(
            parent: seaController,
            curve: Curves.easeInOut,
          ),
        );



    //==============================
    // CREATE ISLAND FLOAT
    //==============================

    for (final island in islands) {


      final controller =
          AnimationController(
            vsync: this,
            duration: Duration(
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
              parent: controller,
              curve: Curves.easeInOut,
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



    refreshTimer?.cancel();



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



          //========================================
          // BACKGROUND MAP
          //========================================

          AnimatedBuilder(

            animation: mapController,

            builder: (
                context,
                child,
                ) {


              return Positioned.fill(

                child: Transform.translate(

                  offset:
                  mapMoveAnimation.value *
                      80,


                  child: Transform.scale(

                    scale:
                    mapScaleAnimation.value,


                    child: Image.asset(

                      mapImage,


                      fit: BoxFit.cover,


                    ),

                  ),

                ),

              );


            },

          ),





          //========================================
          // SPACE STARS LAYER
          //========================================

          AnimatedBuilder(

            animation: starsController,


            builder: (
                context,
                child,
                ) {


              return Positioned.fill(

                child: IgnorePointer(

                  child: CustomPaint(

                    painter:
                    StarFieldPainter(

                      starsAnimation.value,

                    ),

                  ),

                ),

              );


            },

          ),





          //========================================
          // SEA MOVING EFFECT
          //========================================

          AnimatedBuilder(

            animation: seaController,


            builder: (
                context,
                child,
                ) {


              return Positioned.fill(

                child: IgnorePointer(

                  child: Container(

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


                        stops: const [

                          0.0,

                          0.5,

                          1.0,

                        ],

                      ),

                    ),

                  ),

                ),

              );


            },

          ),





          //========================================
          // ISLANDS AREA
          //========================================

          SafeArea(

            child: Stack(

              children: [



                // الجزر ستضاف هنا في الجزء الثالث



              ],

            ),

          ),




          //========================================
          // TOOLBAR
          //========================================

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

                //========================================
                // ISLANDS
                //========================================

                ...islands.map(

                  (island) {


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
                          island.position.dx,


                          top:
                          island.position.dy +
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


                            onTapUp:
                                (_) {


                              Future.delayed(

                                const Duration(
                                  milliseconds: 150,
                                ),

                                    () {


                                  if (!mounted) {
                                    return;
                                  }


                                  openIsland(
                                      island
                                  );


                                },

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
                                ..scale(
                                  1.08,
                                )

                                  :

                              Matrix4.identity(),



                              child:
                              Stack(

                                alignment:
                                Alignment.center,


                                children: [



                                  // الجزيرة

                                  Image.asset(

                                    island.image,


                                    width:
                                    island.size,


                                    height:
                                    island.size,


                                  ),




                                  // لمعان الضغط

                                  if (
                                  selectedIsland ==
                                      island.id
                                  )

                                    Container(

                                      width:
                                      island.size,


                                      height:
                                      island.size,


                                      decoration:
                                      BoxDecoration(

                                        shape:
                                        BoxShape.circle,


                                        boxShadow: [

                                          BoxShadow(

                                            color:
                                            Colors.yellow
                                                .withOpacity(
                                                0.8
                                            ),


                                            blurRadius:
                                            35,


                                            spreadRadius:
                                            8,


                                          ),

                                        ],

                                      ),

                                    ),




                                  // القفل

                                  if (
                                  !islandUnlocked(
                                      island
                                  )
                                  )

                                    Container(

                                      width:
                                      island.size * .35,


                                      height:
                                      island.size * .35,


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
          (baseY +
              animation *
                  40 *
                  (i % 3 + 1))
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