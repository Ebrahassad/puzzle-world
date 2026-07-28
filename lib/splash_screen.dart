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


  late AnimationController logoController;
  late AnimationController fadeController;
  late AnimationController floatController;


  late Animation<double> logoScale;
  late Animation<double> logoFloat;
  late Animation<double> fadeAnimation;



  @override
  void initState() {

    super.initState();


    logoController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 2,
      ),
    );


    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ),
    );


    floatController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 3,
      ),
    );



    logoScale = Tween<double>(
      begin: 0.85,
      end: 1.08,
    ).animate(

      CurvedAnimation(
        parent: logoController,
        curve: Curves.elasticOut,
      ),

    );



    logoFloat = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(

      CurvedAnimation(
        parent: floatController,
        curve: Curves.easeInOut,
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


    logoController.repeat(
      reverse: true,
    );


    floatController.repeat(
      reverse: true,
    );

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





  Widget buildLogo() {


    return AnimatedBuilder(

      animation: Listenable.merge([

        logoController,

        floatController,

      ]),


      builder: (context, child) {


        return Transform.translate(

          offset: Offset(

            0,

            logoFloat.value,

          ),


          child: Transform.scale(

            scale: logoScale.value,


            child: child,

          ),

        );

      },



      child: Image.asset(

        "assets/images/ui/puzzle_logo.png",

        width: 220,

        height: 220,

        fit: BoxFit.contain,

      ),

    );

  }






  @override
  Widget build(BuildContext context) {


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





          Positioned(


            top: MediaQuery.of(context).size.height * 0.20,


            left: 0,

            right: 0,



            child: FadeTransition(

              opacity: fadeAnimation,


              child: Center(

                child: buildLogo(),

              ),

            ),

          ),






          Positioned(


            top: MediaQuery.of(context).size.height * 0.52,


            left: 0,

            right: 0,



            child: Center(


              child: PuzzleSplashLogo(

                onFinished: openWorldMap,

              ),


            ),

          ),



        ],


      ),


    );

  }





  @override
  void dispose() {


    logoController.dispose();

    fadeController.dispose();

    floatController.dispose();


    super.dispose();

  }


}