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



  // لوحة التصميم المرجعية
  static const double worldWidth = 1080;

  static const double worldHeight = 1920;



  static const double islandTop = 70;

  static const double islandHeight = 1650;





  final List<Offset> levelPositions = const [

    Offset(0.18,0.08),
    Offset(0.65,0.15),

    Offset(0.25,0.25),
    Offset(0.70,0.34),

    Offset(0.32,0.43),
    Offset(0.65,0.52),

    Offset(0.25,0.62),
    Offset(0.70,0.70),

    Offset(0.35,0.80),
    Offset(0.60,0.88),

  ];





  final List<int> levelOrder = const [

    0,9,1,8,2,
    7,3,6,4,5,

  ];





  late AnimationController worldController;

  late Animation<double> worldScale;


  late List<PuzzleLevelModel> levels;





  @override
  void initState(){

    super.initState();


    levels =
        PuzzleLevelData.getLevels(
          widget.island.id,
        );



    worldController =
        AnimationController(

          vsync:this,

          duration:
          const Duration(seconds:20),

        )..repeat(
          reverse:true,
        );



    worldScale =
        Tween<double>(

          begin:1.0,

          end:1.01,

        ).animate(

          CurvedAnimation(

            parent:
            worldController,

            curve:
            Curves.easeInOut,

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

      behavior:
      HitTestBehavior.opaque,


      onTap:(){

        openLevel(level);

      },


      child: SizedBox(

        width:
        worldWidth * 0.11,


        height:
        worldWidth * 0.11,



        child: Stack(

          alignment:
          Alignment.center,


          children:[



            Image.asset(

              "assets/images/ui/level_piece.png",


              fit:
              BoxFit.contain,


            ),





            Text(

              "${level.levelNumber}",



              style:
              const TextStyle(

                color:
                Colors.white,


                fontSize:
                38,


                fontWeight:
                FontWeight.bold,



                shadows:[

                  Shadow(

                    color:
                    Colors.black,


                    blurRadius:
                    6,


                    offset:
                    Offset(0,3),

                  ),

                ],

              ),

            ),



          ],

        ),

      ),

    );

  }







  @override
  Widget build(
    BuildContext context,
  ){

    return Scaffold(

      body:

      LayoutBuilder(

        builder:
        (context,constraints){


          return Container(

            color:
            const Color(0xff020b24),


            child:

            Center(

              child:

              FittedBox(

                fit:
                BoxFit.contain,


                child:

                SizedBox(

                  width:
                  worldWidth,


                  height:
                  worldHeight,

                  child:

                  AnimatedBuilder(

                    animation:
                    worldController,


                    builder:
                    (context,child){


                      return Transform.scale(

                        scale:
                        worldScale.value,


                        alignment:
                        Alignment.center,


                        child:
                        child,


                      );


                    },


                    child:

                    Stack(

                      clipBehavior:
                      Clip.none,


                      children:[



                        // خلفية الجزيرة
                        Positioned.fill(

                          child:

                          Image.asset(

                            IslandBackgroundData
                                .getBackground(
                                  widget.island.id,
                                ),


                            fit:
                            BoxFit.fill,


                          ),

                        ),

                        // صورة الجزيرة
                        Positioned(

                          left:
                          0,


                          top:
                          islandTop,


                          width:
                          worldWidth,


                          height:
                          islandHeight,


                          child:

                          Image.asset(

                            widget.island.image,


                            fit:
                            BoxFit.contain,


                            alignment:
                            Alignment.topCenter,


                          ),

                        ),






                        // المراحل
                        ...List.generate(

                          levels.length,


                          (index){


                            final int realIndex =

                            index <
                                levelOrder.length

                                ?

                            levelOrder[index]

                                :

                            index;



                            final level =
                            levels[realIndex];



                            final pos =
                            levelPositions[index];



                            return Positioned(

                              left:

                              (worldWidth *
                                  pos.dx)
                                  -
                                  (worldWidth *
                                      0.055),



                              top:

                              islandTop +

                                  (
                                    islandHeight *
                                        pos.dy
                                  ),



                              child:

                              levelButton(

                                level,

                              ),

                            );


                          },


                        ),

                        // طبقة دمج خفيفة
                        Positioned.fill(

                          child:

                          IgnorePointer(

                            child:

                            Container(

                              color:
                              Colors.black.withOpacity(0.03),

                            ),

                          ),

                        ),





                        // الأزرار العلوية
                        Positioned(

                          top:
                          20,

                          left:
                          12,

                          right:
                          12,


                          child:

                          SafeArea(

                            child:

                            Row(

                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,


                              children:[



                                CircleAvatar(

                                  backgroundColor:
                                  Colors.black54,


                                  child:

                                  IconButton(

                                    icon:

                                    const Icon(

                                      Icons.arrow_back,

                                      color:
                                      Colors.white,

                                    ),


                                    onPressed:(){

                                      Navigator.pop(
                                        context,
                                      );

                                    },

                                  ),

                                ),





                                CircleAvatar(

                                  backgroundColor:
                                  Colors.black54,


                                  child:

                                  IconButton(

                                    icon:

                                    const Icon(

                                      Icons.settings,

                                      color:
                                      Colors.white,

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

                  ),

                ),

              ),

            ),

          );

        },

      ),

    );

  }

}         