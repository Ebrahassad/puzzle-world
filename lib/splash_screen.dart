import 'dart:async';

import 'package:flutter/material.dart';

import 'features/puzzle/screens/world_map_screen.dart';



class SplashScreen extends StatefulWidget {


  const SplashScreen({

    super.key,

  });



  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();


}





class _SplashScreenState
    extends State<SplashScreen>
    with TickerProviderStateMixin {



  late AnimationController scaleController;

  late AnimationController fadeController;

  late AnimationController rotateController;




  late Animation<double> scaleAnimation;

  late Animation<double> fadeAnimation;

  late Animation<double> rotateAnimation;







  @override
  void initState(){

    super.initState();




    scaleController =
        AnimationController(

          vsync:this,

          duration:
          const Duration(
              milliseconds:1200
          ),

        );




    fadeController =
        AnimationController(

          vsync:this,

          duration:
          const Duration(
              milliseconds:1000
          ),

        );




    rotateController =
        AnimationController(

          vsync:this,

          duration:
          const Duration(
              seconds:6
          ),

        );







    scaleAnimation =
        Tween<double>(

          begin:0.95,

          end:1.05,

        ).animate(

          CurvedAnimation(

            parent:
            scaleController,

            curve:
            Curves.easeInOut,

          ),

        );





    fadeAnimation =
        Tween<double>(

          begin:0,

          end:1,

        ).animate(

          CurvedAnimation(

            parent:
            fadeController,

            curve:
            Curves.easeIn,

          ),

        );






    rotateAnimation =
        Tween<double>(

          begin:-0.03,

          end:0.03,

        ).animate(

          CurvedAnimation(

            parent:
            rotateController,

            curve:
            Curves.easeInOut,

          ),

        );






    fadeController.forward();

    scaleController.repeat(reverse:true);

    rotateController.repeat(reverse:true);





    Timer(

      const Duration(seconds:4),

          (){


        if(!mounted)return;



        Navigator.pushReplacement(

          context,

          MaterialPageRoute(

            builder:(_)=>
            const WorldMapScreen(),

          ),

        );


      },

    );



  }







  @override
  void dispose(){

    scaleController.dispose();

    fadeController.dispose();

    rotateController.dispose();

    super.dispose();

  }








  Widget buildLogo(){


    return FadeTransition(

      opacity:
      fadeAnimation,


      child:
      AnimatedBuilder(


        animation:
        rotateAnimation,


        builder:(context,child){


          return Transform.rotate(

            angle:
            rotateAnimation.value,


            child:
            ScaleTransition(

              scale:
              scaleAnimation,


              child:
              child,

            ),

          );


        },



        child:
        Image.asset(



          "assets/images/ui/puzzle_logo.png",



          width:230,

          height:230,



          fit:
          BoxFit.contain,



        ),


      ),


    );


  }








  @override
  Widget build(BuildContext context){



    return Scaffold(



      body:
      Stack(



        fit:
        StackFit.expand,



        children:[




          Image.asset(

            "assets/images/background/home_background.png",

            fit:
            BoxFit.cover,

          ),




          Container(

            color:
            Colors.black.withOpacity(0.15),

          ),






          Center(

            child:
            buildLogo(),

          ),






          Positioned(

            bottom:120,

            left:0,

            right:0,


            child:
            Center(

              child:
              Text(

                "Puzzle World",


                style:
                Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(


                  color:
                  Colors.white,


                  shadows:[


                    const Shadow(

                      color:
                      Colors.black54,

                      blurRadius:
                      8,

                      offset:
                      Offset(0,3),

                    ),


                  ],

                ),

              ),

            ),

          ),






          const Positioned(

            bottom:80,

            left:0,

            right:0,


            child:
            Center(

              child:
              Text(

                "Let's Play & Learn",


                style:
                TextStyle(

                  color:
                  Colors.white70,

                  fontSize:
                  18,

                  fontWeight:
                  FontWeight.w600,

                ),

              ),

            ),

          ),



        ],



      ),



    );


  }


}