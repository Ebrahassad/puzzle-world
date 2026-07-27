import 'dart:async';
import 'dart:ui' as ui;

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





  final AudioPlayer bgPlayer = AudioPlayer();

  final AudioPlayer effectPlayer = AudioPlayer();





  int moves = 0;


  int seconds = 0;


  int hints = 0;






  bool loading = true;


  bool finishing = false;


  bool showRewardBox = false;






  // حجم لوحة اللعبة يحسب حسب الشاشة

  double boardSize = 300;





  late AssetImage puzzleImage;



  ui.Image? loadedImage;



  bool imageReady = false;






  double get pieceSize =>

      boardSize / widget.level.gridSize;









  @override
  void initState(){


    super.initState();



    puzzleImage = AssetImage(

      widget.level.image,

    );





    confettiController =

    ConfettiController(

      duration:

      const Duration(seconds:3),

    );





    initAudio();


    loadPuzzleImage();



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









  Future<void> playSound(String file) async {



    await effectPlayer.play(

      AssetSource(

        "audio/$file",

      ),

    );


  }









  Future<void> loadPuzzleImage() async {



    final stream =

    puzzleImage.resolve(

      const ImageConfiguration(),

    );





    stream.addListener(



      ImageStreamListener(

            (info, _) {



          loadedImage = info.image;





          final screenWidth =

              MediaQueryData.fromWindow(

                WidgetsBinding.instance.window,

              ).size.width;





          // ضبط حجم اللوحة حسب عرض الجهاز

          boardSize = screenWidth * 0.82;





          imageReady = true;



          createGame();



        },

      ),

    );



  }









  void createGame(){



    if(loadedImage == null){

      return;

    }






    pieces = PuzzleGenerator.generate(
  rows: widget.level.gridSize,
  columns: widget.level.gridSize,

  imageWidth: loadedImage!.width.toDouble(),
  imageHeight: loadedImage!.height.toDouble(),

  boardSize: boardSize,
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







    setState((){



      piece.position += details.delta;





      // حدود قسم قطع البازل

      final maxX = boardSize - pieceSize;

      final maxY = boardSize - pieceSize;





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





      if(piece.position.dx > maxX){

        piece.position = Offset(

          maxX,

          piece.position.dy,

        );

      }





      if(piece.position.dy > maxY){

        piece.position = Offset(

          piece.position.dx,

          maxY,

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



    }

    else{



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



    if(loading || !imageReady){



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



                  margin:

                  const EdgeInsets.all(10),



                  padding:

                  const EdgeInsets.symmetric(

                    horizontal:15,

                  ),



                  decoration:

                  BoxDecoration(



                    color:Colors.white,



                    borderRadius:

                    BorderRadius.circular(30),



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

                    const EdgeInsets.symmetric(

                      horizontal:10,

                    ),



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



                        clipBehavior:

                        Clip.none,



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



                // ==========================
                // قسم تركيب الصورة
                // ==========================

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



                  ),



                ),



              ],



            ),



          ),



        ),







        // ==========================
        // تأثير الفوز
        // ==========================

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

            0.3,



          ),



        ),







        // ==========================
        // صندوق المكافأة
        // ==========================


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