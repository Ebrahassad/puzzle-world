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


  late AnimationController puzzleTextController;





  late Animation<double> scaleAnimation;


  late Animation<double> fadeAnimation;


  late Animation<double> floatAnimation;


  late Animation<double> puzzleTextAnimation;





  bool showPuzzleEffect = false;


  final List<String> puzzleLetters = [

    "P",
    "u",
    "z",
    "z",
    "l",
    "e",
    "W",
    "o",
    "r",
    "l",
    "d",

  ];




  final List<Offset> puzzleOffsets = [

    const Offset(-60,-40),

    const Offset(20,-70),

    const Offset(-40,60),

    const Offset(70,30),

    const Offset(-30,-60),

    const Offset(50,70),

    const Offset(-70,20),

    const Offset(60,-50),

    const Offset(-40,50),

    const Offset(30,70),

    const Offset(80,-20),

  ];







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





    puzzleTextController = AnimationController(

      vsync:this,

      duration:

      const Duration(milliseconds:1200),

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







    puzzleTextAnimation = Tween<double>(

      begin:0,

      end:1,

    ).animate(

      CurvedAnimation(

        parent:puzzleTextController,

        curve:Curves.easeOutBack,

      ),

    );







    fadeController.forward();





    logoController.repeat(

      reverse:true,

    );





    floatController.repeat(

      reverse:true,

    );





    startSplashTimer();


  }







  Future<void> startSplashTimer() async {



    await Future.delayed(

      const Duration(seconds:3),

    );




    if(!mounted){

      return;

    }




    setState((){


      showPuzzleEffect = true;


    });





    await puzzleTextController.forward();





    await Future.delayed(

      const Duration(milliseconds:800),

    );





    if(!mounted){

      return;

    }





    Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder:(_)=>

        const WorldMapScreen(),

      ),

    );


  }


  Widget buildLogo(){


    return AnimatedBuilder(

      animation:

      Listenable.merge([

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


        fit:

        BoxFit.contain,


      ),


    );


  }









  Widget buildPuzzleTitle(){


    return AnimatedBuilder(


      animation:

      puzzleTextAnimation,



      builder:(context,child){



        return Row(


          mainAxisAlignment:

          MainAxisAlignment.center,



          children:

          List.generate(

            puzzleLetters.length,


            (index){



              final offset =

              showPuzzleEffect

                  ? puzzleOffsets[index] *

                  puzzleTextAnimation.value

                  : Offset.zero;






              return Transform.translate(



                offset:offset,



                child:

                Transform.rotate(



                  angle:

                  showPuzzleEffect

                      ? (index.isEven

                      ? 0.25

                      : -0.25)

                      *

                      puzzleTextAnimation.value

                      :0,



                  child:

                  AnimatedOpacity(



                    opacity:

                    1 -

                    puzzleTextAnimation.value * 0.2,



                    duration:

                    const Duration(

                      milliseconds:300,

                    ),



                    child:

                    Text(



                      puzzleLetters[index],



                      style:

                      const TextStyle(



                        fontFamily:

                        "Cairo",



                        fontSize:

                        42,



                        fontWeight:

                        FontWeight.w900,



                        color:

                        Color(0xff2196F3),



                        shadows:[



                          Shadow(

                            color:

                            Colors.black,

                            blurRadius:

                            0,

                            offset:

                            Offset(2,2),

                          ),



                          Shadow(

                            color:

                            Colors.black87,

                            blurRadius:

                            8,

                            offset:

                            Offset(0,4),

                          ),



                        ],



                      ),



                    ),


                  ),


                ),


              );



            },

          ),


        );


      },


    );


  }

  Widget buildLogo(){


    return AnimatedBuilder(

      animation:

      Listenable.merge([

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


        fit:

        BoxFit.contain,


      ),


    );


  }









  Widget buildPuzzleTitle(){


    return AnimatedBuilder(


      animation:

      puzzleTextAnimation,



      builder:(context,child){



        return Row(


          mainAxisAlignment:

          MainAxisAlignment.center,



          children:

          List.generate(

            puzzleLetters.length,


            (index){



              final offset =

              showPuzzleEffect

                  ? puzzleOffsets[index] *

                  puzzleTextAnimation.value

                  : Offset.zero;






              return Transform.translate(



                offset:offset,



                child:

                Transform.rotate(



                  angle:

                  showPuzzleEffect

                      ? (index.isEven

                      ? 0.25

                      : -0.25)

                      *

                      puzzleTextAnimation.value

                      :0,



                  child:

                  AnimatedOpacity(



                    opacity:

                    1 -

                    puzzleTextAnimation.value * 0.2,



                    duration:

                    const Duration(

                      milliseconds:300,

                    ),



                    child:

                    Text(



                      puzzleLetters[index],



                      style:

                      const TextStyle(



                        fontFamily:

                        "Cairo",



                        fontSize:

                        42,



                        fontWeight:

                        FontWeight.w900,



                        color:

                        Color(0xff2196F3),



                        shadows:[



                          Shadow(

                            color:

                            Colors.black,

                            blurRadius:

                            0,

                            offset:

                            Offset(2,2),

                          ),



                          Shadow(

                            color:

                            Colors.black87,

                            blurRadius:

                            8,

                            offset:

                            Offset(0,4),

                          ),



                        ],



                      ),



                    ),


                  ),


                ),


              );



            },

          ),


        );


      },


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

              buildPuzzleTitle(),

            ),

          ),





        ],

      ),


    );


  }









  @override
  void dispose(){



    logoController.dispose();


    fadeController.dispose();


    floatController.dispose();


    puzzleTextController.dispose();



    super.dispose();



  }



}