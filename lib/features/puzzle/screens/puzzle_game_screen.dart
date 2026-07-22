import 'dart:async';

import 'package:flutter/material.dart';

import '../models/game_result_model.dart';
import '../models/puzzle_level_model.dart';
import '../models/puzzle_model.dart';

import '../engine/puzzle_controller.dart';
import '../engine/puzzle_generator.dart';
import '../engine/puzzle_piece.dart';

import '../widgets/puzzle_piece_widget.dart';

import '../managers/puzzle_hint_manager.dart';
import '../managers/puzzle_progress_manager.dart';

import '../services/reward_ad_service.dart';
import '../services/puzzle_level_service.dart';

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



  int moves = 0;


  int seconds = 0;


  int hints = 0;



  bool loading = true;


  bool finishing = false;



  final double boardSize = 350;



  double get pieceSize =>

      boardSize / widget.level.gridSize;







  @override
  void initState(){

    super.initState();

    createGame();

  }







  void createGame(){


    pieces = PuzzleGenerator.generate(

      rows: widget.level.gridSize,

      columns: widget.level.gridSize,

      imageWidth: boardSize,

      imageHeight: boardSize,

    );



    controller = PuzzleController(

      pieces: pieces,

    );



    loadProgress();


  }







  Future<void> loadProgress() async {



    final saved =

    await PuzzleProgressManager.loadProgress();





    if(saved != null &&

        saved["puzzleId"] == widget.puzzle.id &&

        saved["levelId"] == widget.level.id){



      final continueGame =

      await showContinueDialog();





      if(continueGame){



        final savedPieces =

        saved["pieces"] ?? [];





        for(final item in savedPieces){



          final piece = pieces.firstWhere(



                (p) =>

            p.id == item["id"].toString(),



            orElse: () => pieces.first,



          );





          piece.position = Offset(



            (item["x"] ?? 0).toDouble(),



            (item["y"] ?? 0).toDouble(),



          );





          piece.placed =

              item["placed"] ?? false;



        }





        moves =

            saved["moves"] ?? 0;



        seconds =

            saved["seconds"] ?? 0;



      }

      else{



        await PuzzleProgressManager

            .clearProgress();



      }



    }






    await loadHints();





    if(mounted){



      setState((){



        loading = false;



      });



    }





    startTimer();


  }







  Future<void> loadHints() async {



    final value =

    await PuzzleHintManager.getHints();





    if(!mounted) return;





    setState((){



      hints = value;



    });



  }

  Future<bool> showContinueDialog() async {


    final result =

    await showDialog<bool>(

      context: context,

      barrierDismissible: false,

      builder:(context){


        return AlertDialog(


          shape:

          RoundedRectangleBorder(

            borderRadius:

            BorderRadius.circular(25),

          ),


          title:

          const Text(

            "🧩 لعبة محفوظة",

            textAlign:

            TextAlign.center,

          ),



          content:

          const Text(

            "وجدنا مرحلة محفوظة، هل تريد المتابعة؟",

            textAlign:

            TextAlign.center,

          ),



          actions:[



            TextButton(


              onPressed:() async {


                await PuzzleProgressManager

                    .clearProgress();



                if(context.mounted){


                  Navigator.pop(

                    context,

                    false,

                  );


                }


              },


              child:

              const Text(

                "ابدأ من جديد",

              ),


            ),






            ElevatedButton(


              onPressed:() async {


                final watched =

                await RewardAdService

                    .showContinueAd();



                if(watched && context.mounted){


                  Navigator.pop(

                    context,

                    true,

                  );


                }


              },


              child:

              const Text(

                "🎬 متابعة",

              ),


            ),



          ],



        );


      },


    );





    return result ?? false;


  }








  void startTimer(){


    timer?.cancel();



    timer = Timer.periodic(

      const Duration(seconds:1),

          (_) {


        if(!mounted || finishing){

          return;

        }



        setState((){


          seconds++;


        });



      },

    );


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









  Future<void> dropPiece(

      PuzzlePiece piece,

      Offset globalPosition,

      ) async {



    if(piece.placed || finishing){

      return;

    }





    final RenderBox box =

    context.findRenderObject()

    as RenderBox;





    final boardPosition =

    box.globalToLocal(

      globalPosition,

    );





    final correctedPosition = Offset(


      (boardPosition.dx - pieceSize / 2)

          .clamp(

        0,

        boardSize - pieceSize,

      ),



      (boardPosition.dy - pieceSize / 2)

          .clamp(

        0,

        boardSize - pieceSize,

      ),



    );






    setState((){



      moves++;



      piece.position =

          correctedPosition;




      controller.checkPiecePosition(

        piece,

        pieceSize,

      );



    });







    await saveGame();



    checkCompleted();



  }









  void checkCompleted(){


    if(controller.isCompleted && !finishing){


      finishGame();


    }


  }









  Future<void> usePuzzleHint() async {



    if(finishing){

      return;

    }





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

  Future<void> loadHints() async {

    final value =
        await PuzzleHintManager.getHints();


    if(!mounted) return;


    setState((){

      hints = value;

    });


  }






  Future<bool> showContinueDialog() async {


    final result =
    await showDialog<bool>(

      context: context,

      barrierDismissible: false,


      builder:(context){


        return AlertDialog(

          shape:

          RoundedRectangleBorder(

            borderRadius:

            BorderRadius.circular(25),

          ),


          title:

          const Text(

            "🧩 لعبة محفوظة",

            textAlign:

            TextAlign.center,

          ),


          content:

          const Text(

            "وجدنا لعبة محفوظة، هل تريد المتابعة؟",

            textAlign:

            TextAlign.center,

          ),



          actions:[


            TextButton(

              onPressed:() async {


                await PuzzleProgressManager

                    .clearProgress();


                if(mounted){

                  Navigator.pop(

                    context,

                    false,

                  );

                }


              },


              child:

              const Text(

                "ابدأ من جديد",

              ),

            ),




            ElevatedButton(


              onPressed:() async {


                final watched =

                await RewardAdService

                    .showContinueAd();



                if(watched && mounted){


                  Navigator.pop(

                    context,

                    true,

                  );


                }


              },


              child:

              const Text(

                "🎬 متابعة",

              ),


            ),


          ],


        );


      },


    );



    return result ?? false;


  }








  void startTimer(){


    timer?.cancel();



    timer = Timer.periodic(


      const Duration(seconds:1),


          (_) {


        if(!mounted || finishing){

          return;

        }



        setState((){


          seconds++;


        });



      },


    );


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









  Future<void> dropPiece(

      PuzzlePiece piece,

      Offset globalPosition,

      ) async {



    if(piece.placed || finishing){

      return;

    }






    final RenderBox box =


    context.findRenderObject()

    as RenderBox;





    final boardPosition =


    box.globalToLocal(

      globalPosition,

    );






    final correctedPosition = Offset(


      (boardPosition.dx - pieceSize / 2)

          .clamp(

        0,

        boardSize - pieceSize,

      ),



      (boardPosition.dy - pieceSize / 2)

          .clamp(

        0,

        boardSize - pieceSize,

      ),


    );







    setState((){


      moves++;



      piece.position =

          correctedPosition;




      controller.checkPiecePosition(

        piece,

        pieceSize,

      );



    });







    await saveGame();



    checkCompleted();



  }









  void checkCompleted(){


    if(controller.isCompleted && !finishing){


      finishGame();


    }


  }


  Future<void> usePuzzleHint() async {


    if(finishing){

      return;

    }



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



    if(finishing){

      return;

    }





    finishing = true;



    timer?.cancel();





    final stars = calculateStars();








    await PuzzleLevelService.finishLevel(



      worldId:

      widget.puzzle.id,



      levelNumber:

      widget.level.levelNumber,



      stars:

      stars,



      difficulty:

      widget.level.gridSize,



    );






    await PuzzleProgressManager.clearProgress();







    if(!mounted){

      return;

    }







    Navigator.pushReplacement(



      context,



      MaterialPageRoute(



        builder: (_) =>



            PuzzleWinScreen(



              result:

              GameResultModel(



                stars:

                stars,



                moves:

                moves,



                time:

                Duration(

                  seconds: seconds,

                ),



              ),





              difficulty:

              widget.level.gridSize,





              worldId:

              widget.puzzle.id,





              level:

              widget.level.levelNumber,



            ),



      ),



    );



  }









  int calculateStars(){


    final size = widget.level.gridSize;



    if(size <= 3 && seconds < 60 && moves < 25){

      return 3;

    }



    if(size <= 4 && seconds < 120){

      return 3;

    }



    if(seconds < 180){

      return 2;

    }



    return 1;


  }









  @override
  void dispose(){


    timer?.cancel();


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






    final ImageProvider image =


    widget.puzzle.image.isEmpty


        ? const AssetImage(

      "assets/images/puzzle_placeholder.png",

    )


        :

    AssetImage(

      widget.puzzle.image,

    );







    return Scaffold(


      body:


      Container(


        decoration:


        const BoxDecoration(


          gradient:


          LinearGradient(


            colors:[


              Color(0xff89F7FE),

              Color(0xff66A6FF),

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


              const SizedBox(height:20),




              Text(


                widget.puzzle.title,


                style:


                const TextStyle(


                  color: Colors.white,

                  fontSize:30,

                  fontWeight:FontWeight.bold,

                ),


              ),




              const SizedBox(height:12),




              Row(


                mainAxisAlignment:

                MainAxisAlignment.center,


                children:[


                  Container(


                    padding:

                    const EdgeInsets.all(12),


                    decoration:


                    BoxDecoration(


                      color:Colors.white24,


                      borderRadius:

                      BorderRadius.circular(20),


                    ),


                    child:


                    Text(


                      "🧩 $moves   ⏱ $seconds",


                      style:

                      const TextStyle(

                        color:Colors.white,

                        fontSize:18,

                      ),


                    ),


                  ),




                  const SizedBox(width:15),




                  ElevatedButton.icon(


                    onPressed:

                    usePuzzleHint,


                    icon:

                    const Icon(Icons.lightbulb),


                    label:

                    Text(

                      "💡 $hints",

                    ),


                  ),


                ],


              ),



              Expanded(


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


                      children:[


                        Container(


                          decoration:

                          BoxDecoration(


                            color:

                            Colors.white30,


                            borderRadius:

                            BorderRadius.circular(25),


                          ),


                        ),




                        ...pieces.map((piece){


                          return AnimatedPositioned(


                            duration:

                            const Duration(

                              milliseconds:180,

                            ),


                            left:

                            piece.position.dx,


                            top:

                            piece.position.dy,



                            child:


                            Draggable<PuzzlePiece>(


                              data:

                              piece,



                              feedback:


                              Material(


                                color:

                                Colors.transparent,


                                child:


                                PuzzlePieceWidget(


                                  piece:

                                  piece,


                                  image:

                                  image,


                                  size:

                                  pieceSize,


                                ),


                              ),




                              childWhenDragging:


                              const SizedBox(),




                              onDragEnd:(details){


                                dropPiece(

                                  piece,

                                  details.offset,

                                );


                              },




                              child:


                              PuzzlePieceWidget(


                                piece:

                                piece,


                                image:

                                image,


                                size:

                                pieceSize,


                              ),


                            ),


                          );


                        }),


                      ],


                    ),


                  ),


                ),


              ),



            ],


          ),


        ),


      ),


    );


  }


}