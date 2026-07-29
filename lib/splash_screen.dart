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


  late Animation<double> shakeAnimation;



  @override
  void initState() {

    super.initState();



    controller = AnimationController(

      vsync: this,

      duration: const Duration(
        milliseconds: 2500,
      ),

    );



    scaleAnimation = Tween<double>(

      begin: 0.2,

      end: 1,

    ).animate(

      CurvedAnimation(

        parent: controller,

        curve: Curves.elasticOut,

      ),

    );



    shakeAnimation = TweenSequence<double>(

      [

        TweenSequenceItem(

          tween: Tween(
            begin: 0,
            end: 0.03,
          ),

          weight: 1,

        ),

        TweenSequenceItem(

          tween: Tween(
            begin: 0.03,
            end: -0.03,
          ),

          weight: 1,

        ),

        TweenSequenceItem(

          tween: Tween(
            begin: -0.03,
            end: 0,
          ),

          weight: 1,

        ),

      ],

    ).animate(

      CurvedAnimation(

        parent: controller,

        curve: const Interval(
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


        fit: StackFit.expand,


        children: [



          Image.asset(

            "assets/images/background/home_background.png",

            fit: BoxFit.cover,

          ),




          Container(

            color: Colors.black.withOpacity(0.18),

          ),






          Center(


            child: AnimatedBuilder(


              animation: controller,


              builder: (context,child){


                return Transform.scale(


                  scale: scaleAnimation.value,


                  child: Transform.rotate(


                    angle: shakeAnimation.value,


                    child: child,


                  ),


                );


              },


              child: Image.asset(


                "assets/images/ui/puzzle_logo.png",


                width: 230,


              ),



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