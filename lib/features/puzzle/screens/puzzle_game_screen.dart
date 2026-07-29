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
import '../widgets/game_toolbar.dart';


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



  List<PuzzlePiece> pieces = [];



  late PuzzleController controller;





  Timer? timer;


  late ConfettiController confettiController;





  final AudioPlayer bgPlayer =
      AudioPlayer();


  final AudioPlayer effectPlayer =
      AudioPlayer();






  int moves = 0;


  int seconds = 0;


  int hints = 0;





  bool loading = true;


  bool finishing = false;


  bool showRewardBox = false;


  bool rewardOpened = false;


  bool starAnimationFinished = false;





  double boardSize = 300;





  late AssetImage puzzleImage;


  ui.Image? loadedImage;


  bool imageReady = false;





  final GlobalKey starKey = GlobalKey();





  double get pieceSize =>

      boardSize / widget.level.gridSize;









  @override
  void initState() {

    super.initState();



    puzzleImage = AssetImage(

      widget.level.image,

    );



    confettiController =

    ConfettiController(

      duration:

      const Duration(

        seconds:3,

      ),

    );



    initAudio();



    loadPuzzleImage();


  }








  Future<void> initAudio() async {


    try {


      await bgPlayer.setReleaseMode(

        ReleaseMode.loop,

      );



      await bgPlayer.play(

        AssetSource(

          "audio/puzzle_bgm.mp3",

        ),

      );


    } catch(e) {


      debugPrint(

        "Audio error: $e",

      );


    }

  }

  //===============================
  // تحميل التقدم
  //===============================

  Future<void> loadProgress() async {

    try {

      hints = await PuzzleHintManager.getHints();


      final saved =
          await PuzzleProgressManager.loadProgress();


      if(saved != null &&
          saved["levelId"] == widget.level.id){


        moves =
            saved["moves"] ?? 0;


        seconds =
            saved["seconds"] ?? 0;


        final savedPieces =
            saved["pieces"];


        if(savedPieces != null){

          for(final item in savedPieces){

            final piece =
            pieces.firstWhere(
                  (p)=>p.id == item["id"],
              orElse: ()=>pieces.first,
            );


            piece.position = Offset(
              item["x"],
              item["y"],
            );


            piece.placed =
                item["placed"] ?? false;

          }

        }

      }



      if(!mounted) return;


      setState((){

        loading = false;

      });



      startTimer();



    }catch(e){

      debugPrint(
        "LOAD ERROR: $e",
      );


      if(mounted){

        setState((){

          loading=false;

        });

      }

    }

  }







  //===============================
  // المؤقت
  //===============================

  void startTimer(){

    timer?.cancel();


    timer =
        Timer.periodic(
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








  //===============================
  // تحريك القطعة
  //===============================

  Future<void> movePiece(

      PuzzlePiece piece,

      DragUpdateDetails details,

      ) async {


    if(piece.placed ||
        finishing){

      return;

    }



    setState((){


      piece.position += details.delta;



      final maxX =
          boardSize - pieceSize;


      final maxY =
          boardSize - pieceSize;




      piece.position = Offset(

        piece.position.dx
            .clamp(
          0,
          maxX,
        ),


        piece.position.dy
            .clamp(
          0,
          maxY,
        ),

      );



    });



  }








  //===============================
  // إسقاط القطعة
  //===============================

  Future<void> dropPiece(

      PuzzlePiece piece,

      ) async {


    if(piece.placed ||
        finishing){

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
        "DROP ERROR: $e",
      );

    }


  }







  //===============================
  // حفظ اللعبة
  //===============================

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
        "SAVE ERROR: $e",
      );


    }

  }

  //===============================
  // فحص اكتمال البازل
  //===============================

  void checkCompleted(){

    try{


      if(controller.isCompleted &&
          !finishing){


        finishGame();


      }


    }catch(e){


      debugPrint(

        "CHECK COMPLETE ERROR: $e",

      );


    }


  }








  //===============================
  // استخدام التلميح
  //===============================

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

        "HINT ERROR: $e",

      );


    }


  }










  //===============================
  // إنهاء المرحلة
  //===============================

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






      await PuzzleProgressManager.unlockNextLevel(

        widget.puzzle.id,

        widget.level.levelNumber,

      );






      await PuzzleProgressManager.clearProgress();






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

        "FINISH ERROR: $e",

      );


      finishing = false;


    }


  }










  //===============================
  // فتح شاشة الفوز
  //===============================

  Future<void> openWinScreen() async {


    if(rewardOpened){

      return;

    }





    try{


      rewardOpened = true;






      await bgPlayer.stop();






      if(!mounted){

        return;

      }







      Navigator.pushReplacement(


        context,


        MaterialPageRoute(


          builder: (_)=>

          PuzzleWinScreen(


            result:

            GameResultModel(


              stars:

              widget.level.rewardStars,



              moves:

              moves,



              time:

              Duration(

                seconds: seconds,

              ),


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

        "OPEN WIN ERROR: $e",

      );


    }


  }










  //===============================
  // فتح صندوق المكافأة
  //===============================

  Widget buildRewardBox(){


    if(!showRewardBox){

      return const SizedBox();

    }





    return Container(

      color:

      Colors.black.withOpacity(0.35),





      child:

      RewardBoxWidget(


        starTargetKey:

        starKey,





        onStarReady:

        (){


          starAnimationFinished = true;


        },






        onRewardOpened:

        (){


          if(starAnimationFinished){


            openWinScreen();


          }


        },



      ),


    );


  }

  //===============================
  // بناء واجهة اللعبة
  //===============================

  @override
  Widget build(BuildContext context) {


    if (loading ||
        !imageReady ||
        !::pieces.isInitialized) {

      return const Scaffold(

        body: Center(

          child: CircularProgressIndicator(),

        ),

      );

    }



    return Stack(

      children: [


        Scaffold(

          backgroundColor:
          Colors.blue.shade50,


          body: SafeArea(

            child: Column(

              children: [



                GameToolbar(

                  logo:
                  "assets/images/ui/puzzle_logo.png",

                  starKey:
                  starKey,

                ),



                const SizedBox(
                  height: 10,
                ),





                Expanded(

                  child: Container(

                    margin:
                    const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),


                    decoration: BoxDecoration(

                      color: Colors.white,

                      borderRadius:
                      BorderRadius.circular(25),

                    ),



                    child: ClipRRect(

                      borderRadius:
                      BorderRadius.circular(25),



                      child: Stack(

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
                                  (_) {


                                dropPiece(
                                  piece,
                                );


                              },



                              child:

                              PuzzlePieceWidget(

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

                    color:
                    Colors.white,


                    borderRadius:
                    BorderRadius.circular(25),


                    border:
                    Border.all(

                      color:
                      Colors.orange,

                      width:
                      3,

                    ),

                  ),





                  child: Center(

                    child: SizedBox(

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
            Colors.black.withOpacity(0.35),



            child:

            RewardBoxWidget(

              starTargetKey:
              starKey,



              onStarReady: (){


                starAnimationFinished =
                true;


              },



              onRewardOpened: (){


                if(starAnimationFinished){

                  openWinScreen();

                }


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