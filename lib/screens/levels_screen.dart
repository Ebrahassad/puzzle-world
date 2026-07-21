import 'package:flutter/material.dart';
import '../models/puzzle_model.dart';
import '../data/levels_data.dart';
import '../models/puzzle_level_model.dart';


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

            colors: [

              Color(0xff89F7FE),

              Color(0xff66A6FF),

            ],

            begin: Alignment.topCenter,

            end: Alignment.bottomCenter,

          ),

        ),


        child: SafeArea(

          child: Column(

            children: [


              const SizedBox(height:20),


              Text(

                puzzle.title,

                style: const TextStyle(

                  color: Colors.white,

                  fontSize:32,

                  fontWeight:FontWeight.bold,

                ),

              ),


              const SizedBox(height:25),



              Expanded(

                child: ListView.builder(


                  padding:
                  const EdgeInsets.all(20),


                  itemCount: levels.length,


                  itemBuilder:(context,index){


                    final level =
                    levels[index];



                    return _LevelCard(

                      level: level,

                      onTap:(){


                        // لاحقاً نفتح لعبة البازل


                      },

                    );


                  },

                ),

              )


            ],

          ),

        ),

      ),

    );

  }

}




class _LevelCard extends StatelessWidget {


  final PuzzleLevelModel level;

  final VoidCallback onTap;



  const _LevelCard({

    required this.level,

    required this.onTap,

  });



  @override
  Widget build(BuildContext context) {


    return InkWell(

      onTap:onTap,


      borderRadius:
      BorderRadius.circular(25),



      child: Container(


        margin:
        const EdgeInsets.only(bottom:18),



        padding:
        const EdgeInsets.all(20),



        decoration:BoxDecoration(


          color:Colors.white,


          borderRadius:
          BorderRadius.circular(25),



          boxShadow:const [

            BoxShadow(

              color:Colors.black26,

              blurRadius:12,

              offset:Offset(0,7),

            )

          ],


        ),



        child:Row(

          children:[


            Container(

              width:65,

              height:65,

              decoration:const BoxDecoration(

                color:Colors.blue,

                shape:BoxShape.circle,

              ),


              child:const Icon(

                Icons.extension,

                color:Colors.white,

                size:35,

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

              Icons.arrow_forward_ios,

            ),


          ],

        ),


      ),

    );

  }

}
