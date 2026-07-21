import 'dart:async';

import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

import '../puzzle_engine/puzzle_piece.dart';
import '../puzzle_engine/puzzle_generator.dart';
import '../puzzle_engine/puzzle_controller.dart';

import '../widgets/puzzle_piece_widget.dart';

import '../utils/image_helper.dart';

import '../managers/puzzle_progress_manager.dart';

import '../services/reward_ad_service.dart';

import 'puzzle_win_screen.dart';

import '../models/game_result_model.dart';



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



  int moves = 0;


  int seconds = 0;



  Timer? timer;



  bool loading = true;


  bool gameStarted = false;



  final double boardSize = 350;




  @override
  void initState() {

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

        saved['puzzleId'] == widget.puzzle.id &&

        saved['levelId'] == widget.level.id){



      final continueGame =

      await showContinueDialog();



      if(continueGame){


        for(final item in saved['pieces']){


          final piece = pieces.firstWhere(

                (p)=>p.id == item['id'],

          );



          piece.position = Offset(

            item['x'],

            item['y'],

          );



          piece.placed =

          item['placed'];

        }



        moves = saved['moves'];

        seconds = saved['seconds'];

      }



    }



    setState((){

      loading = false;

    });



    startTimer();


  }








  Future<bool> showContinueDialog() async {


    final result = await showDialog<bool>(


      context: context,


      barrierDismissible:false,


      builder:(context){


        return AlertDialog(


          shape:RoundedRectangleBorder(


            borderRadius:
            BorderRadius.circular(25),


          ),



          title:const Text(

            '🧩 لعبة مستمرة',

            textAlign:TextAlign.center,

          ),



          content:const Text(

            'وجدنا تقدم سابق، هل تريد المتابعة؟',

            textAlign:TextAlign.center,

          ),



          actions:[


            TextButton(


              onPressed:(){


                Navigator.pop(context,false);


              },


              child:const Text(

                'ابدأ من جديد',

              ),

            ),




            ElevatedButton(


              onPressed:() async {


                final ad =

                await RewardAdService.showContinueAd();



                if(ad && mounted){


                  Navigator.pop(context,true);


                }


              },


              child:const Text(

                '🎬 متابعة',

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


      moves:moves,


      seconds:seconds,


    );


  }







  void dropPiece(

      PuzzlePiece piece,

      Offset position,

      ){



    setState((){


      moves++;


      piece.position = position;



      controller.checkPiecePosition(

        piece,

        boardSize / widget.level.gridSize,

      );


    });



    saveGame();



    if(controller.isCompleted){


      finishGame();


    }


  }








  Future<void> finishGame() async {


    timer?.cancel();


    await PuzzleProgressManager.clearProgress();



    Navigator.pushReplacement(


      context,


      MaterialPageRoute(


        builder:(context)=>PuzzleWinScreen(


          result:GameResultModel(


            stars:3,


            moves:moves,


            time:Duration(seconds:seconds),


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
  Widget build(BuildContext context) {


    if(loading){


      return const Scaffold(


        body:Center(


          child:CircularProgressIndicator(),


        ),

      );

    }




    final image =

    ImageHelper.getPuzzleImage(

      widget.puzzle.image,

    );



    final pieceSize =

        boardSize / widget.level.gridSize;





    return Scaffold(


      body:Container(


        decoration:const BoxDecoration(


          gradient:LinearGradient(


            colors:[

              Color(0xff89F7FE),

              Color(0xff66A6FF),

            ],

          ),

        ),



        child:SafeArea(


          child:Column(


            children:[



              const SizedBox(height:15),



              Text(


                widget.puzzle.title,


                style:const TextStyle(


                  color:Colors.white,


                  fontSize:30,


                  fontWeight:FontWeight.bold,

                ),

              ),




              Text(


                '⭐ $moves حركة  ⏱ $seconds',

                style:const TextStyle(


                  color:Colors.white,


                  fontSize:18,

                ),

              ),





              Expanded(


                child:Stack(


                  children:[



                    Center(


                      child:Container(


                        width:boardSize,


                        height:boardSize,


                        decoration:BoxDecoration(


                          color:Colors.white24,


                          borderRadius:
                          BorderRadius.circular(25),


                        ),


                      ),


                    ),




                    ...pieces.map((piece){



                      return Positioned(


                        left:piece.position.dx,


                        top:piece.position.dy,



                        child:Draggable<PuzzlePiece>(



                          data:piece,



                          feedback:PuzzlePieceWidget(


                            piece:piece,


                            image:image,


                            size:pieceSize,


                          ),



                          childWhenDragging:


                          const SizedBox(),




                          onDragEnd:(details){


                            dropPiece(


                              piece,


                              details.offset,


                            );


                          },



                          child:PuzzlePieceWidget(


                            piece:piece,


                            image:image,


                            size:pieceSize,


                          ),



                        ),


                      );



                    }),



                  ],


                ),

              ),


            ],

          ),

        ),

      ),

    );


  }

}