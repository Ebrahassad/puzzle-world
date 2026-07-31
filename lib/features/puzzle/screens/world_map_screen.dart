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



  //==================================================
  // صورة العالم
  //==================================================

  static const String mapImage =

      "assets/images/world/world_map.png";




  // الحجم الأساسي للخريطة

  static const double worldWidth = 896;


  static const double worldHeight = 1350;





  late final List<PuzzleModel> islands;





  //==================================================
  // حركة العالم
  //==================================================

  late AnimationController worldController;


  late Animation<double> worldScale;





  //==================================================
  // حركة الجزر
  //==================================================

  late AnimationController islandController;


  late Animation<double> islandFloat;





  //==================================================
  // حركة السحب
  //==================================================

  late AnimationController cloudController;


  late Animation<double> cloudMove;








  @override
  void initState() {


    super.initState();



    islands = PuzzleData.puzzles;




    // حركة بسيطة للخريطة

    worldController = AnimationController(

      vsync: this,

      duration:

          const Duration(

            seconds: 18,

          ),

    )

      ..repeat(

        reverse: true,

      );




    worldScale = Tween<double>(

      begin: 1.0,

      end: 1.015,

    ).animate(

      CurvedAnimation(

        parent: worldController,

        curve: Curves.easeInOut,

      ),

    );






    // طفو الجزر

    islandController = AnimationController(

      vsync: this,

      duration:

          const Duration(

            seconds: 5,

          ),

    )

      ..repeat(

        reverse: true,

      );




    islandFloat = Tween<double>(

      begin: -4,

      end: 4,

    ).animate(

      CurvedAnimation(

        parent: islandController,

        curve: Curves.easeInOut,

      ),

    );






    // حركة السحب

    cloudController = AnimationController(

      vsync: this,

      duration:

          const Duration(

            seconds: 45,

          ),

    )

      ..repeat();




    cloudMove = Tween<double>(

      begin: 1100,

      end: -500,

    ).animate(

      CurvedAnimation(

        parent: cloudController,

        curve: Curves.linear,

      ),

    );

  }


  @override
  void dispose() {


    worldController.dispose();


    islandController.dispose();


    cloudController.dispose();



    super.dispose();

  }






  //==================================================
  // جلب الجزيرة
  //==================================================

  PuzzleModel getIsland(

    String id,

  ) {


    return islands.firstWhere(

      (item) => item.id == id,

    );


  }







  //==================================================
  // بناء الخريطة
  //==================================================

  @override
  Widget build(

    BuildContext context,

  ) {


    return Scaffold(

      backgroundColor:

          const Color(0xff08182b),



      body: LayoutBuilder(

        builder: (

          context,

          constraints,

        ) {



          final scaleX =

              constraints.maxWidth /

                  worldWidth;



          final scaleY =

              constraints.maxHeight /

                  worldHeight;



          final scale =

              scaleX < scaleY

                  ? scaleX

                  : scaleY;





          final mapWidth =

              worldWidth * scale;



          final mapHeight =

              worldHeight * scale;





          return Center(

            child:

                SizedBox(

                  width: mapWidth,

                  height: mapHeight,



                  child:

                      Transform.scale(

                        scale: 1.0,



                        child:

                            AnimatedBuilder(

                              animation:

                                  worldController,



                              builder:

                                  (

                                    context,

                                    child,

                                  ) {


                                return Transform.scale(

                                  scale:

                                      worldScale.value,



                                  alignment:

                                      Alignment.center,



                                  child: child,

                                );


                              },



                              child:

                                  SizedBox(

                                    width:

                                        worldWidth,



                                    height:

                                        worldHeight,



                                    child:

                                        Transform.scale(

                                          scale: scale,

                                          alignment:

                                              Alignment.topLeft,



                                          child:

                                              Stack(

                                                clipBehavior:

                                                    Clip.none,


                                                children: [


                                                  //==================================
                                                  // خلفية العالم
                                                  //==================================


                                                  Positioned.fill(


                                                    child:

                                                        Image.asset(

                                                          mapImage,


                                                          fit:

                                                              BoxFit.fill,

                                                        ),

                                                  ),




                                                  //==================================
                                                  // تأثير البحر
                                                  //==================================


                                                  Positioned.fill(


                                                    child:

                                                        IgnorePointer(


                                                          child:

                                                              Container(

                                                                decoration:

                                                                    BoxDecoration(

                                                                      gradient:

                                                                          LinearGradient(

                                                                            begin:

                                                                                Alignment.topCenter,


                                                                            end:

                                                                                Alignment.bottomCenter,


                                                                            colors: [


                                                                              Colors.white.withOpacity(0.04),


                                                                              Colors.blue.withOpacity(0.12),


                                                                            ],

                                                                          ),

                                                                    ),

                                                              ),

                                                        ),

                                                  ),


                                                  //==================================
                                                  // السحابة الأولى
                                                  //==================================

                                                  AnimatedBuilder(

                                                    animation:

                                                        cloudController,


                                                    builder:

                                                        (

                                                          context,

                                                          child,

                                                        ) {


                                                      return Positioned(

                                                        left:

                                                            cloudMove.value,


                                                        top:

                                                            90,


                                                        child:

                                                            child!,

                                                      );


                                                    },


                                                    child:

                                                        Opacity(

                                                          opacity:

                                                              0.18,


                                                          child:

                                                              Image.asset(

                                                                "assets/images/background/clouds.png",


                                                                width:

                                                                    320,

                                                              ),

                                                        ),

                                                  ),





                                                  //==================================
                                                  // السحابة الثانية
                                                  //==================================


                                                  AnimatedBuilder(

                                                    animation:

                                                        cloudController,


                                                    builder:

                                                        (

                                                          context,

                                                          child,

                                                        ) {


                                                      return Positioned(

                                                        left:

                                                            cloudMove.value * 0.65,


                                                        top:

                                                            330,


                                                        child:

                                                            child!,

                                                      );


                                                    },


                                                    child:

                                                        Opacity(

                                                          opacity:

                                                              0.12,


                                                          child:

                                                              Image.asset(

                                                                "assets/images/background/clouds.png",


                                                                width:

                                                                    250,

                                                              ),

                                                        ),

                                                  ),







                                                  //==================================
                                                  // الجزر
                                                  //==================================


                                                  islandImage(

                                                    id: "space",

                                                    left: 300,

                                                    top: 40,

                                                    width: 260,

                                                    height: 330,

                                                  ),



                                                  islandImage(

                                                    id: "landmarks",

                                                    left: 50,

                                                    top: 330,

                                                    width: 260,

                                                    height: 330,

                                                  ),



                                                  islandImage(

                                                    id: "cars",

                                                    left: 585,

                                                    top: 330,

                                                    width: 260,

                                                    height: 330,

                                                  ),



                                                  islandImage(

                                                    id: "nature",

                                                    left: 300,

                                                    top: 650,

                                                    width: 260,

                                                    height: 330,

                                                  ),



                                                  islandImage(

                                                    id: "animals",

                                                    left: 300,

                                                    top: 980,

                                                    width: 260,

                                                    height: 330,

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

  //==================================================
  // رسم الجزيرة
  //==================================================

  Widget islandImage({

    required String id,

    required double left,

    required double top,

    required double width,

    required double height,

  }) {



    final island = getIsland(id);




    return AnimatedBuilder(

      animation: islandController,



      builder:

          (

            context,

            child,

          ) {



        return Positioned(

          left: left,

          top:

              top + islandFloat.value,

          width: width,

          height: height,



          child: GestureDetector(

            behavior:

                HitTestBehavior.translucent,



            onTap: () {


              openIsland(island);


            },



            child: Stack(

              alignment:

                  Alignment.center,



              children: [



                // توهج الجزيرة

                Container(

                  width:

                      width * 0.85,


                  height:

                      height * 0.55,



                  decoration:

                      BoxDecoration(


                    shape:

                        BoxShape.circle,



                    boxShadow: [


                      BoxShadow(

                        color:

                            Colors.white.withOpacity(

                              0.14,

                            ),


                        blurRadius:

                            35,


                        spreadRadius:

                            10,

                      ),


                    ],

                  ),

                ),





                // صورة الجزيرة

                Image.asset(

                  island.image,


                  fit:

                      BoxFit.contain,

                ),



              ],

            ),

          ),

        );


      },

    );

  }






  //==================================================
  // فتح شاشة الجزيرة
  //==================================================

  void openIsland(

    PuzzleModel island,

  ) {



    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>

            IslandScreen(

              island: island,

            ),

      ),

    );


  }


}