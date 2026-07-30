import 'dart:math' as math;

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



  //=========================================
  // خلفية العالم
  //=========================================

  static const String mapImage =
      "assets/images/world/world_map.png";



  // أبعاد صورة العالم الأصلية
  static const double worldWidth = 896;

  static const double worldHeight = 1200;




  late final List<PuzzleModel> islands;




  //=========================================
  // Animation
  //=========================================

  late AnimationController animationController;


  late Animation<double> waterAnimation;


  late Animation<double> islandFloatAnimation;


  late Animation<double> cloudAnimation;





  @override
  void initState() {

    super.initState();



    islands =
        PuzzleData.puzzles;



    animationController =
        AnimationController(

          vsync: this,

          duration:
          const Duration(
            seconds: 8,
          ),

        )
          ..repeat(
            reverse: true,
          );




    // حركة البحر والخلفية

    waterAnimation =
        Tween<double>(
          begin: -10,
          end: 10,
        )
            .animate(

          CurvedAnimation(

            parent: animationController,

            curve:
            Curves.easeInOut,

          ),

        );





    // حركة طفو الجزر

    islandFloatAnimation =
        Tween<double>(
          begin: -6,
          end: 6,
        )
            .animate(

          CurvedAnimation(

            parent: animationController,

            curve:
            Curves.easeInOut,

          ),

        );





    // حركة السحب

    cloudAnimation =
        Tween<double>(
          begin: -25,
          end: 25,
        )
            .animate(

          CurvedAnimation(

            parent: animationController,

            curve:
            Curves.easeInOut,

          ),

        );


  }






  @override
  void dispose() {


    animationController.dispose();


    super.dispose();


  }






  //=========================================
  // جلب الجزيرة
  //=========================================


  PuzzleModel getIsland(
      String id,
      ) {


    return islands.firstWhere(

          (item) =>
      item.id == id,

    );


  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xff08182b),


      body: LayoutBuilder(

        builder: (context, constraints) {


          final scaleX =
              constraints.maxWidth / worldWidth;


          final scaleY =
              constraints.maxHeight / worldHeight;


          final scale =
          scaleX > scaleY
              ? scaleX
              : scaleY;



          final offsetX =
              (constraints.maxWidth -
                  (worldWidth * scale)) / 2;



          final offsetY =
              (constraints.maxHeight -
                  (worldHeight * scale)) / 2;




          return Stack(

            children: [



              Positioned(

                left: offsetX,

                top: offsetY,


                child: Transform.scale(

                  scale: scale,

                  alignment:
                  Alignment.topLeft,


                  child: SizedBox(

                    width: worldWidth,

                    height: worldHeight,



                    child: AnimatedBuilder(

                      animation:
                      animationController,


                      builder:
                          (context, child) {


                        return Stack(

                          clipBehavior:
                          Clip.none,


                          children: [




                            //================================
                            // خلفية العالم
                            //================================

                            Positioned.fill(

                              child: Transform.translate(

                                offset:
                                Offset(
                                  waterAnimation.value,
                                  0,
                                ),


                                child: Image.asset(

                                  mapImage,

                                  fit:
                                  BoxFit.fill,

                                ),

                              ),

                            ),





                            //================================
                            // تأثير ضباب / إضاءة على البحر
                            //================================

                            Positioned.fill(

                              child: Container(

                                decoration:
                                BoxDecoration(

                                  gradient:
                                  LinearGradient(

                                    begin:
                                    Alignment.topCenter,


                                    end:
                                    Alignment.bottomCenter,


                                    colors: [

                                      Colors.white
                                          .withOpacity(0.05),


                                      Colors.blue
                                          .withOpacity(0.08),


                                    ],

                                  ),

                                ),

                              ),

                            ),






                            //================================
                            // حركة السحب الخفيفة
                            //================================

                            Positioned(

                              top: 50,

                              left:
                              cloudAnimation.value,


                              child: Opacity(

                                opacity: 0.18,


                                child:
                                Image.asset(

                                  "assets/images/background/clouds.png",

                                  width: 300,

                                ),

                              ),

                            ),






                            //================================
                            // الجزر
                            // سيتم وضعها في الجزء الثالث
                            //================================



                            islandImage(

                              id: "space",

                              left: 192,

                              top: 30,

                              width: 512,

                              height: 686,

                            ),



                            islandImage(

                              id: "landmarks",

                              left: 20,

                              top: 330,

                              width: 512,

                              height: 686,

                            ),



                            islandImage(

                              id: "cars",

                              left: 420,

                              top: 330,

                              width: 512,

                              height: 686,

                            ),



                            islandImage(

                              id: "nature",

                              left: 190,

                              top: 650,

                              width: 512,

                              height: 686,

                            ),



                            islandImage(

                              id: "animals",

                              left: 190,

                              top: 900,

                              width: 512,

                              height: 686,

                            ),



                          ],

                        );


                      },


                    ),


                  ),


                ),


              ),


            ],

          );


        },

      ),

    );


  }

  //=========================================
  // رسم الجزيرة فوق الخريطة
  //=========================================

  Widget islandImage({

    required String id,

    required double left,

    required double top,

    required double width,

    required double height,

  }) {



    final island =
        getIsland(id);



    return AnimatedBuilder(

      animation: islandFloatAnimation,


      builder: (context, child) {


        return Positioned(

          left: left,

          top:
          top + islandFloatAnimation.value,


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



                // لمعان حول الجزيرة

                Container(

                  width:
                  width * 0.75,


                  height:
                  height * 0.55,


                  decoration:
                  BoxDecoration(

                    shape:
                    BoxShape.circle,


                    boxShadow: [

                      BoxShadow(

                        blurRadius: 40,

                        spreadRadius: 10,

                        color: Colors.white
                            .withOpacity(0.12),

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







  //=========================================
  // فتح شاشة الجزيرة
  //=========================================


  void openIsland(
      PuzzleModel island,
      ) {



    Navigator.push(


      context,


      MaterialPageRoute(


        builder: (_) => IslandScreen(

          island: island,

        ),


      ),


    );


  }



}