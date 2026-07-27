import 'package:flutter/material.dart';

import '../data/puzzle_data.dart';
import '../managers/puzzle_progress_manager.dart';
import '../models/puzzle_model.dart';

import '../widgets/game_toolbar.dart';

import 'island_screen.dart';



class WorldMapScreen extends StatefulWidget {


  const WorldMapScreen({

    super.key,

  });



  @override
  State<WorldMapScreen> createState() =>
      _WorldMapScreenState();


}






class _WorldMapScreenState
    extends State<WorldMapScreen>
    with SingleTickerProviderStateMixin {



  int totalStars = 0;


  int rewards = 0;


  bool loading = true;





  late AnimationController floatController;

  late Animation<double> floatAnimation;







  @override
  void initState(){

    super.initState();


    loadData();



    floatController = AnimationController(

      vsync:this,

      duration:
      const Duration(seconds:3),

    )..repeat(

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



  }









  Future<void> loadData() async {


    final stars =
    await PuzzleProgressManager
        .getTotalStars();



    if(mounted){


      setState((){


        totalStars = stars;


        loading = false;


      });


    }


  }









  void openWorld(PuzzleModel world){



    Navigator.push(

      context,

      MaterialPageRoute(

        builder:(_)=>

            IslandScreen(

              island:world,

            ),

      ),

    );


  }









  Widget islandButton(


      String id,


      double x,


      double y,

      ){



    final world =
    PuzzleData.getById(id);




    if(world == null){

      return const SizedBox();

    }







    return Positioned(



      left:x-45,


      top:y-45,


      width:90,


      height:90,



      child:

      AnimatedBuilder(



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



        child:

        GestureDetector(


          onTap:(){

            openWorld(world);

          },



          child:

          Container(

            decoration:

            BoxDecoration(

              color:
              Colors.transparent,


              shape:
              BoxShape.circle,


            ),


          ),



        ),



      ),



    );


  }









  @override
  void dispose(){


    floatController.dispose();


    super.dispose();


  }









  @override
  Widget build(BuildContext context){



    if(loading){


      return const Scaffold(


        body:

        Center(

          child:

          CircularProgressIndicator(),

        ),


      );


    }








    return Scaffold(



      body:

      Stack(



        children:[






          Positioned.fill(



            child:

            Image.asset(



              "assets/images/world/world_map.jpg",



              fit:

              BoxFit.cover,



              errorBuilder:

                  (context,error,stackTrace){


                return Container(

                  color:

                  Colors.lightBlue,

                );


              },


            ),



          ),








          Positioned(



            top:0,

            left:0,

            right:0,



            child:

            GameToolbar(



              logo:

              "assets/images/ui/puzzle_logo.png",



              stars:

              totalStars,



              rewards:

              rewards,



            ),



          ),







          SafeArea(



            child:

            LayoutBuilder(



              builder:

                  (context,constraints){



                final width =
                    constraints.maxWidth;


                final height =
                    constraints.maxHeight;




                return Stack(



                  children:[




                    islandButton(

                      "animals",

                      width*0.256,

                      height*0.20,

                    ),






                    islandButton(

                      "cars",

                      width*0.212,

                      height*0.552,

                    ),






                    islandButton(

                      "space",

                      width*0.732,

                      height*0.252,

                    ),






                    islandButton(

                      "landmarks",

                      width*0.784,

                      height*0.568,

                    ),






                    islandButton(

                      "nature",

                      width*0.380,

                      height*0.793,

                    ),



                  ],



                );


              },


            ),



          ),





        ],



      ),



    );


  }


}