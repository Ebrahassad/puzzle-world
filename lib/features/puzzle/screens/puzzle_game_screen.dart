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



    await loadHints();



    if(mounted){

      setState((){

        loading=false;

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

      puzzleId: widget.puzzle.id,

      levelId: widget.level.id,

      pieces: pieces,

      moves: moves,

      seconds: seconds,

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


        available=true;


      }


    }




    if(!available){

      return;

    }




    final piece =

    PuzzleHintManager.findAvailablePiece(

      pieces,

    );




    if(piece==null){

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



    finishing=true;


    timer?.cancel();



    await PuzzleProgressManager.completeLevel(

      widget.level.id,

    );



    await PuzzleProgressManager.addStars(3);



    if(!mounted){

      return;

    }



    Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder:(_)=>PuzzleWinScreen(

          result: GameResultModel(

            stars:3,

            moves:moves,

            time:Duration(

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


    super.dispose();

  }







  @override
  Widget build(BuildContext context){



    if(loading){


      return const Scaffold(

        body:Center(

          child:CircularProgressIndicator(),

        ),

      );


    }





    return Scaffold(



      appBar:AppBar(

        title:Text(widget.level.title),

        centerTitle:true,

      ),




      body:Column(

        children:[



          const SizedBox(height:15),



          Row(

            mainAxisAlignment:

            MainAxisAlignment.spaceEvenly,

            children:[


              Text(
                "🧩 $moves",
                style:const TextStyle(
                  fontSize:18,
                ),
              ),


              Text(
                "⏱ $seconds",
                style:const TextStyle(
                  fontSize:18,
                ),
              ),


              TextButton(
                onPressed:usePuzzleHint,
                child:Text(
                  "💡 $hints",
                  style:const TextStyle(
                    fontSize:18,
                  ),
                ),
              ),


            ],

          ),





          const SizedBox(height:20),





          SizedBox(

            width:boardSize,

            height:boardSize,

            child:Stack(


              children:pieces.map((piece){



                return Positioned(



                  left:piece.position.dx,

                  top:piece.position.dy,



                  child:GestureDetector(



                    onPanUpdate:(details){

                      movePiece(

                        piece,

                        details,

                      );

                    },



                    onPanEnd:(_){

                      dropPiece(piece);

                    },



                    child:PuzzlePieceWidget(



                      key:ValueKey(piece.id),



                      piece:piece,



                      image:AssetImage(

                        widget.level.image,

                      ),



                      size:pieceSize,


                    ),


                  ),


                );



              }).toList(),


            ),

          ),






          const SizedBox(height:20),





          ElevatedButton.icon(



            onPressed:saveGame,



            icon:const Icon(Icons.save),



            label:const Text(

              "حفظ اللعبة",

            ),



          ),



        ],

      ),



    );

  }


}