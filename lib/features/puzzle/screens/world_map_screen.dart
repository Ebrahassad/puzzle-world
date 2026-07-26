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

      setState((){

        totalStars = stars;

        loading = false;

      });

    }

  }





  void openIsland(
      PuzzleModel puzzle,
      ){

    if(totalStars < puzzle.requiredStars){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(
            "تحتاج ${puzzle.requiredStars} نجمة لفتح ${puzzle.title}",
          ),

        ),

      );

      return;

    }



    final levels =
        PuzzleLevelData.getLevels(
          puzzle.id,
        );


    if(levels.isEmpty){

      return;

    }



    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>
            PuzzleLevelScreen(
              puzzle: puzzle,
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

      body: Container(

        decoration: const BoxDecoration(

          image: DecorationImage(

            image: AssetImage(
              "assets/images/background/home_background.png",
            ),

            fit: BoxFit.cover,

          ),

        ),



        child: SafeArea(

          child: Column(

            children: [


              const SizedBox(height:20),



              Row(

                mainAxisAlignment:
                MainAxisAlignment.center,

                children: [


                  const Text(

                    "🌍 Puzzle World",

                    style: TextStyle(

                      color: Colors.white,

                      fontSize: 30,

                      fontWeight:
                      FontWeight.bold,

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

                      color: Colors.white24,

                      borderRadius:
                      BorderRadius.circular(20),

                    ),


                    child: Text(

                      "⭐ $totalStars",

                      style:
                      const TextStyle(

                        color: Colors.white,

                        fontSize:20,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),

                  ),


                ],

              ),




              const SizedBox(height:20),





              Expanded(

                child: GridView.builder(

                  padding:
                  const EdgeInsets.all(20),


                  itemCount:
                  PuzzleData.puzzles.length,


                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(

                    crossAxisCount:2,

                    crossAxisSpacing:20,

                    mainAxisSpacing:20,

                    childAspectRatio:0.8,

                  ),



                  itemBuilder:
                  (context,index){


                    final island =
                    PuzzleData.puzzles[index];



                    final locked =
                    totalStars <
                        island.requiredStars;



                    return GestureDetector(


                      onTap:(){

                        openIsland(island);

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

                                island.image,

                                fit:
                                BoxFit.contain,


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

                                color:
                                Colors.white,

                                size:55,

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

      ),

    );

  }

}