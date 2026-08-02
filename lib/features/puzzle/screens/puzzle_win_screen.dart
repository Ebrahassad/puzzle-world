import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/game_result_model.dart';
import '../models/puzzle_level_model.dart';


class PuzzleWinScreen extends StatefulWidget {

  final GameResultModel result;

  final PuzzleLevelModel level;


  final VoidCallback? onBackToIsland;

  final VoidCallback? onBackToWorld;

  final VoidCallback? onExit;


  const PuzzleWinScreen({

    super.key,

    required this.result,

    required this.level,

    this.onBackToIsland,

    this.onBackToWorld,

    this.onExit,

  });


  @override
  State<PuzzleWinScreen> createState() =>
      _PuzzleWinScreenState();

}





class _PuzzleWinScreenState
    extends State<PuzzleWinScreen>
    with SingleTickerProviderStateMixin {


  late AnimationController animationController;


  late Animation<double> fadeAnimation;


  late Animation<double> scaleAnimation;



  @override
  void initState() {

    super.initState();


    animationController =
        AnimationController(

      vsync: this,

      duration:
          const Duration(seconds: 2),

    );



    fadeAnimation =
        Tween<double>(

      begin: 0,

      end: 1,

    ).animate(

      CurvedAnimation(

        parent: animationController,

        curve: Curves.easeOut,

      ),

    );




    scaleAnimation =
        Tween<double>(

      begin: 0.96,

      end: 1,

    ).animate(

      CurvedAnimation(

        parent: animationController,

        curve: Curves.easeOutBack,

      ),

    );



    animationController.forward();

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.transparent,

      body: FadeTransition(

        opacity: fadeAnimation,

        child: ScaleTransition(

          scale: scaleAnimation,

          child: Stack(

            children: [


              // الخلفية الرئيسية
              Positioned.fill(

                child: Image.asset(

                  "assets/images/background/win_background.png",

                  fit: BoxFit.cover,

                ),

              ),



              // طبقة شفافية خفيفة فوق الخلفية
              Positioned.fill(

                child: Container(

                  color: Colors.black.withOpacity(0.18),

                ),

              ),



              // تأثير إضاءة خفيف
              Positioned.fill(

                child: IgnorePointer(

                  child: Container(

                    decoration: BoxDecoration(

                      gradient: RadialGradient(

                        center: Alignment.center,

                        radius: 0.8,

                        colors: [

                          Colors.white.withOpacity(0.08),

                          Colors.transparent,

                        ],

                      ),

                    ),

                  ),

                ),

              ),




              SafeArea(

                child: Column(

                  children: [


                    const Spacer(),



                    // مساحة فارغة لأن التصميم موجود داخل الصورة

                    const SizedBox(height: 120),



                    // الأزرار في الأسفل

                    buildNavigationButtons(),



                    const SizedBox(height: 30),


                  ],

                ),

              ),


            ],

          ),

        ),

      ),

    );

  }

  Widget buildNavigationButtons() {

    return Padding(

      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),

      child: Row(

        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,

        children: [


          // العودة للجزيرة (يسار)

          glassButton(

            icon: Icons.extension,

            text: "الجزيرة",

            onTap: () {

              if (widget.onBackToIsland != null) {

                widget.onBackToIsland!();

              }

            },

          ),




          // العودة للعوالم (وسط)

          glassButton(

            icon: Icons.public,

            text: "العوالم",

            onTap: () {

              if (widget.onBackToWorld != null) {

                widget.onBackToWorld!();

              }

            },

          ),




          // خروج (يمين)

          glassButton(

            icon: Icons.exit_to_app,

            text: "خروج",

            onTap: () {

              if (widget.onExit != null) {

                widget.onExit!();

              } else {

                Navigator.pop(context);

              }

            },

          ),


        ],

      ),

    );

  }





  Widget glassButton({

    required IconData icon,

    required String text,

    required VoidCallback onTap,

  }) {


    return GestureDetector(

      onTap: onTap,

      child: ClipRRect(

        borderRadius:
            BorderRadius.circular(20),

        child: BackdropFilter(

          filter: ui.ImageFilter.blur(

  sigmaX: 8,

  sigmaY: 8,

),
          child: Container(

            width: 90,

            padding: const EdgeInsets.symmetric(

              vertical: 10,

            ),

            decoration: BoxDecoration(

              color: Colors.white.withOpacity(0.18),

              borderRadius:
                  BorderRadius.circular(20),

              border: Border.all(

                color: Colors.white.withOpacity(0.35),

              ),

            ),

            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [


                Icon(

                  icon,

                  color: Colors.white,

                  size: 24,

                ),



                const SizedBox(height: 5),



                Text(

                  text,

                  style: const TextStyle(

                    color: Colors.white,

                    fontSize: 13,

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),


              ],

            ),

          ),

        ),

      ),

    );

  }





  @override
  void dispose() {

    animationController.dispose();

    super.dispose();

  }

}