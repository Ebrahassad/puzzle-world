import 'package:flutter/material.dart';

import '../data/island_background_data.dart';
import '../data/puzzle_level_data.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';


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


final List<int> levelOrder = const [
  0, // 1
  9, // 10
  1, // 2
  8, // 9
  2, // 3
  7, // 8
  3, // 4
  6, // 7
  4, // 5
  5, // 6
];


  late AnimationController floatController;

  late Animation<double> floatAnimation;



  late AnimationController backgroundController;

  late Animation<double> backgroundMove;

  late Animation<double> backgroundScale;



  late List<PuzzleLevelModel> levels;





  @override

  void initState() {

    super.initState();



    levels = PuzzleLevelData.getLevels(

      widget.island.id,

    );





    floatController = AnimationController(

      vsync:this,

      duration:const Duration(seconds:3),

    )

      ..repeat(reverse:true);





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

      duration:const Duration(seconds:20),

    )

      ..repeat(reverse:true);





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

      begin:1,

      end:1.02,

    ).animate(

      CurvedAnimation(

        parent:backgroundController,

        curve:Curves.easeInOut,

      ),

    );


  }





  @override

  void dispose(){

    floatController.dispose();

    backgroundController.dispose();

    super.dispose();

  }






  void openLevel(

      PuzzleLevelModel level,

      ){

    Navigator.push(

      context,

      MaterialPageRoute(

        builder:(_)=>PuzzleGameScreen(

          level:level,

        ),

      ),

    );

  }

  Widget levelButton(
  PuzzleLevelModel level,
){

  return GestureDetector(

    onTap:(){
      openLevel(level);
    },

    child: Stack(

      alignment: Alignment.center,

      children:[


        Image.asset(

          "assets/images/ui/level_piece.png",

          width:95,

          height:95,

          fit:BoxFit.contain,

        ),



        Text(

          "${level.levelNumber}",

          style: const TextStyle(

            color: Colors.white,

            fontSize: 32,

            fontWeight: FontWeight.bold,

            shadows:[

              Shadow(

                color: Colors.black,

                blurRadius:5,

                offset: Offset(0,3),

              ),

            ],

          ),

        ),


      ],

    ),

  );

}



  @override

  Widget build(BuildContext context){


    final height =

        MediaQuery.of(context).size.height;


    final width =

        MediaQuery.of(context).size.width;





    return Scaffold(

      body:Stack(

        children:[




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


              child:Transform.scale(
  scale: 1.25,
  child: Image.asset(
    IslandBackgroundData.getBackground(
      widget.island.id,
    ),
    fit: BoxFit.contain,
     alignment: Alignment.center,
        ),

     ),

   ),

 ),






          Positioned.fill(

            child:Container(

              color:

              Colors.black.withOpacity(0.05),

            ),

          ),







          SafeArea(

            child:Padding(

              padding:

              const EdgeInsets.all(12),


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





          Column(

            children:[



              SizedBox(

                height:

                height * 0.36,


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

                    fit:BoxFit.contain,

                  ),

                ),

              ),




              Expanded(

                child:LayoutBuilder(

                  builder:(context,box){


                    return Stack(

                      clipBehavior:

                      Clip.none,


                      children:[



                        



                        ...List.generate(

                          levels.length,


                              (index){


                            final pos =

                            levelPositions[index];



                            return Positioned(

                              left:

                              box.maxWidth *

                                  pos.dx,


                              top:

                              box.maxHeight *

                                  pos.dy,


                              child:
levelButton(
  levels[levelOrder[index]],
),

                            );


                          },

                        ),



                      ],

                    );


                  },

                ),

              ),



            ],

          ),



        ],

      ),

    );

  }


}