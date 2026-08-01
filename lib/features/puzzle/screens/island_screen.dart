import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/island_background_data.dart';
import '../data/puzzle_level_data.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

import 'puzzle_game_screen.dart';


class IslandScreen extends StatefulWidget {

  final PuzzleModel island;


  const IslandScreen({
    super.key,
    required this.island,
  });


  @override
  State<IslandScreen> createState() =>
      _IslandScreenState();

}



class _IslandScreenState extends State<IslandScreen>
    with TickerProviderStateMixin {


  static const double worldWidth = 1080;
  static const double worldHeight = 1920;


  static const double islandAreaHeightFraction = 0.55;



  final List<Offset> levelPositions = const [

    Offset(0.15, 0.00),
    Offset(0.65, 0.08),
    Offset(0.25, 0.16),
    Offset(0.70, 0.24),
    Offset(0.30, 0.32),
    Offset(0.65, 0.40),
    Offset(0.25, 0.48),
    Offset(0.70, 0.56),
    Offset(0.35, 0.64),
    Offset(0.60, 0.72),

  ];



  final List<int> levelOrder = const [

    0,
    9,
    1,
    8,
    2,
    7,
    3,
    6,
    4,
    5,

  ];



  late final AnimationController worldController;

  late final Animation<double> worldScale;

  late final Animation<double> worldTranslate;



  late List<PuzzleLevelModel> levels;



  @override
  void initState() {

    super.initState();


    levels = PuzzleLevelData.getLevels(
      widget.island.id,
    );



    worldController = AnimationController(

      vsync: this,

      duration: const Duration(seconds:20),

    )..repeat(reverse:true);



    worldScale = Tween<double>(

      begin: 1.0,

      end: 1.02,

    ).animate(

      CurvedAnimation(

        parent: worldController,

        curve: Curves.easeInOut,

      ),

    );



    worldTranslate = Tween<double>(

      begin: -8,

      end: 8,

    ).animate(

      CurvedAnimation(

        parent: worldController,

        curve: Curves.easeInOut,

      ),

    );


  }



  @override
  void dispose(){

    worldController.dispose();

    super.dispose();

  }



  void openLevel(
      PuzzleLevelModel level,
      ){

    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) => PuzzleGameScreen(

          level: level,

        ),

      ),

    );

  }



  Widget levelButton(
      PuzzleLevelModel level,
      ){

    return GestureDetector(

      onTap: (){

        openLevel(level);

      },


      child: Stack(

        alignment: Alignment.center,

        children:[


          Image.asset(

            "assets/images/ui/level_piece.png",

            width:130,

            height:130,

            fit:BoxFit.contain,

          ),



          Text(

            "${level.levelNumber}",

            style: const TextStyle(

              color:Colors.white,

              fontSize:42,

              fontWeight:FontWeight.bold,

              shadows:[

                Shadow(

                  color:Colors.black,

                  blurRadius:5,

                  offset:Offset(0,3),

                ),

              ],

            ),

          ),


        ],

      ),

    );

  }

@override
Widget build(BuildContext context) {

  return Scaffold(

    body: Stack(

      children: [


        Positioned.fill(

          child: Container(

            decoration: const BoxDecoration(

              gradient: LinearGradient(

                begin: Alignment.topCenter,

                end: Alignment.bottomCenter,

                colors: [

                  Color(0xff06152f),

                  Color(0xff083b5c),

                  Color(0xff006994),

                ],

              ),

            ),

          ),

        ),



        Positioned.fill(

          child: LayoutBuilder(

            builder: (context, constraints) {


              final double screenWidth =
                  constraints.maxWidth;


              final double screenHeight =
                  constraints.maxHeight;



              // عرض العالم كاملاً بدون قص
              final double scale = math.min(

                screenWidth / worldWidth,

                screenHeight / worldHeight,

              );



              final double scaledWidth =
                  worldWidth * scale;


              final double scaledHeight =
                  worldHeight * scale;



              final double dx =
                  (screenWidth - scaledWidth) / 2;


              final double dy =
                  (screenHeight - scaledHeight) / 2;



              return ClipRect(

                child: Stack(

                  children: [


                    Positioned(

                      left: dx,

                      top: dy,


                      child: Transform.scale(

                        scale: scale,

                        alignment: Alignment.topLeft,


                        child: SizedBox(

                          width: worldWidth,

                          height: worldHeight,


                          child: AnimatedBuilder(

                            animation: worldController,


                            builder: (context, child){


                              return Transform.scale(

                                scale:
                                worldScale.value,


                                alignment:
                                Alignment.center,


                                child:
                                Transform.translate(

                                  offset: Offset(
                                    worldTranslate.value,
                                    0,
                                  ),

                                  child: child,

                                ),

                              );


                            },



                            child: Stack(

                              clipBehavior:
                              Clip.none,


                              children: [



                                Positioned.fill(

                                  child: Image.asset(

                                    IslandBackgroundData
                                        .getBackground(
                                      widget.island.id,
                                    ),


                                    fit:
                                    BoxFit.contain,


                                    alignment:
                                    Alignment.center,

                                  ),

                                ),





                                Positioned(

                                  left:0,

                                  top:0,

                                  width:worldWidth,

                                  height:
                                  worldHeight *
                                  islandAreaHeightFraction,


                                  child: Image.asset(

                                    widget.island.image,


                                    fit:
                                    BoxFit.contain,


                                  ),

                                ),





                                ...List.generate(

                                  levels.length,


                                  (index){


                                    final pos =
                                    levelPositions[index];



                                    return Positioned(

                                      left:
                                      worldWidth *
                                      pos.dx,


                                      top:
                                      worldHeight *
                                      pos.dy,


                                      child:
                                      levelButton(

                                        levels[
                                        levelOrder[index]
                                        ],

                                      ),

                                    );


                                  },


                                ),


                              ],

                            ),

                          ),

                        ),

                      ),

                    ),


                  ],

                ),

              );


            },

          ),

        ),




        Positioned.fill(

          child: Container(

            color:
            Colors.black.withOpacity(0.05),

          ),

        ),





        SafeArea(

          child: Padding(

            padding:
            const EdgeInsets.all(12),


            child: Row(

              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,


              children:[



                CircleAvatar(

                  backgroundColor:
                  Colors.black54,


                  child: IconButton(

                    icon:
                    const Icon(

                      Icons.arrow_back,

                      color:Colors.white,

                    ),


                    onPressed:(){

                      Navigator.pop(context);

                    },

                  ),

                ),





                CircleAvatar(

                  backgroundColor:
                  Colors.black54,


                  child: IconButton(

                    icon:
                    const Icon(

                      Icons.settings,

                      color:Colors.white,

                    ),


                    onPressed:(){},

                  ),

                ),



              ],

            ),

          ),

        ),



      ],

    ),

  );

}

}