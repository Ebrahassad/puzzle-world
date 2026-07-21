import 'package:flutter/material.dart';

import '../models/stage_node_model.dart';
import '../widgets/stage_node.dart';

import '../../puzzle/screens/puzzle_game_screen.dart';

import '../../puzzle/models/puzzle_model.dart';
import '../../puzzle/models/puzzle_level_model.dart';



class WorldLevelsScreen extends StatelessWidget {


  final String worldId;


  final String title;



  const WorldLevelsScreen({

    super.key,

    required this.worldId,

    required this.title,

  });





  List<StageNodeModel> createLevels(){


    return List.generate(30, (index){


      return StageNodeModel(


        id:"${worldId}_${index+1}",


        level:index + 1,


        unlocked:index < 5,


        stars:index < 3 ? 3 : 0,


      );


    });


  }






  PuzzleModel createPuzzle(int level){


    return PuzzleModel(


      id:"${worldId}_$level",


      title:"$title - مرحلة $level",


      image:"animals_1.png",


    );


  }






  PuzzleLevelModel createPuzzleLevel(int level){


    return PuzzleLevelModel(


      id:"level_$level",


      puzzleId:"${worldId}_$level",


      gridSize:3,


      piecesCount:9,


      difficulty:"easy",


      unlocked:true,


    );


  }







  @override
  Widget build(BuildContext context){


    final levels = createLevels();




    return Scaffold(



      body:Container(



        decoration:const BoxDecoration(



          gradient:LinearGradient(



            colors:[

              Color(0xff56CCF2),

              Color(0xff2F80ED),

            ],

          ),

        ),



        child:SafeArea(



          child:Column(



            children:[



              const SizedBox(height:20),




              Text(



                title,



                style:const TextStyle(



                  color:Colors.white,

                  fontSize:32,

                  fontWeight:FontWeight.bold,


                ),



              ),





              Expanded(



                child:GridView.builder(



                  padding:

                  const EdgeInsets.all(25),



                  gridDelegate:

                  const SliverGridDelegateWithFixedCrossAxisCount(



                    crossAxisCount:4,


                    mainAxisSpacing:30,


                    crossAxisSpacing:20,


                  ),



                  itemCount:levels.length,



                  itemBuilder:(context,index){



                    final level = levels[index];



                    return StageNode(



                      node:level,



                      onTap:(){



                        Navigator.push(



                          context,



                          MaterialPageRoute(



                            builder:(context)=>



                            PuzzleGameScreen(



                              puzzle:

                              createPuzzle(level.level),



                              level:

                              createPuzzleLevel(level.level),



                            ),



                          ),



                        );



                      },



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