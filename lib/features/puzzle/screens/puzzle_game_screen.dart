import 'dart:async';

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';


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






  // الصوت

  final AudioPlayer bgPlayer = AudioPlayer();

  final AudioPlayer effectPlayer = AudioPlayer();







  // بيانات اللعب

  int moves = 0;


  int seconds = 0;


  int hints = 0;







  bool loading = true;


  bool finishing = false;


  bool showRewardBox = false;








  // حجم لوحة التركيب

  final double boardSize = 330;







  // الصورة

  late AssetImage puzzleImage;







  double get pieceSize =>

      boardSize / widget.level.gridSize;










  @override
  void initState(){


    super.initState();



    puzzleImage = AssetImage(

      widget.level.image,

    );



    confettiController = ConfettiController(



      duration:

      const Duration(seconds:3),



    );



    initAudio();



    createGame();



  }









  Future<void> initAudio() async {



    await bgPlayer.setReleaseMode(

      ReleaseMode.loop,

    );



    await bgPlayer.play(

      AssetSource(

        "audio/puzzle_bgm.mp3",

      ),

    );



  }









  Future<void> playSound(String name) async {



    await effectPlayer.play(

      AssetSource(

        "audio/$name",

      ),

    );


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

    );





    loadProgress();



  }









  Future<void> loadProgress() async {



    hints =

    await PuzzleHintManager.getHints();





    if(mounted){


      setState((){


        loading = false;


      });


    }





    startTimer();



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





    await playSound(

      "puzzle_click.mp3",

    );






    setState((){



      piece.position += details.delta;





      // منع خروج القطعة من الشاشة

      if(piece.position.dx < 0){

        piece.position = Offset(

          0,

          piece.position.dy,

        );

      }



      if(piece.position.dy < 0){

        piece.position = Offset(

          piece.position.dx,

          0,

        );

      }





    });



  }












  Future<void> dropPiece(

      PuzzlePiece piece,

      ) async {



    if(piece.placed || finishing){

      return;

    }







    final correct =

    controller.checkPiecePosition(

      piece,

      pieceSize,

    );







    setState((){


      moves++;


    });






    if(correct){



      await playSound(

        "puzzle_success.mp3",

      );



    }else{



      await playSound(

        "puzzle_fail.mp3",

      );



    }







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



    if(

    controller.isCompleted &&

        !finishing

    ){



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







    await playSound(

      "puzzle_success.mp3",

    );






    await saveGame();



    await loadProgress();





    checkCompleted();



  }













  Future<void> finishGame() async {



    finishing = true;



    timer?.cancel();






    await PuzzleProgressManager.completeLevel(



      widget.level.id,



    );






    await playSound(

      "puzzle_win.mp3",

    );







    if(!mounted){

      return;

    }







    confettiController.play();







    await Future.delayed(

      const Duration(

        milliseconds:1200,

      ),

    );







    setState((){



      showRewardBox = true;



    });



  }












  Future<void> openWinScreen() async {



    await playSound(

      "puzzle_reward.mp3",

    );






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

          Colors.blue.shade50,






          body:

          SafeArea(



            child:

            Column(



              children:[







                // شريط اللعبة

                Container(



                  height:65,



                  padding:

                  const EdgeInsets.symmetric(

                    horizontal:15,

                  ),



                  decoration:

                  BoxDecoration(



                    color:

                    Colors.white,



                    boxShadow:[



                      BoxShadow(

                        color:

                        Colors.black12,

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



                      boxShadow:[



                        BoxShadow(

                          color:

                          Colors.black12,

                          blurRadius:10,

                        ),



                      ],



                    ),




                    child:

                    ClipRRect(



                      borderRadius:

                      BorderRadius.circular(25),



                      child:

                      Stack(



                        children:



                        pieces.map((piece){



                          if(piece.placed){

                            return const SizedBox();

                          }





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



                                dropPiece(piece);



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

                                puzzleImage,



                                size:

                                pieceSize,



                              ),



                            ),



                          );





                        }).toList(),



                      ),



                    ),



                  ),



                ),












                // قسم تركيب الصورة

                Container(



                  height:

                  boardSize + 40,



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

                  Stack(



                    children:



                    pieces.map((piece){



                      if(!piece.placed){

                        return const SizedBox();

                      }







                      return Positioned(



                        left:

                        piece.column *

                            pieceSize,



                        top:

                        piece.row *

                            pieceSize,



                        child:

                        PuzzlePieceWidget(



                          piece:

                          piece,



                          image:

                          puzzleImage,



                          size:

                          pieceSize,



                        ),



                      );



                    }).toList(),



                  ),



                ),



              ],



            ),



          ),



        ),










        // الكونفيتي

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

            40,



            gravity:

            .3,



          ),



        ),











        // صندوق المكافأة

        if(showRewardBox)



          Container(



            color:

            Colors.black54,



            child:

            RewardBoxWidget(



              onRewardOpened:

                  (){



                openWinScreen();



              },



            ),



          ),





      ],



    );



  }









  @override
  void dispose(){



    timer?.cancel();



    confettiController.dispose();



    bgPlayer.stop();

    bgPlayer.dispose();



    effectPlayer.dispose();




    super.dispose();


  }


}