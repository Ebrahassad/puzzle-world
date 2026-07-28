import 'package:flutter/material.dart';

import 'features/puzzle/screens/world_map_screen.dart';
import 'features/puzzle/widgets/puzzle_splash_logo.dart';


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


  late AnimationController fadeController;

  late Animation<double> fadeAnimation;



  @override
  void initState() {

    super.initState();


    fadeController = AnimationController(

      vsync: this,

      duration: const Duration(
        milliseconds: 1200,
      ),

    );


    fadeAnimation = Tween<double>(

      begin: 0,

      end: 1,

    ).animate(

      CurvedAnimation(

        parent: fadeController,

        curve: Curves.easeIn,

      ),

    );


    fadeController.forward();

  }





  void openWorldMap() {


    Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder: (_) =>
            const WorldMapScreen(),

      ),

    );

  }







  @override
  Widget build(BuildContext context) {


    return Scaffold(


      body: Stack(


        fit: StackFit.expand,


        children: [



          // خلفية شاشة البداية

          Image.asset(

            "assets/images/background/home_background.png",

            fit: BoxFit.cover,

          ),




          // تعتيم خفيف

          Container(

            color: Colors.black.withOpacity(0.18),

          ),





          // كلمة Puzzle World وهي التي تتحول لقطع بازل

          Positioned(

            top: MediaQuery.of(context).size.height * 0.38,

            left: 0,

            right: 0,


            child: FadeTransition(

              opacity: fadeAnimation,


              child: Center(


                child: PuzzleSplashLogo(

                  onFinished: openWorldMap,

                ),


              ),

            ),

          ),



        ],


      ),


    );

  }






  @override
  void dispose() {


    fadeController.dispose();


    super.dispose();

  }


}