import 'package:flutter/material.dart';

import '../managers/puzzle_progress_manager.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

import '../services/puzzle_level_service.dart';
import '../services/puzzle_level_progress_service.dart';
import '../services/puzzle_level_unlock_service.dart';

import '../widgets/game_toolbar.dart';

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
    extends State<PuzzleLevelScreen>
    with SingleTickerProviderStateMixin {



  List<PuzzleLevelModel> levels = [];



  int totalStars = 0;


  int coins = 0;


  int rewards = 0;



  final GlobalKey starKey = GlobalKey();



  bool loading = true;



  late AnimationController pressController;







  @override
  void initState(){


    super.initState();


    pressController = AnimationController(

      vsync:this,

      duration:

      const Duration(milliseconds:120),

    );


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

      levels:data,

    );







    final stars =

    await PuzzleProgressManager

        .getTotalStars();







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



        builder:(_)=>


            PuzzleGameScreen(


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



      builder:(context){



        return Dialog(



          backgroundColor:

          Colors.transparent,



          child:

          Container(



            padding:

            const EdgeInsets.all(25),



            decoration:

            BoxDecoration(



              color:

              Colors.white,



              borderRadius:

              BorderRadius.circular(30),



              boxShadow:[



                const BoxShadow(



                  color:

                  Colors.black26,



                  blurRadius:

                  15,



                  offset:

                  Offset(0,8),



                ),



              ],



            ),



            child:

            Column(



              mainAxisSize:

              MainAxisSize.min,



              children:[



                Image.asset(



                  "assets/images/ui/lock.png",



                  height:75,



                  errorBuilder:

                      (_,__,___){



                    return const Icon(



                      Icons.lock,



                      size:70,



                    );



                  },



                ),





                const SizedBox(height:15),





                const Text(



                  "🔒 المرحلة مغلقة",



                  style:

                  TextStyle(



                    fontSize:22,



                    fontWeight:

                    FontWeight.bold,



                  ),



                ),





                const SizedBox(height:10),





                Text(



                  "تحتاج ⭐ ${level.requiredStars} نجوم لفتح هذه المرحلة",



                  textAlign:

                  TextAlign.center,



                  style:

                  const TextStyle(



                    fontSize:17,



                  ),



                ),





                const SizedBox(height:20),





                ElevatedButton(



                  onPressed:(){



                    Navigator.pop(context);



                  },



                  style:

                  ElevatedButton.styleFrom(



                    backgroundColor:

                    Colors.orange,



                    shape:

                    RoundedRectangleBorder(



                      borderRadius:

                      BorderRadius.circular(25),



                    ),



                  ),



                  child:

                  const Text(



                    "حسناً",



                    style:

                    TextStyle(



                      color:

                      Colors.white,



                    ),



                  ),



                ),



              ],



            ),



          ),



        );



      },



    );



  }









  @override

  void dispose(){


    pressController.dispose();


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

            Container(



              decoration:

              const BoxDecoration(



                gradient:

                LinearGradient(



                  colors:[



                    Color(0xff4FC3F7),


                    Color(0xff1976D2),



                  ],



                  begin:

                  Alignment.topCenter,



                  end:

                  Alignment.bottomCenter,



                ),



              ),



            ),



          ),








          Column(



            children:[





              GameToolbar(



                logo:

                "assets/images/ui/puzzle_logo.png",



                stars:

                totalStars,



                coins:

                coins,



                rewards:

                rewards,



                starKey:

                starKey,



                onBack:(){



                  Navigator.pop(context);



                },



              ),





              Padding(



                padding:

                const EdgeInsets.only(



                  top:15,



                  bottom:10,



                ),



                child:

                Text(



                  widget.puzzle.title,



                  style:

                  const TextStyle(



                    color:

                    Colors.white,



                    fontSize:28,



                    fontWeight:

                    FontWeight.bold,



                    shadows:[



                      Shadow(



                        color:

                        Colors.black45,



                        blurRadius:

                        8,



                      ),



                    ],



                  ),



                ),



              ),





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

                    16,



                    mainAxisSpacing:

                    16,



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







                        return _LevelCard(



                          level:

                          level,



                          unlocked:

                          unlocked,



                          onTap:(){



                            openLevel(level);



                          },



                        );



                      },



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

} // نهاية PuzzleLevelScreen







class _LevelCard extends StatefulWidget {



  final PuzzleLevelModel level;


  final bool unlocked;


  final VoidCallback onTap;





  const _LevelCard({

    required this.level,

    required this.unlocked,

    required this.onTap,

  });





  @override
  State<_LevelCard> createState() =>
      _LevelCardState();


}


class _LevelCardState extends State<_LevelCard>{



  bool pressed = false;





  @override
  Widget build(BuildContext context){



    return GestureDetector(



      onTapDown:(_){


        setState((){


          pressed = true;


        });


      },



      onTapUp:(_){


        setState((){


          pressed = false;


        });


        widget.onTap();


      },



      onTapCancel:(){


        setState((){


          pressed = false;


        });


      },





      child:

      AnimatedScale(



        scale:

        pressed ? 0.93 : 1,



        duration:

        const Duration(milliseconds:120),



        child:

        Container(



          decoration:

          BoxDecoration(



            color:

            Colors.white,



            borderRadius:

            BorderRadius.circular(25),



            boxShadow:[



              BoxShadow(



                color:

                Colors.black.withOpacity(.25),



                blurRadius:

                12,



                offset:

                const Offset(0,6),



              ),



            ],



          ),





          child:

          Column(



            mainAxisAlignment:

            MainAxisAlignment.center,



            children:[





              Image.asset(



                widget.unlocked &&

                    widget.level.image.isNotEmpty

                    ?

                widget.level.image

                    :

                "assets/images/ui/lock.png",



                height:

                65,



                fit:

                BoxFit.cover,



                errorBuilder:

                    (_,__,___){



                  return Icon(



                    widget.unlocked

                        ?

                    Icons.extension

                        :

                    Icons.lock,



                    size:

                    50,



                    color:

                    widget.unlocked

                        ?

                    Colors.orange

                        :

                    Colors.grey,



                  );



                },



              ),





              const SizedBox(height:8),





              Text(



                widget.level.title.isEmpty

                    ?

                "مرحلة ${widget.level.levelNumber}"

                    :

                widget.level.title,



                textAlign:

                TextAlign.center,



                style:

                const TextStyle(



                  fontSize:16,



                  fontWeight:

                  FontWeight.bold,



                ),



              ),






              if(widget.level.completed)



                const Text(



                  "✅",



                  style:

                  TextStyle(

                    fontSize:22,

                  ),



                ),






              if(widget.unlocked && widget.level.earnedStars > 0)



                Text(



                  "⭐ ${widget.level.earnedStars}",



                  style:

                  const TextStyle(



                    color:

                    Colors.orange,



                    fontWeight:

                    FontWeight.bold,



                  ),



                ),





              if(!widget.unlocked)



                Text(



                  "⭐ ${widget.level.requiredStars}",



                  style:

                  const TextStyle(



                    color:

                    Colors.grey,



                    fontWeight:

                    FontWeight.bold,



                  ),



                ),



            ],



          ),



        ),



      ),



    );


  }


}