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



  late AnimationController controller;



  late Animation<double> scaleAnimation;


  late Animation<double> fadeAnimation;


  late Animation<double> floatAnimation;


  late Animation<double> shakeAnimation;







  @override
  void initState() {

    super.initState();




    controller = AnimationController(

      vsync: this,


      duration:
      const Duration(

        milliseconds: 3000,

      ),


    );






    // تكبير الشعار

    scaleAnimation =
        Tween<double>(

          begin: 0.4,


          end: 1,


        ).animate(


          CurvedAnimation(

            parent:
            controller,


            curve:
            Curves.elasticOut,


          ),


        );







    // ظهور تدريجي

    fadeAnimation =
        Tween<double>(

          begin: 0,


          end: 1,


        ).animate(


          CurvedAnimation(

            parent:
            controller,


            curve:
            const Interval(

              0,


              0.5,


              curve:
              Curves.easeIn,


            ),


          ),


        );








    // حركة الطفو

    floatAnimation =
        Tween<double>(

          begin: -12,


          end: 12,


        ).animate(


          CurvedAnimation(

            parent:
            controller,


            curve:
            Curves.easeInOut,


          ),


        );








    // اهتزاز بسيط

    shakeAnimation =
        TweenSequence<double>(


          [

            TweenSequenceItem(

              tween:
              Tween(

                begin: 0,


                end: 0.03,


              ),


              weight: 1,


            ),



            TweenSequenceItem(

              tween:
              Tween(

                begin: 0.03,


                end: -0.03,


              ),


              weight: 1,


            ),



            TweenSequenceItem(

              tween:
              Tween(

                begin: -0.03,


                end: 0,


              ),


              weight: 1,


            ),


          ],


        ).animate(


          CurvedAnimation(

            parent:
            controller,


            curve:
            const Interval(

              0.75,


              1,


            ),


          ),


        );







    controller.forward();







    Future.delayed(


      const Duration(

        milliseconds: 3500,

      ),


      openWorldMap,


    );


  }








  void openWorldMap(){


    if(!mounted){

      return;

    }



    Navigator.pushReplacement(


      context,


      MaterialPageRoute(


        builder: (_) =>

        const WorldMapScreen(),


      ),


    );


  }










  @override
  Widget build(BuildContext context){



    return Scaffold(



      body: Stack(



        fit:
        StackFit.expand,



        children: [






          //====================================
          // SPLASH BACKGROUND
          //====================================


          Image.asset(


            "assets/images/background/splash_background.png",


            fit:
            BoxFit.cover,


          ),






          Container(


            color:
            Colors.black.withOpacity(
                0.12
            ),


          ),







          //====================================
          // PUZZLE WORLD LOGO
          //====================================


          AnimatedBuilder(


            animation:
            controller,



            builder:
                (
                context,
                child,
                ){



              return Positioned(



                top:
                MediaQuery.of(context)
                    .size
                    .height *
                    0.12
                    +
                    floatAnimation.value,



                left:
                0,


                right:
                0,



                child:
                FadeTransition(



                  opacity:
                  fadeAnimation,



                  child:
                  Transform.scale(



                    scale:
                    scaleAnimation.value,



                    child:
                    Transform.rotate(



                      angle:
                      shakeAnimation.value,



                      child:
                      child,



                    ),


                  ),


                ),


              );



            },



            child:
Image.asset(

  "assets/images/ui/puzzle_world_logo.png",

  width: 350,

),


          ),






        ],


      ),


    );


  }










  @override
  void dispose(){


    controller.dispose();


    super.dispose();


  }


}