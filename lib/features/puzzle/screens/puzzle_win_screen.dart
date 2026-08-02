import 'dart:ui' as ui;

import 'package:flutter/material.dart';


class PuzzleWinScreen extends StatefulWidget {


  final VoidCallback? onBackToIsland;

  final VoidCallback? onBackToWorld;

  final VoidCallback? onExit;



  const PuzzleWinScreen({

    super.key,

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


  late Animation<double> glowAnimation;



  @override
  void initState() {

    super.initState();



    animationController =
        AnimationController(

      vsync: this,

      duration:
          const Duration(seconds: 3),

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



    glowAnimation =
        Tween<double>(

      begin: 0.05,

      end: 0.15,

    ).animate(

      CurvedAnimation(

        parent: animationController,

        curve: Curves.easeInOut,

      ),

    );



    animationController.repeat(
      reverse: true,
    );

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



              // الخلفية الجاهزة

              Positioned.fill(

                child: Image.asset(

                  "assets/images/background/win_background.png",

                  fit: BoxFit.cover,

                ),

              ),





              // طبقة شفافية

              Positioned.fill(

                child: Container(

                  color: Colors.black.withOpacity(
                    0.18,
                  ),

                ),

              ),





              // إضاءة متحركة خفيفة

              Positioned.fill(

                child: AnimatedBuilder(

                  animation: glowAnimation,

                  builder: (context, child) {

                    return IgnorePointer(

                      child: Container(

                        decoration:
                            BoxDecoration(

                          gradient:
                              RadialGradient(

                            center:
                                Alignment.center,

                            radius:
                                0.8,

                            colors: [

                              Colors.white.withOpacity(
                                glowAnimation.value,
                              ),

                              Colors.transparent,

                            ],

                          ),

                        ),

                      ),

                    );

                  },

                ),

              ),





              SafeArea(

                child: Column(

                  children: [



                    const Spacer(),



                    buildNavigationButtons(),



                    const SizedBox(
                      height: 30,
                    ),


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

      padding:
          const EdgeInsets.symmetric(
            horizontal: 20,
          ),


      child: Row(

        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,


        children: [



          // العودة للجزيرة

          glassButton(

            icon: Icons.extension,

            text: "الجزيرة",

            onTap: () {

              widget.onBackToIsland?.call();

            },

          ),





          // العودة للعوالم

          glassButton(

            icon: Icons.public,

            text: "العوالم",

            onTap: () {

              widget.onBackToWorld?.call();

            },

          ),





          // خروج

          glassButton(

            icon: Icons.exit_to_app,

            text: "خروج",

            onTap: () {

              if(widget.onExit != null){

                widget.onExit!();

              }else{

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


            padding:
                const EdgeInsets.symmetric(

              vertical: 10,

            ),



            decoration:
                BoxDecoration(

              color:
                  Colors.white.withOpacity(
                    0.18,
                  ),


              borderRadius:
                  BorderRadius.circular(20),


              border:
                  Border.all(

                color:
                    Colors.white.withOpacity(
                      0.35,
                    ),

              ),

            ),




            child: Column(

              mainAxisSize:
                  MainAxisSize.min,


              children: [



                Icon(

                  icon,

                  color:
                      Colors.white,

                  size:
                      24,

                ),



                const SizedBox(
                  height: 5,
                ),




                Text(

                  text,

                  style:
                      const TextStyle(

                    color:
                        Colors.white,

                    fontSize:
                        13,

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