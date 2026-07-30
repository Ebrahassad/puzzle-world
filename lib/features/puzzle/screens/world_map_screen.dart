import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/puzzle_data.dart';
import '../models/puzzle_model.dart';

import 'island_screen.dart';
import 'wallet_screen.dart';



class WorldMapScreen extends StatefulWidget {

  const WorldMapScreen({
    super.key,
  });


  @override
  State<WorldMapScreen> createState() =>
      _WorldMapScreenState();

}




class _WorldMapScreenState extends State<WorldMapScreen>
    with TickerProviderStateMixin {



  //==================================================
  // صورة العالم (تحتوي الجزر الخمس)
  //==================================================


  static const String mapImage =
      "assets/images/world/world_map.png";



  //==================================================
  // بيانات الجزر للفتح فقط
  // لا يوجد رسم جزر
  //==================================================


  late final List<PuzzleModel> islands;




  //==================================================
  // تأثير حركة الخريطة
  //==================================================


  late AnimationController mapController;


  late Animation<double> mapScaleAnimation;


  late Animation<Offset> mapMoveAnimation;




  //==================================================
  // النجوم بالخلفية
  //==================================================


  late AnimationController starsController;


  late Animation<double> starsAnimation;




  //==================================================
  // تأثير البحر
  //==================================================


  late AnimationController seaController;


  late Animation<double> seaAnimation;




  //==================================================
  // الجزيرة المختارة
  //==================================================


  String? selectedIsland;



  @override
  void initState() {

    super.initState();



    // جميع الجزر مفتوحة مؤقتاً

    islands = PuzzleData.puzzles;




    // حركة الخريطة

    mapController = AnimationController(

      vsync:this,

      duration:

      const Duration(

        seconds:18,

      ),

    )..repeat(

      reverse:true,

    );




    mapScaleAnimation =
        Tween<double>(

          begin:1.0,

          end:1.03,

        ).animate(


          CurvedAnimation(

            parent:mapController,

            curve:Curves.easeInOut,

          ),

        );





    mapMoveAnimation =
        Tween<Offset>(

          begin:Offset.zero,

          end:

          const Offset(

            0.01,

            -0.01,

          ),

        ).animate(


          CurvedAnimation(

            parent:mapController,

            curve:Curves.easeInOut,

          ),

        );





    // حركة النجوم


    starsController = AnimationController(

      vsync:this,

      duration:

      const Duration(

        seconds:8,

      ),

    )..repeat();




    starsAnimation =
        Tween<double>(

          begin:0,

          end:1,

        ).animate(


          CurvedAnimation(

            parent:starsController,

            curve:Curves.linear,

          ),

        );





    // حركة البحر


    seaController = AnimationController(

      vsync:this,

      duration:

      const Duration(

        seconds:10,

      ),

    )..repeat(

      reverse:true,

    );





    seaAnimation =
        Tween<double>(

          begin:0.03,

          end:0.10,

        ).animate(


          CurvedAnimation(

            parent:seaController,

            curve:Curves.easeInOut,

          ),

        );



  }


//==================================================
// BUILD
//==================================================


@override
Widget build(BuildContext context) {


  final size = MediaQuery.of(context).size;


  return Scaffold(


    body:Stack(


      children:[



        //==================================================
        // خريطة العالم كاملة
        //==================================================


        Positioned.fill(


          child:AnimatedBuilder(


            animation:mapController,


            builder:(context,child){


              return Transform.translate(


                offset:
                mapMoveAnimation.value * 40,



                child:Transform.scale(


                  scale:
                  mapScaleAnimation.value,



                  child:Center(


                    child:Image.asset(


                      mapImage,



                      fit: BoxFit.cover,


                      width:
                      size.width,



                      height:
                      size.height,


                    ),


                  ),


                ),


              );


            },


          ),


        ),





        //==================================================
        // تأثير النجوم
        //==================================================


        Positioned.fill(


          child:IgnorePointer(


            child:AnimatedBuilder(


              animation:starsController,


              builder:(context,child){


                return CustomPaint(


                  painter:StarFieldPainter(

                    starsAnimation.value,

                  ),


                );


              },


            ),


          ),


        ),






        //==================================================
        // تأثير البحر
        //==================================================


        Positioned.fill(


          child:IgnorePointer(


            child:AnimatedBuilder(


              animation:seaController,


              builder:(context,child){


                return Container(


                  decoration:BoxDecoration(


                    gradient:LinearGradient(


                      colors:[


                        Colors.white.withOpacity(
                          seaAnimation.value,
                        ),


                        Colors.transparent,


                        Colors.blue.withOpacity(
                          seaAnimation.value,
                        ),


                      ],


                    ),


                  ),


                );


              },


            ),


          ),


        ),





        //==================================================
        // مناطق الضغط على الجزر
        // (بدون صور)
        //==================================================



        // الحيوانات


        islandButton(

          left:size.width * 0.25,

          top:size.height * 0.32,

          width:size.width * 0.20,

          islandId:"animals",

        ),




        // الفضاء


        islandButton(

          left:size.width * 0.43,

          top:size.height * 0.10,

          width:size.width * 0.18,

          islandId:"space",

        ),




        // المعالم


        islandButton(

          left:size.width * 0.62,

          top:size.height * 0.33,

          width:size.width * 0.20,

          islandId:"landmarks",

        ),




        // السيارات


        islandButton(

          left:size.width * 0.25,

          top:size.height * 0.57,

          width:size.width * 0.20,

          islandId:"cars",

        ),





        // الطبيعة


        islandButton(

          left:size.width * 0.62,

          top:size.height * 0.57,

          width:size.width * 0.20,

          islandId:"nature",

        ),





        //==================================================
        // أزرار الأعلى
        //==================================================


        SafeArea(


          child:Padding(


            padding:
            EdgeInsets.symmetric(

              horizontal:size.width * 0.04,

              vertical:size.height * 0.02,

            ),


            child:Row(


              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,


              children:[



                // الإعدادات يسار


                circleButton(

                  icon:Icons.settings_rounded,

                  color:Colors.black54,

                  onTap:(){


                  },

                ),





                // المحفظة يمين


                circleButton(

                  icon:
                  Icons.account_balance_wallet_rounded,

                  color:Colors.amber,

                  onTap:(){


                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder:(_)=>
                        const WalletScreen(),

                      ),

                    );


                  },

                ),


              ],


            ),


          ),


        ),



      ],


    ),


  );


}

//==================================================
// زر ضغط الجزيرة الشفاف
//==================================================


Widget islandButton({

  required double left,

  required double top,

  required double width,

  required String islandId,

}) {


  return Positioned(

    left:left,

    top:top,

    child:GestureDetector(

      behavior:HitTestBehavior.translucent,


      onTap:(){


        final island =

        islands.firstWhere(

          (item)=>

          item.id == islandId,

        );


        openIsland(island);


      },


      child:Container(


        width:width,


        height:width,

        color:Colors.transparent,


      ),


    ),


  );


}






//==================================================
// زر علوي دائري
//==================================================


Widget circleButton({

  required IconData icon,

  required Color color,

  required VoidCallback onTap,

}) {


  return Container(


    width:

    MediaQuery.of(context).size.width * 0.12,


    height:

    MediaQuery.of(context).size.width * 0.12,



    decoration:BoxDecoration(


      color:color,


      borderRadius:

      BorderRadius.circular(18),


      boxShadow:[


        BoxShadow(


          color:Colors.black.withOpacity(.25),


          blurRadius:8,


          offset:

          const Offset(0,4),


        ),


      ],


    ),



    child:IconButton(


      icon:Icon(

        icon,

        color:Colors.white,

      ),


      onPressed:onTap,


    ),


  );


}







//==================================================
// فتح الجزيرة
//==================================================


void openIsland(

    PuzzleModel island,

    ){


  Navigator.push(


    context,


    MaterialPageRoute(


      builder:(_)=>

      IslandScreen(

        island:island,

      ),


    ),


  );


}






//==================================================
// إغلاق الانيميشن
//==================================================


@override
void dispose(){


  mapController.dispose();


  starsController.dispose();


  seaController.dispose();



  super.dispose();


}






//==================================================
// رسم النجوم
//==================================================


class StarFieldPainter extends CustomPainter {


  final double animation;



  const StarFieldPainter(

      this.animation,

      );





  @override
  void paint(

      Canvas canvas,

      Size size,

      ){


    final paint = Paint();


    final random = math.Random(10);




    for(int i = 0; i < 80; i++){



      final x =

      random.nextDouble() *

          size.width;




      final baseY =

      random.nextDouble() *

          size.height;




      final y =

      (baseY +

          animation *

              40 *

              (i % 3 + 1))

          %

          size.height;





      final radius =

      random.nextDouble() *

          1.8 +

          0.5;





      paint.color =

      Colors.white.withOpacity(


        0.25 +


            (math.sin(

              animation *

                  math.pi *

                  2 +

                  i,

            ) + 1) / 4,


      );





      canvas.drawCircle(

        Offset(

          x,

          y,

        ),

        radius,

        paint,

      );


    }


  }






  @override
  bool shouldRepaint(

      covariant StarFieldPainter oldDelegate,

      ){


    return oldDelegate.animation != animation;


  }


}