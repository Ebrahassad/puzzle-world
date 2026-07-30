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


  late AnimationController glowController;



  late Animation<double> scaleAnimation;


  late Animation<double> fadeAnimation;


  late Animation<double> floatAnimation;


  late Animation<double> shakeAnimation;


  late Animation<double> glowAnimation;







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






    //====================================
    // حركة اللمعان للشعار
    //====================================


    glowController = AnimationController(

      vsync: this,


      duration:

      const Duration(

        seconds: 2,

      ),


    )

      ..repeat(

        reverse: true,

      );





    glowAnimation = Tween<double>(

      begin: 0.3,


      end: 1.0,


    ).animate(


      CurvedAnimation(

        parent:

        glowController,


        curve:

        Curves.easeInOut,


      ),


    );







    //====================================
    // تكبير الشعار
    //====================================


    scaleAnimation = Tween<double>(

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







    //====================================
    // ظهور تدريجي
    //====================================


    fadeAnimation = Tween<double>(

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

    //====================================
    // حركة الطفو
    //====================================


    floatAnimation = Tween<double>(

      begin: -10,


      end: 10,


    ).animate(


      CurvedAnimation(

        parent:

        controller,


        curve:

        Curves.easeInOut,


      ),


    );








    //====================================
    // اهتزاز بسيط للشعار
    //====================================


    shakeAnimation = TweenSequence<double>(


      [

        TweenSequenceItem(

          tween: Tween(

            begin: 0,


            end: 0.025,


          ),


          weight: 1,


        ),



        TweenSequenceItem(

          tween: Tween(

            begin: 0.025,


            end: -0.025,


          ),


          weight: 1,


        ),



        TweenSequenceItem(

          tween: Tween(

            begin: -0.025,


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







    // تشغيل الحركة


    controller.forward();








    // الانتقال للخريطة


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
          // خلفية الاسبلش
          //====================================


          Image.asset(


            "assets/images/background/splash_background.jpg",


            fit:

            BoxFit.cover,


          ),





          Container(


            color:

            Colors.black.withOpacity(

              0.10,

            ),


          ),







          //====================================
          // شعار Puzzle World
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

                    0.20

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

                      AnimatedBuilder(


                        animation:

                        glowController,



                        builder:

                            (

                            context,

                            logo,

                            ){



                          return Container(


                            alignment:

                            Alignment.center,



                            decoration:

                            BoxDecoration(


                              boxShadow: [


                                BoxShadow(


                                  color:

                                  Colors.white

                                      .withOpacity(

                                    glowAnimation.value *

                                        0.35,

                                  ),


                                  blurRadius:

                                  30,


                                  spreadRadius:

                                  5,


                                ),


                              ],


                            ),


                            child:

                            logo,


                          );


                        },



                        child:

                        child,


                      ),


                    ),


                  ),


                ),


              );


            },



            child:

            Image.asset(


              "assets/images/ui/puzzle_world_logo.png",



              width:

              280,


            ),


          ),






          //====================================
          // ايقونة التطبيق
          //====================================


          Positioned(


            bottom:

            60,



            left:

            0,



            right:

            0,



            child:

            FadeTransition(


              opacity:

              fadeAnimation,



              child:

              AnimatedBuilder(


                animation:

                glowController,



                builder:

                    (

                    context,

                    child,

                    ){



                  return Container(


                    alignment:

                    Alignment.center,



                    decoration:

                    BoxDecoration(


                      boxShadow: [


                        BoxShadow(


                          color:

                          Colors.white

                              .withOpacity(

                            glowAnimation.value *

                                0.30,

                          ),


                          blurRadius:

                          25,


                          spreadRadius:

                          4,


                        ),


                      ],


                    ),


                    child:

                    child,


                  );


                },



                child:

                Image.asset(


                  "assets/icon/app_icon.png",


                  width:

                  75,


                  height:

                  75,


                ),


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


    glowController.dispose();



    super.dispose();


  }


}