import 'package:flutter/material.dart';

import '../data/puzzle_data.dart';
import '../data/puzzle_level_data.dart';
import '../managers/puzzle_progress_manager.dart';
import '../models/puzzle_model.dart';

import 'puzzle_level_screen.dart';



class WorldMapScreen extends StatefulWidget {

  const WorldMapScreen({
    super.key,
  });


  @override
  State<WorldMapScreen> createState() =>
      _WorldMapScreenState();

}



class _WorldMapScreenState
    extends State<WorldMapScreen> {


  int totalStars = 0;

  bool loading = true;



  @override
  void initState() {

    super.initState();

    loadStars();

  }



  Future<void> loadStars() async {

    final stars =
        await PuzzleProgressManager.getTotalStars();


    if(mounted){

      setState(() {

        totalStars = stars;

        loading = false;

      });

    }

  }





  void openWorld(
      PuzzleModel world,
      ) {


    if(totalStars < world.requiredStars){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(
            "تحتاج ${world.requiredStars} نجمة لفتح ${world.title}",
          ),

        ),

      );

      return;

    }



    final levels =
        PuzzleLevelData.getLevels(
          world.id,
        );



    if(levels.isEmpty){

      return;

    }



    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>
            PuzzleLevelScreen(
              puzzle: world,
            ),

      ),

    );

  }







  @override
  Widget build(BuildContext context) {


    if(loading){

      return const Scaffold(

        body: Center(

          child:
          CircularProgressIndicator(),

        ),

      );

    }




    return Scaffold(

      body: Stack(

        children: [



          Positioned.fill(

            child: Image.asset(

              "assets/images/world/world_map.jpg",

              fit: BoxFit.cover,

              errorBuilder:
                  (context,error,stackTrace){

                return Container(

                  color:
                  Colors.lightBlue,

                );

              },

            ),

          ),




          SafeArea(

            child: Column(

              children: [



                const SizedBox(height:20),



                Row(

                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [



                    const Text(

                      "Puzzle World",

                      style: TextStyle(

                        color: Colors.white,

                        fontSize:32,

                        fontWeight:
                        FontWeight.bold,

                        shadows: [

                          Shadow(

                            color:
                            Colors.black45,

                            blurRadius:8,

                          ),

                        ],

                      ),

                    ),



                    const SizedBox(width:20),



                    Container(

                      padding:
                      const EdgeInsets.symmetric(

                        horizontal:15,

                        vertical:8,

                      ),

                      decoration: BoxDecoration(

                        color:
                        Colors.white24,

                        borderRadius:
                        BorderRadius.circular(20),

                      ),

                      child: Text(

                        "⭐ $totalStars",

                        style:
                        const TextStyle(

                          color:
                          Colors.white,

                          fontSize:20,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),

                    ),



                  ],

                ),





                Expanded(

                  child: GridView.builder(

                    padding:
                    const EdgeInsets.all(25),


                    itemCount:
                    PuzzleData.puzzles.length,


                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(

                      crossAxisCount:2,

                      crossAxisSpacing:25,

                      mainAxisSpacing:25,

                    ),



                    itemBuilder:
                        (context,index){



                      final world =
                      PuzzleData.puzzles[index];



                      final locked =
                      totalStars <
                          world.requiredStars;



                      return GestureDetector(

                        onTap:(){

                          openWorld(world);

                        },



                        child: Stack(

                          alignment:
                          Alignment.center,

                          children: [



                            Container(

                              decoration:
                              BoxDecoration(

                                borderRadius:
                                BorderRadius.circular(35),

                                boxShadow:
                                const [

                                  BoxShadow(

                                    color:
                                    Colors.black38,

                                    blurRadius:15,

                                    offset:
                                    Offset(0,8),

                                  ),

                                ],

                              ),



                              child: ClipRRect(

                                borderRadius:
                                BorderRadius.circular(35),


                                child:
                                Image.asset(

                                  world.image,

                                  fit:
                                  BoxFit.contain,

                                  errorBuilder:
                                      (context,error,stack){

                                    return const Icon(

                                      Icons.image_not_supported,

                                      size:70,

                                      color:
                                      Colors.white,

                                    );

                                  },

                                ),

                              ),

                            ),




                            if(locked)

                              Container(

                                decoration:
                                BoxDecoration(

                                  color:
                                  Colors.black45,

                                  borderRadius:
                                  BorderRadius.circular(35),

                                ),


                                child:
                                const Icon(

                                  Icons.lock,

                                  size:60,

                                  color:
                                  Colors.white,

                                ),

                              ),



                          ],

                        ),

                      );

                    },


                  ),

                ),


              ],

            ),

          ),


        ],

      ),

    );

  }

}