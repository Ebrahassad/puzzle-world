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



  late List<PuzzleLevelModel> levels;



  late AnimationController worldController;

  late Animation<double> worldScale;



  // مسار المراحل الجديد
  // مرتب من الأسفل إلى الأعلى داخل الجزيرة

  final List<Offset> levelPositions = const [

    Offset(0.50, 0.12),

    Offset(0.35, 0.23),

    Offset(0.60, 0.34),

    Offset(0.42, 0.46),

    Offset(0.65, 0.57),

    Offset(0.45, 0.68),

    Offset(0.30, 0.78),

    Offset(0.58, 0.86),

    Offset(0.42, 0.93),

    Offset(0.70, 0.97),

  ];



  @override
  void initState() {

    super.initState();


    levels =
        PuzzleLevelData.getLevels(
          widget.island.id,
        );



    worldController =
        AnimationController(

          vsync: this,

          duration:
          const Duration(seconds: 18),

        )..repeat(
          reverse: true,
        );



    worldScale =
        Tween<double>(

          begin: 1.0,

          end: 1.015,

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
  void dispose() {

    worldController.dispose();

    super.dispose();

  }



  void openLevel(
    PuzzleLevelModel level,
  ) {

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
  ) {

    return GestureDetector(

      behavior:
      HitTestBehavior.opaque,


      onTap: () {

        openLevel(level);

      },


      child: Container(

        width: 95,

        height: 95,


        decoration: BoxDecoration(

          shape:
          BoxShape.circle,


          boxShadow: [

            BoxShadow(

              color:
              Colors.black.withOpacity(0.35),

              blurRadius:
              10,

              offset:
              const Offset(0, 5),

            ),

          ],

        ),


        child: Stack(

          alignment:
          Alignment.center,


          children: [


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
                32,

                fontWeight:
                FontWeight.bold,


                shadows: [

                  Shadow(

                    color:
                    Colors.black,

                    blurRadius:
                    6,

                    offset:
                    Offset(0, 3),

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
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        color:
        const Color(0xff020b24),


        child: SafeArea(

          child: Stack(

            children: [


              // العالم الرئيسي
              Positioned.fill(

                child: LayoutBuilder(

                  builder:
                  (context, constraints) {


                    return Center(

                      child: ClipRect(

                        child: OverflowBox(

                          alignment:
                          Alignment.center,


                          maxWidth:
                          double.infinity,


                          maxHeight:
                          double.infinity,


                          child: AspectRatio(

                            aspectRatio:
                            worldWidth /
                            worldHeight,


                            child: AnimatedBuilder(

                              animation:
                              worldController,


                              builder:
                              (context, child) {


                                return Transform.scale(

                                  scale:
                                  worldScale.value,


                                  alignment:
                                  Alignment.center,


                                  child:
                                  child,

                                );

                              },


                              child: SizedBox(

                                width:
                                worldWidth,


                                height:
                                worldHeight,


                                child: Stack(

                                  clipBehavior:
                                  Clip.none,


                                  children: [



                                    // خلفية الجزيرة

                                    Positioned.fill(

                                      child: Image.asset(

                                        IslandBackgroundData
                                            .getBackground(
                                              widget.island.id,
                                            ),


                                        fit:
                                        BoxFit.cover,

                                      ),

                                    ),




                                    // الجزيرة

                                    Positioned.fill(

                                      child: Image.asset(

                                        widget.island.image,


                                        fit:
                                        BoxFit.contain,


                                        alignment:
                                        Alignment.center,

                                      ),

                                    ),



                                    // المراحل

                                    ...List.generate(

                                      levels.length,


                                      (index) {


                                        final pos =
                                        levelPositions[index];


                                        return Positioned(

                                          left:

                                          (worldWidth *
                                          pos.dx) -
                                          47,


                                          top:

                                          worldHeight *
                                          pos.dy,


                                          child:

                                          levelButton(

                                            levels[index],

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

                      ),

                    );

                  },

                ),

              ),

              // أزرار التحكم

              Positioned(

                top: 20,

                left: 20,

                child: CircleAvatar(

                  radius: 28,

                  backgroundColor:
                  Colors.black54,


                  child: IconButton(

                    icon:

                    const Icon(

                      Icons.arrow_back,

                      color:
                      Colors.white,

                      size:
                      32,

                    ),


                    onPressed: () {

                      Navigator.pop(context);

                    },

                  ),

                ),

              ),




              Positioned(

                top: 20,

                right: 20,

                child: CircleAvatar(

                  radius: 28,

                  backgroundColor:
                  Colors.black54,


                  child: IconButton(

                    icon:

                    const Icon(

                      Icons.settings,

                      color:
                      Colors.white,

                      size:
                      32,

                    ),


                    onPressed: () {},

                  ),

                ),

              ),



            ],

          ),

        ),

      ),

    );

  }

}