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


  bool loading = true;



  late AnimationController _floatController;

  late Animation<double> _floatAnimation;





  @override
  void initState() {

    super.initState();


    loadStars();



    _floatController = AnimationController(

      vsync: this,

      duration: const Duration(seconds: 3),

    )..repeat(
      reverse: true,
    );



    _floatAnimation = Tween<double>(

      begin: -5,

      end: 5,

    ).animate(

      CurvedAnimation(

        parent: _floatController,

        curve: Curves.easeInOut,

      ),

    );

  }





  Future<void> loadStars() async {


    final stars =
    await PuzzleProgressManager.getTotalStars();



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

        builder: (_) =>

            IslandScreen(

              island: world,

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

      left: x - 40,

      top: y - 40,

      width: 80,

      height: 80,



      child: AnimatedBuilder(

        animation: _floatAnimation,


        builder: (context, child){


          return Transform.translate(

            offset: Offset(

              0,

              _floatAnimation.value,

            ),


            child: child,

          );


        },



        child: GestureDetector(

          onTap: (){


            openWorld(world);


          },


          child: Container(

            color: Colors.transparent,

          ),


        ),


      ),

    );

  }







  @override
  void dispose(){

    _floatController.dispose();

    super.dispose();

  }







  @override
  Widget build(BuildContext context){



    if(loading){

      return const Scaffold(

        body: Center(

          child: CircularProgressIndicator(),

        ),

      );

    }






    return Scaffold(



      body: Stack(

        children: [




          Positioned.fill(

            child: Image.asset(

              "assets/images/World/world_map.jpg",


              fit: BoxFit.cover,



              errorBuilder:

                  (context,error,stackTrace){


                return Container(

                  color: Colors.lightBlue,

                );

              },


            ),

          ),







          Positioned(

            top: 0,

            left: 0,

            right: 0,


            child: GameToolbar(

              logo:

              "assets/images/UI/puzzle_logo.png",


              stars: totalStars,


              rewards: 0,


            ),

          ),







          SafeArea(


            child: LayoutBuilder(


              builder:

                  (context,constraints){



                final width =
                    constraints.maxWidth;



                final height =
                    constraints.maxHeight;





                return Stack(

                  children: [




                    islandButton(

                      "animals",

                      width * 0.256,

                      height * 0.20,

                    ),





                    islandButton(

                      "cars",

                      width * 0.212,

                      height * 0.552,

                    ),





                    islandButton(

                      "space",

                      width * 0.732,

                      height * 0.252,

                    ),





                    islandButton(

                      "landmarks",

                      width * 0.784,

                      height * 0.568,

                    ),





                    islandButton(

                      "nature",

                      width * 0.380,

                      height * 0.793,

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