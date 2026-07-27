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


  late AnimationController logoController;
  late AnimationController fadeController;
  late AnimationController floatController;


  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;
  late Animation<double> floatAnimation;





  @override
  void initState(){

    super.initState();



    logoController = AnimationController(

      vsync:this,

      duration:
      const Duration(seconds:2),

    );



    fadeController = AnimationController(

      vsync:this,

      duration:
      const Duration(milliseconds:1200),

    );



    floatController = AnimationController(

      vsync:this,

      duration:
      const Duration(seconds:3),

    );






    scaleAnimation = Tween<double>(

      begin:0.85,

      end:1.08,

    ).animate(

      CurvedAnimation(

        parent:logoController,

        curve:Curves.elasticOut,

      ),

    );






    fadeAnimation = Tween<double>(

      begin:0,

      end:1,

    ).animate(

      CurvedAnimation(

        parent:fadeController,

        curve:Curves.easeIn,

      ),

    );






    floatAnimation = Tween<double>(

      begin:-10,

      end:10,

    ).animate(

      CurvedAnimation(

        parent:floatController,

        curve:Curves.easeInOut,

      ),

    );






    fadeController.forward();

    logoController.repeat(

      reverse:true,

    );

    floatController.repeat(

      reverse:true,

    );






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


    logoController.dispose();

    fadeController.dispose();

    floatController.dispose();


    super.dispose();


  }









  Widget buildLogo(){


    return AnimatedBuilder(

      animation:Listenable.merge([

        logoController,

        floatController,

      ]),


      builder:(context,child){


        return Transform.translate(

          offset:

          Offset(

            0,

            floatAnimation.value,

          ),


          child:

          Transform.scale(

            scale:

            scaleAnimation.value,


            child:child,


          ),


        );


      },


      child:

      Image.asset(

        "assets/images/ui/puzzle_logo.png",

        width:220,

        height:220,

        fit:BoxFit.contain,

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

            Colors.black.withOpacity(.18),

          ),







          Positioned(

            top:

            MediaQuery.of(context).size.height * .22,


            left:0,

            right:0,


            child:

            FadeTransition(

              opacity:

              fadeAnimation,


              child:

              Center(

                child:

                buildLogo(),

              ),

            ),


          ),







          Positioned(

            top:

            MediaQuery.of(context).size.height * .55,


            left:0,

            right:0,


            child:

            Center(



              child:

              Text(

                "Puzzle World",



                style:

                const TextStyle(


                  fontFamily:"Cairo",


                  fontSize:42,


                  fontWeight:

                  FontWeight.w900,


                  color:

                  Color(0xff2196F3),



                  shadows:[


                    Shadow(

                      color:

                      Colors.black,


                      blurRadius:0,


                      offset:

                      Offset(2,2),

                    ),



                    Shadow(

                      color:

                      Colors.black87,


                      blurRadius:8,


                      offset:

                      Offset(0,4),

                    ),


                  ],


                ),



              ),



            ),



          ),





        ],



      ),



    );

  }


}