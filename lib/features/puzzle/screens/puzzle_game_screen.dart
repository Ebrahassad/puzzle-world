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
import '../managers/reward_manager.dart';

import '../services/reward_ad_service.dart';
import '../services/puzzle_audio_service.dart';


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


  bool rewardOpened = false;






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





    confettiController = ConfettiController(

      duration:

      const Duration(seconds:3),

    );





    initAudio();


    loadPuzzleImage();


  }









  Future<void> initAudio() async {


    try{


      await bgPlayer.setReleaseMode(

        ReleaseMode.loop,

      );



      await bgPlayer.play(

        AssetSource(

          "audio/puzzle_bgm.mp3",

        ),

      );


    }catch(e){


      debugPrint(

        "Audio error: $e",

      );


    }


  }









  Future<void> playSound(String file) async {


    try{


      await effectPlayer.play(

        AssetSource(

          "audio/$file",

        ),

      );


    }catch(e){


      debugPrint(

        "Sound error: $e",

      );


    }


  }









  Future<void> loadPuzzleImage() async {


    try{


      final stream =

      puzzleImage.resolve(

        const ImageConfiguration(),

      );





      stream.addListener(



        ImageStreamListener(

              (info, _) {



            loadedImage = info.image;





            final width =

            MediaQueryData.fromView(

              WidgetsBinding

                  .instance

                  .platformDispatcher

                  .views

                  .first,

            ).size.width;





            boardSize = width * 0.82;





            imageReady = true;



            createGame();



          },

        ),

      );



    }catch(e){


      debugPrint(

        "Image loading error: $e",

      );



      if(mounted){


        setState((){


          loading = false;


        });


      }


    }


  }









  void createGame(){


    try{


      if(loadedImage == null){

        return;

      }






      pieces = PuzzleGenerator.generate(

        rows: widget.level.gridSize,

        columns: widget.level.gridSize,


        imageWidth:

        loadedImage!.width.toDouble(),


        imageHeight:

        loadedImage!.height.toDouble(),


        boardSize:

        boardSize,

      );







      controller = PuzzleController(

        pieces: pieces,

      );





      loadProgress();



    }catch(e){


      debugPrint(

        "Create game error: $e",

      );


    }


  }

  Future<void> loadProgress() async {


    try{


      hints = await PuzzleHintManager.getHints();





      if(mounted){


        setState((){


          loading = false;


        });


      }





      startTimer();



    }catch(e){


      debugPrint(

        "Load progress error: $e",

      );


      if(mounted){


        setState((){


          loading = false;


        });


      }


    }


  }









  void startTimer(){


    try{


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



    }catch(e){


      debugPrint(

        "Timer error: $e",

      );


    }


  }









  Future<void> movePiece(

      PuzzlePiece piece,

      DragUpdateDetails details,

      ) async {



    if(piece.placed || finishing){


      return;


    }





    try{


      setState((){



        piece.position += details.delta;





        final maxX =

            boardSize - pieceSize;



        final maxY =

            boardSize - pieceSize;





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



    }catch(e){


      debugPrint(

        "Move piece error: $e",

      );


    }


  }









  Future<void> dropPiece(

      PuzzlePiece piece,

      ) async {



    if(piece.placed || finishing){

      return;

    }





    try{


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



    }catch(e){


      debugPrint(

        "Drop piece error: $e",

      );


    }


  }









  Future<void> saveGame() async {


    try{


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



    }catch(e){


      debugPrint(

        "Save game error: $e",

      );


    }


  }









  void checkCompleted(){


    try{


      if(

      controller.isCompleted &&

          !finishing

      ){



        finishGame();



      }



    }catch(e){


      debugPrint(

        "Check complete error: $e",

      );


    }


  }









  Future<void> usePuzzleHint() async {


    try{


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



    }catch(e){


      debugPrint(

        "Hint error: $e",

      );


    }


  }


  Future<void> finishGame() async {


    if(finishing){

      return;

    }



    try{


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







      if(!mounted){

        return;

      }







      setState((){


        showRewardBox = true;


      });





    }catch(e){


      debugPrint(

        "Finish game error: $e",

      );


    }


  }









  Future<void> openWinScreen() async {


    if(rewardOpened){

      return;

    }



    try{


      rewardOpened = true;







      await playSound(

        "puzzle_reward.mp3",

      );


final reward = await RewardManager.completePuzzle(

  difficulty:

  widget.level.gridSize <= 4
      ? 1
      : widget.level.gridSize <= 6
      ? 2
      : 3,


  rewardKey:

  "${widget.puzzle.id}_${widget.level.id}",

);




      if(!mounted){

        return;

      }







      Navigator.pushReplacement(



        context,



        MaterialPageRoute(



          builder:(_)=>PuzzleWinScreen(



            result:

GameResultModel(

  stars:

  reward?.stars ?? 3,

  moves:moves,

  seconds:seconds,

),




            difficulty:

            widget.level.gridSize <= 4

                ? 1

                : widget.level.gridSize <= 6

                ? 2

                : 3,





            worldId:

            widget.puzzle.id,





            level:

            widget.level.levelNumber,



          ),



        ),



      );





    }catch(e){


      debugPrint(

        "Open win screen error: $e",

      );


    }


  }


  @override
  Widget build(BuildContext context){


    if(loading || !imageReady){


      return const Scaffold(


        body: Center(


          child:CircularProgressIndicator(),


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


            child:Column(


              children:[



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


                      const BoxShadow(

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



                        child:Text(

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









                Expanded(


                  child:Container(


                    margin:

                    const EdgeInsets.symmetric(

                      horizontal:10,

                    ),



                    decoration:

                    BoxDecoration(


                      color:Colors.white,


                      borderRadius:

                      BorderRadius.circular(25),


                    ),





                    child:ClipRRect(


                      borderRadius:

                      BorderRadius.circular(25),



                      child:Stack(


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









                Container(


                  height:

                  boardSize + 40,



                  margin:

                  const EdgeInsets.all(10),




                  decoration:

                  BoxDecoration(


                    color:Colors.white,


                    borderRadius:

                    BorderRadius.circular(25),


                    border:

                    Border.all(

                      color:Colors.orange,

                      width:3,

                    ),


                  ),





                  child:Center(


                    child:SizedBox(


                      width:

                      boardSize,



                      height:

                      boardSize,



                      child:Stack(



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



    try{


      timer?.cancel();



      confettiController.dispose();



      bgPlayer.stop();

      bgPlayer.dispose();



      effectPlayer.dispose();



    }catch(e){


      debugPrint(

        "Dispose error: $e",

      );


    }



    super.dispose();



  }


}