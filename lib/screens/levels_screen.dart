import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';
import '../data/levels_data.dart';
import '../models/puzzle_level_model.dart';

import 'puzzle_game_screen.dart';



class LevelsScreen extends StatelessWidget {


  final PuzzleModel puzzle;


  const LevelsScreen({

    super.key,

    required this.puzzle,

  });



  @override
  Widget build(BuildContext context) {


    final levels =
    LevelsData.byPuzzle(puzzle.id);



    return Scaffold(


      body: Container(


        decoration: const BoxDecoration(


          gradient: LinearGradient(

            colors:[

              Color(0xff89F7FE),

              Color(0xff66A6FF),

            ],

          ),

        ),



        child:SafeArea(


          child:Column(


            children:[


              const SizedBox(height:20),



              Text(


                puzzle.title,


                style:const TextStyle(


                  color:Colors.white,


                  fontSize:32,


                  fontWeight:
                  FontWeight.bold,


                ),

              ),



              const SizedBox(height:25),



              Expanded(


                child:ListView.builder(


                  padding:
                  const EdgeInsets.all(20),


                  itemCount:
                  levels.length,


                  itemBuilder:(context,index){


                    final level =
                    levels[index];



                    return LevelCard(


                      level:level,


                      onTap:(){



                        Navigator.push(



                          context,



                          MaterialPageRoute(



                            builder:(context)=>


                            PuzzleGameScreen(



                              puzzle:puzzle,



                              level:level,



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






class LevelCard extends StatelessWidget {


  final PuzzleLevelModel level;


  final VoidCallback onTap;



  const LevelCard({

    super.key,

    required this.level,

    required this.onTap,

  });



  @override
  Widget build(BuildContext context) {


    return InkWell(


      onTap:onTap,


      borderRadius:
      BorderRadius.circular(25),



      child:Container(


        margin:
        const EdgeInsets.only(bottom:18),


        padding:
        const EdgeInsets.all(20),



        decoration:BoxDecoration(


          color:Colors.white,


          borderRadius:
          BorderRadius.circular(25),



          boxShadow:const[


            BoxShadow(

              color:Colors.black26,

              blurRadius:12,

              offset:Offset(0,8),

            )


          ],



        ),



        child:Row(


          children:[


            const CircleAvatar(


              radius:32,


              child:Icon(

                Icons.extension,

              ),

            ),



            const SizedBox(width:20),



            Expanded(


              child:Column(


                crossAxisAlignment:
                CrossAxisAlignment.start,


                children:[


                  Text(


                    level.difficulty,


                    style:const TextStyle(


                      fontSize:24,


                      fontWeight:
                      FontWeight.bold,


                    ),


                  ),



                  Text(


                    '${level.piecesCount} قطعة',


                    style:const TextStyle(

                      fontSize:17,

                    ),

                  ),



                ],


              ),


            ),



            const Icon(

              Icons.play_circle_fill,

              size:40,

            ),



          ],


        ),


      ),


    );


  }

}