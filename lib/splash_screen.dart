import 'package:flutter/material.dart';
import 'dart:math' as math;

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



  //====================================
  // الشعار
  //====================================


  late AnimationController controller;


  late Animation<double> scaleAnimation;


  late Animation<double> fadeAnimation;


  late Animation<double> floatAnimation;


  late Animation<double> shakeAnimation;





  //====================================
  // لمعان العناصر
  //====================================


  late AnimationController glowController;


  late Animation<double> glowAnimation;





  //====================================
  // حركة الخلفية
  //====================================


  late AnimationController weatherController;


  late Animation<double> waterMove;



  late List<_Particle> particles;





  @override
  void initState() {

    super.initState();



    //====================================
    // حركة الشعار الأساسية
    //====================================


    controller = AnimationController(

      vsync: this,

      duration: const Duration(

        milliseconds: 3000,

      ),

    );





    // تكبير ودخول الشعار

    scaleAnimation = Tween<double>(

      begin: 0.45,

      end: 1,

    ).animate(

      CurvedAnimation(

        parent: controller,

        curve: Curves.elasticOut,

      ),

    );





    // ظهور تدريجي

    fadeAnimation = Tween<double>(

      begin: 0,

      end: 1,

    ).animate(

      CurvedAnimation(

        parent: controller,

        curve: const Interval(

          0,

          0.5,

          curve: Curves.easeIn,

        ),

      ),

    );





    // حركة طفو بسيطة

    floatAnimation = Tween<double>(

      begin: -8,

      end: 8,

    ).animate(

      CurvedAnimation(

        parent: controller,

        curve: Curves.easeInOut,

      ),

    );





    // اهتزاز خفيف عند الظهور

    shakeAnimation = TweenSequence<double>(

      [

        TweenSequenceItem(

          tween: Tween(

            begin: 0,

            end: 0.02,

          ),

          weight: 1,

        ),


        TweenSequenceItem(

          tween: Tween(

            begin: 0.02,

            end: -0.02,

          ),

          weight: 1,

        ),


        TweenSequenceItem(

          tween: Tween(

            begin: -0.02,

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
    //====================================
    // حركة اللمعان
    //====================================


    glowController = AnimationController(

      vsync: this,

      duration: const Duration(

        seconds: 2,

      ),

    )

      ..repeat(

        reverse: true,

      );





    glowAnimation = Tween<double>(

      begin: 0.35,

      end: 1,

    ).animate(

      CurvedAnimation(

        parent: glowController,

        curve: Curves.easeInOut,

      ),

    );





    //====================================
    // حركة الماء والمطر
    //====================================


    weatherController = AnimationController(

      vsync: this,

      duration: const Duration(

        seconds: 20,

      ),

    )

      ..repeat();





    waterMove = Tween<double>(

      begin: -12,

      end: 12,

    ).animate(

      CurvedAnimation(

        parent: weatherController,

        curve: Curves.easeInOut,

      ),

    );





    particles = List.generate(

      35,

      (index) => _Particle.random(),

    );





    // تشغيل حركة الشعار

    controller.forward();





    // الانتقال للعالم

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


        fit: StackFit.expand,


        children: [





          //====================================
          // خلفية الاسبلش
          //====================================


          Image.asset(

            "assets/images/background/splash_background.jpg",

            fit: BoxFit.cover,

          ),






          // تغميق خفيف

          Container(

            color: Colors.black.withOpacity(

              0.10,

            ),

          ),





          //====================================
          // حركة الماء
          //====================================


          AnimatedBuilder(

            animation: weatherController,


            builder: (context, child){


              return Positioned.fill(


                child: Transform.translate(


                  offset: Offset(

                    waterMove.value,

                    0,

                  ),


                  child: Opacity(


                    opacity: 0.15,


                    child: Image.asset(

                      "assets/images/background/water_effect.png",

                      fit: BoxFit.cover,


                      errorBuilder: (_,__,___){

                        return const SizedBox();

                      },


                    ),


                  ),


                ),


              );


            },


          ),




          //====================================
          // المطر / الثلج
          //====================================


          AnimatedBuilder(

            animation: weatherController,


            builder: (context, child){


              return Positioned.fill(


                child: CustomPaint(


                  painter: _WeatherPainter(

                    particles,

                    weatherController.value,

                  ),


                ),


              );


            },


          ),

          //====================================
          // شعار Puzzle World
          //====================================


          AnimatedBuilder(

            animation: controller,


            builder: (context, child){


              return Positioned(


                // تم إنزال الشعار قليلاً

                top:

                MediaQuery.of(context)

                    .size

                    .height *

                    0.26

                    +

                    floatAnimation.value,



                left: 0,

                right: 0,



                child: FadeTransition(


                  opacity: fadeAnimation,



                  child: Transform.scale(


                    scale: scaleAnimation.value,



                    child: Transform.rotate(


                      angle: shakeAnimation.value,



                      child: AnimatedBuilder(


                        animation: glowController,



                        builder: (context, logo){


                          return Container(


                            alignment:

                            Alignment.center,



                            decoration: BoxDecoration(


                              boxShadow: [


                                BoxShadow(


                                  color:

                                  Colors.white.withOpacity(

                                    glowAnimation.value *

                                    0.35,

                                  ),



                                  blurRadius: 35,


                                  spreadRadius: 6,


                                ),


                              ],


                            ),



                            child: logo,


                          );


                        },



                        child: child,


                      ),


                    ),


                  ),


                ),


              );


            },



            child: Image.asset(


              "assets/images/ui/puzzle_world_logo.png",



              // تصغير الشعار

              width: 240,


            ),


          ),






          //====================================
          // أيقونة التطبيق أسفل الشاشة
          //====================================


          Positioned(


            bottom: 55,


            left: 0,


            right: 0,



            child: FadeTransition(


              opacity: fadeAnimation,



              child: AnimatedBuilder(


                animation: glowController,



                builder: (context, child){


                  return Container(


                    alignment:

                    Alignment.center,



                    decoration: BoxDecoration(


                      boxShadow: [


                        BoxShadow(


                          color:

                          Colors.white.withOpacity(

                            glowAnimation.value *

                            0.30,

                          ),



                          blurRadius: 25,


                          spreadRadius: 5,


                        ),


                      ],


                    ),



                    child: child,


                  );


                },



                child: Image.asset(


                  "assets/icon/app_icon.png",


                  width: 75,


                  height: 75,


                ),


              ),


            ),


          ),



        ],


      ),


    );


  }
class _Particle {


  double x;

  double y;

  double size;

  double speed;




  _Particle({

    required this.x,

    required this.y,

    required this.size,

    required this.speed,

  });





  factory _Particle.random(){


    final random = math.Random();



    return _Particle(


      x: random.nextDouble(),


      y: random.nextDouble(),


      size:

      2 + random.nextDouble() * 5,


      speed:

      0.2 + random.nextDouble(),


    );


  }


}







class _WeatherPainter extends CustomPainter {



  final List<_Particle> particles;


  final double animationValue;





  _WeatherPainter(

    this.particles,

    this.animationValue,

  );






  @override

  void paint(

    Canvas canvas,

    Size size,

  ) {


    final paint = Paint();




    for(final particle in particles){



      final y =

      (particle.y +

          animationValue *

              particle.speed)

          % 1;



      final x =

          particle.x *

              size.width;





      paint.color = Colors.white.withOpacity(

        0.45,

      );





      canvas.drawCircle(

        Offset(

          x,

          y * size.height,

        ),

        particle.size,

        paint,

      );



    }



  }







  @override

  bool shouldRepaint(

      covariant _WeatherPainter oldDelegate,

      ){

    return true;

  }


}







//====================================
// نهاية الشاشة
//====================================


@override

void dispose(){


  controller.dispose();


  glowController.dispose();


  weatherController.dispose();



  super.dispose();


}


}