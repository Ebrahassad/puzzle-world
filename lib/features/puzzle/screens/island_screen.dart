import 'package:flutter/material.dart';

import '../data/puzzle_level_data.dart';
import '../data/island_background_data.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

import '../widgets/level_path_painter.dart';

import 'puzzle_game_screen.dart';



class IslandScreen extends StatefulWidget {


  final PuzzleModel island;



  const IslandScreen({

    super.key,

    required this.island,

  });



  @override
  State<IslandScreen> createState()

      => _IslandScreenState();

}







class _IslandScreenState

    extends State<IslandScreen>

    with TickerProviderStateMixin {



  //==================================================
  // أماكن المراحل
  //==================================================


  final List<Offset> levelPositions = const [


    Offset(0.15,0.00),

    Offset(0.65,0.08),

    Offset(0.25,0.16),

    Offset(0.70,0.24),

    Offset(0.30,0.32),

    Offset(0.65,0.40),

    Offset(0.25,0.48),

    Offset(0.70,0.56),

    Offset(0.35,0.64),

    Offset(0.60,0.72),


  ];





  late AnimationController floatController;


  late Animation<double> floatAnimation;



  late AnimationController backgroundController;


  late Animation<double> backgroundMove;


  late Animation<double> backgroundScale;





  @override
  void initState() {


    super.initState();



    floatController = AnimationController(

      vsync: this,

      duration:

      const Duration(seconds:3),

    )

    ..repeat(

      reverse:true,

    );




    floatAnimation = Tween<double>(

      begin:-6,

      end:6,

    ).animate(

      CurvedAnimation(

        parent:floatController,

        curve:Curves.easeInOut,

      ),

    );





    backgroundController = AnimationController(

      vsync:this,

      duration:

      const Duration(seconds:20),

    )

    ..repeat(

      reverse:true,

    );





    backgroundMove = Tween<double>(

      begin:-8,

      end:8,

    ).animate(

      CurvedAnimation(

        parent:backgroundController,

        curve:Curves.easeInOut,

      ),

    );





    backgroundScale = Tween<double>(

      begin:1.0,

      end:1.02,

    ).animate(

      CurvedAnimation(

        parent:backgroundController,

        curve:Curves.easeInOut,

      ),

    );


  }






  //==================================================
  // فتح المرحلة
  //==================================================


  void openLevel(int level){


    final levels = PuzzleLevelData.getLevels(

      widget.island.id,

    );



    final selectedLevel = levels[level - 1];



    Navigator.push(

      context,

      MaterialPageRoute(

        builder:(_)=>PuzzleGameScreen(

          level:selectedLevel,

        ),

      ),

    );


  }

  //==================================================
  // زر المرحلة
  //==================================================

  Widget levelButton({

    required int level,

  }) {


    return GestureDetector(

      onTap:(){

        openLevel(level);

      },


      child: Stack(

        alignment:Alignment.center,


        children:[



          Image.asset(

            "assets/images/ui/level_piece.png",

            width:95,

            height:95,

            fit:BoxFit.contain,

          ),




          Text(

            "$level",

            style:const TextStyle(

              fontSize:26,

              fontWeight:

              FontWeight.w900,

              color:Colors.white,

              shadows:[

                Shadow(

                  color:Colors.black54,

                  blurRadius:5,

                  offset:Offset(0,2),

                ),

              ],

            ),

          ),


        ],


      ),

    );


  }







  //==================================================
  // BUILD
  //==================================================


  @override
  Widget build(BuildContext context){


    final screenHeight =

        MediaQuery.of(context).size.height;



    final screenWidth =

        MediaQuery.of(context).size.width;



    return Scaffold(


      body:Stack(

        children:[




          //==================================================
          // خلفية الجزيرة
          //==================================================


          Positioned.fill(

            child:AnimatedBuilder(

              animation:backgroundController,


              builder:(context,child){


                return Transform.scale(

                  scale:backgroundScale.value,


                  child:Transform.translate(

                    offset:Offset(

                      backgroundMove.value,

                      0,

                    ),


                    child:child,


                  ),


                );


              },



              child:Image.asset(


                IslandBackgroundData.getBackground(

                  widget.island.id,

                ),



                fit:BoxFit.cover,


              ),


            ),

          ),







          //==================================================
          // صورة الجزيرة
          // تم تصغيرها
          //==================================================


          Positioned(

            top:screenHeight * 0.08,


            left:0,

            right:0,


            child:AnimatedBuilder(

              animation:floatAnimation,


              builder:(context,child){


                return Transform.translate(

                  offset:Offset(

                    0,

                    floatAnimation.value,

                  ),


                  child:child,


                );


              },



              child:Image.asset(


                widget.island.image,



                height:

                screenHeight * 0.32,



                fit:BoxFit.contain,


              ),


            ),

          ),






          //==================================================
          // أزرار التحكم
          //==================================================


          SafeArea(

            child:Padding(

              padding:

              const EdgeInsets.all(16),


              child:Row(

                mainAxisAlignment:

                MainAxisAlignment.spaceBetween,


                children:[



                  CircleAvatar(

                    backgroundColor:

                    Colors.black54,


                    child:IconButton(

                      icon:const Icon(

                        Icons.arrow_back,

                        color:Colors.white,

                      ),


                      onPressed:(){

                        Navigator.pop(context);

                      },

                    ),

                  ),




                  CircleAvatar(

                    backgroundColor:

                    Colors.black54,


                    child:IconButton(

                      icon:const Icon(

                        Icons.settings,

                        color:Colors.white,

                      ),


                      onPressed:(){},


                    ),

                  ),



                ],


              ),


            ),

          ),


          //==================================================
          // مسار المراحل + المراحل
          //==================================================


          Positioned(

            top:screenHeight * 0.48,


            left:0,


            right:0,


            bottom:20,



            child:Stack(

              children:[



                // الطريق

                Positioned.fill(

                  child:CustomPaint(

                    painter:LevelPathPainter(

                      positions:

                      levelPositions,

                    ),

                  ),

                ),





                // المراحل

                ...List.generate(

                  levelPositions.length,


                  (index){



                    final position =

                    levelPositions[index];



                    return Positioned(



                      left:

                      screenWidth *

                      position.dx,



                      top:

                      screenHeight *

                      position.dy,




                      child:levelButton(

                        level:index + 1,

                      ),


                    );


                  },

                ),



              ],

            ),


          ),




        ],


      ),


    );


  }







  //==================================================
  // DISPOSE
  //==================================================


  @override
  void dispose(){


    floatController.dispose();


    backgroundController.dispose();



    super.dispose();


  }



}