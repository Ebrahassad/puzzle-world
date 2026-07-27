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
  void initState() {

    super.initState();

    createGame();

  }





  void createGame() {


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

        saved["levelId"] == widget.level.id) {



      final continueGame =
          await showContinueDialog();



      if(continueGame) {


        final savedPieces =
            saved["pieces"] ?? [];



        for(final item in savedPieces) {


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



        moves = saved["moves"] ?? 0;


        seconds = saved["seconds"] ?? 0;



      } else {


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



          shape: RoundedRectangleBorder(


            borderRadius:

            BorderRadius.circular(25),


          ),



          title: const Text(


            "🧩 لعبة محفوظة",


            textAlign: TextAlign.center,


          ),



          content: const Text(


            "وجدنا مرحلة محفوظة، هل تريد المتابعة؟",


            textAlign: TextAlign.center,


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


              child: const Text(


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


              child: const Text(


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




    final localPosition =

    box.globalToLocal(

      globalPosition,

    );




    final newPosition = Offset(



      (localPosition.dx - pieceSize / 2)

          .clamp(

        0,

        boardSize - pieceSize,

      ),




      (localPosition.dy - pieceSize / 2)

          .clamp(

        0,

        boardSize - pieceSize,

      ),



    );




    setState((){



      moves++;



      piece.position = newPosition;



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





    await PuzzleProgressManager.completeLevel(

      widget.level.id,

    );





    await PuzzleProgressManager.addCompletedPuzzle(

      moves: moves,

      seconds: seconds,

    );





    await PuzzleProgressManager.saveLevelStars(

      widget.level.id,

      3,

    );





    await PuzzleProgressManager.addStars(

      3,

    );





    if(!mounted){

      return;

    }





    Navigator.pushReplacement(


      context,


      MaterialPageRoute(



        builder: (_) => PuzzleWinScreen(



          result: GameResultModel(



            stars: 3,



            moves: moves,



            time: Duration(

              seconds: seconds,

            ),



          ),



        ),



      ),



    );



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



        body: Center(



          child: CircularProgressIndicator(),



        ),



      );



    }





    return Scaffold(



      backgroundColor:

      Colors.blue.shade50,





      appBar:

      AppBar(



        title:

        Text(



          widget.level.title,



        ),



        centerTitle:true,



      ),






      body:

      Column(



        children:[





          const SizedBox(height:15),





          Row(



            mainAxisAlignment:

            MainAxisAlignment.spaceEvenly,



            children:[



              Text(



                "🧩 الحركات: $moves",



                style:

                const TextStyle(



                  fontSize:18,

                  fontWeight:FontWeight.bold,

                ),



              ),





              Text(



                "⏱ $seconds",



                style:

                const TextStyle(



                  fontSize:18,

                  fontWeight:FontWeight.bold,

                ),



              ),





              TextButton(



                onPressed:

                usePuzzleHint,



                child:

                Text(



                  "💡 $hints",



                  style:

                  const TextStyle(

                    fontSize:18,

                  ),



                ),



              ),



            ],



          ),






          const SizedBox(height:15),




          SizedBox(



            width:

            boardSize,



            height:

            boardSize,




            child:

            Stack(



              children:

              pieces.map((piece){



                return PuzzlePieceWidget(



                  key:

                  ValueKey(piece.id),




                  piece:

                  piece,




                  image:

                  AssetImage(



                    // تم تغيير مصدر الصورة هنا

                    // يعتمد على صورة المستوى

                    widget.level.image,



                  ),




                  size:

                  pieceSize,



                );



              }).toList(),



            ),



          ),
          const SizedBox(height:20),





          ElevatedButton.icon(



            onPressed:() async {



              await saveGame();




              if(context.mounted){



                ScaffoldMessenger.of(context)

                    .showSnackBar(



                  const SnackBar(



                    content:

                    Text(



                      "💾 تم حفظ اللعبة",



                    ),



                  ),



                );



              }



            },



            icon:

            const Icon(



              Icons.save,



            ),




            label:

            const Text(



              "حفظ اللعبة",



            ),



          ),





        ],



      ),



    );



  }



}