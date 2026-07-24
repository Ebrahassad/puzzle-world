import 'package:flutter/material.dart';
import '../managers/puzzle_progress_manager.dart';
import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

import '../services/puzzle_level_service.dart';
import '../services/puzzle_level_progress_service.dart';
import '../services/puzzle_level_unlock_service.dart';

import 'puzzle_game_screen.dart';



class PuzzleLevelScreen extends StatefulWidget {


  final PuzzleModel puzzle;



  const PuzzleLevelScreen({

    super.key,

    required this.puzzle,

  });



  @override
  State<PuzzleLevelScreen> createState() =>
      _PuzzleLevelScreenState();


}







class _PuzzleLevelScreenState
    extends State<PuzzleLevelScreen> {



  List<PuzzleLevelModel> levels = [];


  int totalStars = 0;


  bool loading = true;







  @override
  void initState(){

    super.initState();

    loadData();

  }







  Future<void> loadData() async {



    final data =

    await PuzzleLevelService.getLevels(

      widget.puzzle.id,

    );






    final prepared =

    await PuzzleLevelProgressService.prepareLevels(

      worldId: widget.puzzle.id,

      levels: data,

    );





final stars =
    await PuzzleProgressManager.getTotalStars();





    if(mounted){



      setState((){


        levels = prepared;


        totalStars = stars;


        loading = false;



      });


    }


  }







  Future<bool> isUnlocked(

      PuzzleLevelModel level,

      ) async {



    return await PuzzleLevelUnlockService.checkUnlocked(

      worldId: widget.puzzle.id,

      level: level,

    );


  }







  void openLevel(

      PuzzleLevelModel level,

      ) async {



    final unlocked =

    await isUnlocked(level);






    if(!unlocked){



      showLockedDialog(level);


      return;


    }







    await Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) => PuzzleGameScreen(

          puzzle: widget.puzzle,

          level: level,

        ),

      ),

    );





    loadData();


  }







  void showLockedDialog(

      PuzzleLevelModel level,

      ){



    showDialog(


      context: context,


      builder: (context){



        return AlertDialog(



          shape:

          RoundedRectangleBorder(


            borderRadius:

            BorderRadius.circular(25),

          ),






          title:

          const Text(

            "🔒 المرحلة مغلقة",

            textAlign:

            TextAlign.center,

          ),






          content:

          Text(

            "تحتاج ⭐ ${level.requiredStars} نجوم لفتح هذه المرحلة",

            textAlign:

            TextAlign.center,

          ),






          actions:[



            Center(

              child:

              ElevatedButton(

                onPressed: (){

                  Navigator.pop(context);

                },


                child:

                const Text(

                  "حسناً",

                ),

              ),

            )



          ],


        );


      },


    );


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

      Container(



        decoration:

        const BoxDecoration(



          gradient:

          LinearGradient(



            colors:[


              Color(0xffFFD166),


              Color(0xffFF9F1C),


            ],



            begin:

            Alignment.topCenter,



            end:

            Alignment.bottomCenter,



          ),



        ),






        child:

        SafeArea(



          child:

          Column(



            children:[



              const SizedBox(height:25),






              Text(



                widget.puzzle.title,



                style:

                const TextStyle(



                  color:

                  Colors.white,



                  fontSize:

                  32,



                  fontWeight:

                  FontWeight.bold,



                ),



              ),






              const SizedBox(height:10),






              Container(



                padding:

                const EdgeInsets.symmetric(



                  horizontal:20,

                  vertical:8,



                ),



                decoration:

                BoxDecoration(



                  color:

                  Colors.white24,



                  borderRadius:

                  BorderRadius.circular(25),



                ),



                child:

                Text(



                  "⭐ $totalStars",



                  style:

                  const TextStyle(



                    color:

                    Colors.white,



                    fontSize:

                    22,



                  ),



                ),



              ),






              const SizedBox(height:30),






              Expanded(



                child:

                GridView.builder(



                  padding:

                  const EdgeInsets.all(20),






                  gridDelegate:

                  const SliverGridDelegateWithFixedCrossAxisCount(



                    crossAxisCount:

                    3,



                    crossAxisSpacing:

                    15,



                    mainAxisSpacing:

                    15,



                  ),






                  itemCount:

                  levels.length,








                  itemBuilder:(context,index){



                    final level =

                    levels[index];






                    return FutureBuilder<bool>(



                      future:

                      isUnlocked(level),




                      builder:(context,snapshot){



                        final unlocked =

                        snapshot.data ?? false;







                        return GestureDetector(



                          onTap: (){


                            openLevel(level);


                          },






                          child:

                          Container(



                            decoration:

                            BoxDecoration(



                              color:

                              Colors.white,



                              borderRadius:

                              BorderRadius.circular(25),





                              boxShadow:[



                                const BoxShadow(



                                  color:

                                  Colors.black26,



                                  blurRadius:

                                  10,



                                  offset:

                                  Offset(0,6),

                                ),

                              ],

                            ),






                            child:

                            Column(



                              mainAxisAlignment:

                              MainAxisAlignment.center,



                              children:[



                                Icon(



                                  unlocked

                                  ?

                                  Icons.extension

                                  :

                                  Icons.lock,



                                  size:

                                  45,



                                  color:

                                  unlocked

                                  ?

                                  Colors.orange

                                  :

                                  Colors.grey,



                                ),






                                const SizedBox(height:10),






                                Text(



                                  level.title.isEmpty

                                  ?

                                  "مرحلة ${level.levelNumber}"

                                  :

                                  level.title,



                                  textAlign:

                                  TextAlign.center,



                                  style:

                                  const TextStyle(



                                    fontSize:

                                    17,



                                    fontWeight:

                                    FontWeight.bold,



                                  ),



                                ),







                                if(level.earnedStars > 0)



                                  Text(



                                    "⭐ ${level.earnedStars}",



                                    style:

                                    const TextStyle(



                                      color:

                                      Colors.orange,



                                      fontWeight:

                                      FontWeight.bold,



                                    ),



                                  ),






                                if(!unlocked)



                                  Text(



                                    "🔒 ${level.requiredStars}",



                                  ),






                                if(level.completed)



                                  const Text(



                                    "✅",



                                    style:

                                    TextStyle(



                                      fontSize:

                                      20,



                                    ),



                                  ),



                              ],



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
