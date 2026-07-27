import 'dart:async';

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';


import '../models/game_result_model.dart';
import '../models/puzzle_level_model.dart';
import '../models/puzzle_model.dart';


import '../engine/puzzle_controller.dart';
import '../engine/puzzle_generator.dart';
import '../engine/puzzle_piece.dart';


import '../widgets/puzzle_piece_widget.dart';
import '../widgets/reward_box_widget.dart';


import '../managers/puzzle_hint_manager.dart';
import '../managers/puzzle_progress_manager.dart';


import '../services/reward_ad_service.dart';


import 'puzzle_win_screen.dart';








class PuzzleGameScreen extends StatefulWidget {



  final PuzzleModel puzzle;


  final PuzzleLevelModel level;




  const PuzzleGameScreen({


    super.key,


    required this.puzzle,


    required this.level,


  });






  @override
  State<PuzzleGameScreen> createState() =>

      _PuzzleGameScreenState();



}









class _PuzzleGameScreenState

    extends State<PuzzleGameScreen> {



  late List<PuzzlePiece> pieces;



  late PuzzleController controller;




  Timer? timer;



  late ConfettiController confettiController;





  int moves = 0;


  int seconds = 0;


  int hints = 0;






  bool loading = true;


  bool finishing = false;


  bool showRewardBox = false;







  // حجم لوحة التركيب

  final double boardSize = 330;







  double get pieceSize =>

      boardSize / widget.level.gridSize;









  @override

  void initState(){


    super.initState();




    confettiController = ConfettiController(



      duration:

      const Duration(seconds:3),



    );



    createGame();



  }








  void createGame(){



    pieces = PuzzleGenerator.generate(



      rows:

      widget.level.gridSize,



      columns:

      widget.level.gridSize,



      imageWidth:

      boardSize,



      imageHeight:

      boardSize,



    );






    controller = PuzzleController(
  pieces: pieces,
  boardOffsetY: boardSize + 50,
);





    loadProgress();



  }








  Future<void> loadProgress() async {



    await loadHints();



    if(mounted){


      setState((){


        loading = false;


      });


    }




    startTimer();



  }








  Future<void> loadHints() async {



    hints = await PuzzleHintManager.getHints();



  }








  void startTimer(){



    timer?.cancel();



    timer = Timer.periodic(



      const Duration(seconds:1),



      (_){



        if(!mounted || finishing){


          return;


        }




        setState((){


          seconds++;


        });



      },



    );



  }


  Future<void> movePiece(

      PuzzlePiece piece,

      DragUpdateDetails details,

      ) async {



    if(piece.placed || finishing){

      return;

    }




    setState((){


      piece.position += details.delta;



    });



  }









  Future<void> dropPiece(

      PuzzlePiece piece,

      ) async {



    if(piece.placed || finishing){

      return;

    }





    setState((){



      moves++;




      controller.checkPiecePosition(

        piece,

        pieceSize,

      );



    });





    await saveGame();



    checkCompleted();



  }









  Future<void> saveGame() async {



    await PuzzleProgressManager.saveProgress(



      puzzleId:

      widget.puzzle.id,



      levelId:

      widget.level.id,



      pieces:

      pieces,



      moves:

      moves,



      seconds:

      seconds,



    );



  }









  void checkCompleted(){



    if(controller.isCompleted && !finishing){



      finishGame();



    }



  }









  Future<void> usePuzzleHint() async {



    bool available =

    await PuzzleHintManager.consumeHint();






    if(!available){



      final watched =

      await RewardAdService.showRewardAd();




      if(watched){



        await PuzzleHintManager.addHints(3);



        available = true;



      }



    }






    if(!available){


      return;


    }







    final piece =

    PuzzleHintManager.findAvailablePiece(

      pieces,

    );






    if(piece == null){


      return;


    }






    setState((){



      controller.applyHint(

        piece,

        pieceSize,

      );



      moves++;



    });






    await saveGame();




    await loadHints();




    checkCompleted();



  }









  Future<void> finishGame() async {



    finishing = true;



    timer?.cancel();







    await PuzzleProgressManager.completeLevel(



      widget.level.id,



    );








    if(!mounted){


      return;


    }






    confettiController.play();







    await Future.delayed(



      const Duration(milliseconds:1200),



    );






    setState((){



      showRewardBox = true;



    });



  }









  Future<void> openWinScreen() async {



    await PuzzleProgressManager.addStars(3);






    if(!mounted){


      return;


    }






    Navigator.pushReplacement(



      context,



      MaterialPageRoute(



        builder:(_)=>PuzzleWinScreen(



          result:

          GameResultModel(



            stars:3,



            moves:moves,



            time:

            Duration(

              seconds:seconds,

            ),



          ),



        ),



      ),



    );



  }









  @override

  void dispose(){



    timer?.cancel();



    confettiController.dispose();



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







    return Stack(



      children:[



        Scaffold(



          backgroundColor:

          Colors.blueGrey.shade50,



          body:

          SafeArea(



            child:

            Column(



              children:[






                // شريط معلومات اللعبة

                Container(



                  height:60,



                  padding:

                  const EdgeInsets.symmetric(

                    horizontal:15,

                  ),



                  decoration:

                  const BoxDecoration(



                    color:Colors.white,

                    boxShadow:[

                      BoxShadow(

                        color:Colors.black12,

                        blurRadius:8,

                      ),

                    ],

                  ),



                  child:Row(



                    mainAxisAlignment:

                    MainAxisAlignment.spaceAround,



                    children:[



                      Text(

                        "🧩 $moves",

                        style:

                        const TextStyle(

                          fontSize:18,

                          fontWeight:

                          FontWeight.bold,

                        ),

                      ),




                      Text(

                        "⏱ $seconds",

                        style:

                        const TextStyle(

                          fontSize:18,

                          fontWeight:

                          FontWeight.bold,

                        ),

                      ),




                      GestureDetector(



                        onTap:

                        usePuzzleHint,



                        child:

                        Text(

                          "💡 $hints",

                          style:

                          const TextStyle(

                            fontSize:18,

                            fontWeight:

                            FontWeight.bold,

                          ),

                        ),



                      ),



                    ],



                  ),



                ),







                // قسم قطع البازل

                Expanded(



                  child:

                  Container(



                    margin:

                    const EdgeInsets.all(10),



                    decoration:

                    BoxDecoration(



                      color:

                      Colors.white,



                      borderRadius:

                      BorderRadius.circular(25),



                    ),



                    child:

                    Stack(



                      children:



                      pieces.map((piece){



                        return Positioned(



                          left:

                          piece.position.dx,



                          top:

                          piece.position.dy,



                          child:

                          GestureDetector(



                            onPanUpdate:

                                (details){



                              movePiece(

                                piece,

                                details,

                              );



                            },



                            onPanEnd:

                                (_){



                              dropPiece(

                                piece,

                              );



                            },



                            child:

                            PuzzlePieceWidget(



                              key:

                              ValueKey(

                                piece.id,

                              ),



                              piece:

                              piece,



                              image:

                              AssetImage(

                                widget.level.image,

                              ),



                              size:

                              pieceSize,



                            ),



                          ),



                        );



                      }).toList(),



                    ),



                  ),



                ),







                // قسم تركيب الصورة

                Container(



                  height:

                  boardSize + 30,



                  margin:

                  const EdgeInsets.all(10),



                  decoration:

                  BoxDecoration(



                    color:

                    Colors.white,



                    borderRadius:

                    BorderRadius.circular(25),



                    border:

                    Border.all(

                      color:

                      Colors.orange,

                      width:3,

                    ),



                  ),



                  child:

                  Center(



                    child:

                    SizedBox(



                      width:

                      boardSize,



                      height:

                      boardSize,



                      child:

                      Stack(



                        children:



                        pieces.map((piece){



                          return Positioned(



                            left:

                            piece.placed

                                ?

                            piece.column *

                            pieceSize

                                :

                            0,



                            top:

                            piece.placed

                                ?

                            piece.row *

                            pieceSize

                                :

                            0,



                            child:

                            piece.placed

                                ?

                            PuzzlePieceWidget(



                              piece:

                              piece,



                              image:

                              AssetImage(

                                widget.level.image,

                              ),



                              size:

                              pieceSize,



                            )

                                :

                            const SizedBox(),



                          );



                        }).toList(),



                      ),



                    ),



                  ),



                ),



              ],



            ),



          ),



        ),








        // تأثير الفوز

        Align(



          alignment:

          Alignment.topCenter,



          child:

          ConfettiWidget(



            confettiController:

            confettiController,



            blastDirectionality:

            BlastDirectionality.explosive,



            numberOfParticles:

            35,



            gravity:

            0.3,



          ),



        ),








        // صندوق المكافأة

        if(showRewardBox)



          Container(



            color:

            Colors.black54,



            child:

            RewardBoxWidget(



              onRewardOpened:(){



                openWinScreen();



              },



            ),



          ),



      ],



    );


  }