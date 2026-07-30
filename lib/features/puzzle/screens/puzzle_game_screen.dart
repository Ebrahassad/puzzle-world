import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

import '../engine/puzzle_controller.dart';
import '../engine/puzzle_generator.dart';
import '../engine/puzzle_piece.dart';

import '../widgets/puzzle_piece_widget.dart';


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


  late PuzzleController controller;


  List<PuzzlePiece> pieces = [];


  late AssetImage puzzleImage;


  ui.Image? image;


  bool loading = true;


  bool gameReady = false;


  bool completed = false;



  final double boardSize = 300;



  double get pieceSize =>
      boardSize / widget.level.gridSize;




  @override
  void initState() {

    super.initState();


    puzzleImage =
        AssetImage(
          widget.level.image,
        );


    loadGame();

  }





  Future<void> loadGame() async {


    try {


      image =
          await loadImage(
            widget.level.image,
          );



      pieces =
          PuzzleGenerator.generate(

            rows:
            widget.level.gridSize,


            columns:
            widget.level.gridSize,


            imageWidth:
            image!.width.toDouble(),


            imageHeight:
            image!.height.toDouble(),


            boardSize:
            boardSize,

          );



      controller =
          PuzzleController(
            pieces: pieces,
          );



      if(!mounted) return;



      setState((){

        loading = false;

        gameReady = true;

      });



    } catch(e, stack){


  debugPrint(
    "PUZZLE ERROR: $e",
  );


  debugPrint(
    stack.toString(),
  );


  if(!mounted) return;


  setState((){

    loading = false;

    gameReady = false;

  });


  ScaffoldMessenger.of(context).showSnackBar(

    SnackBar(

      content: Text(
        "خطأ: $e",
      ),

    ),

  );


}

  }







  Future<ui.Image> loadImage(
      String path,
      ) async {


    final completer =
        Completer<ui.Image>();


    final stream =
        AssetImage(path)
            .resolve(
              const ImageConfiguration(),
            );



    late ImageStreamListener listener;



    listener =
        ImageStreamListener(

          (ImageInfo info, bool _){


            if(!completer.isCompleted){

              completer.complete(
                info.image,
              );

            }


            stream.removeListener(
              listener,
            );


          },


          onError:(error,stack){


            completer.completeError(
              error,
              stack,
            );


            stream.removeListener(
              listener,
            );


          },

        );



    stream.addListener(
      listener,
    );



    return completer.future;


  }








  void movePiece(

      PuzzlePiece piece,

      DragUpdateDetails details,

      ){


    if(piece.placed || !gameReady){

      return;

    }




    setState((){


      piece.position +=
          details.delta;



      piece.position =
          Offset(

            piece.position.dx.clamp(
              0,
              boardSize-pieceSize,
            ),


            piece.position.dy.clamp(
              0,
              boardSize-pieceSize,
            ),

          );


    });


  }







  void dropPiece(
      PuzzlePiece piece,
      ){


    if(piece.placed){

      return;

    }



    final correct =
        controller.checkPiecePosition(

          piece,

          pieceSize,

        );



    if(correct){


      setState((){

        piece.placed = true;

      });


    }



    if(controller.isCompleted &&
        !completed){


      completed = true;


      showWinDialog();


    }


  }







  void showWinDialog(){


    showDialog(

      context: context,

      builder:(_){


        return AlertDialog(


          title:
          const Text(
            "🎉 أحسنت",
          ),



          content:
          const Text(
            "أكملت البازل",
          ),



          actions:[


            TextButton(

              onPressed:(){

                Navigator.pop(context);

              },


              child:
              const Text(
                "ممتاز",
              ),

            )


          ],


        );


      },

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



    if(!gameReady){


      return Scaffold(

        body:

        Center(

          child:

          Text(
            "تعذر فتح المرحلة",
          ),

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

      ),




      body:

      SingleChildScrollView(


        child:

        Column(

          children:[



            const SizedBox(
              height:20,
            ),





            Container(

              width:boardSize,

              height:boardSize,


              decoration:

              BoxDecoration(

                color:Colors.white,

                borderRadius:
                BorderRadius.circular(20),

              ),



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


                      onPanUpdate:(details){

                        movePiece(
                          piece,
                          details,
                        );

                      },


                      onPanEnd:(_){

                        dropPiece(
                          piece,
                        );

                      },


                      child:

                      PuzzlePieceWidget(

                        piece:piece,

                        image:puzzleImage,

                        size:pieceSize,

                      ),


                    ),

                  );


                }).toList(),


              ),


            ),






            const SizedBox(
              height:20,
            ),






            Container(

              width:boardSize,

              height:boardSize,


              decoration:

              BoxDecoration(

                color:Colors.white,

                borderRadius:
                BorderRadius.circular(20),

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
                    piece.column * pieceSize,


                    top:
                    piece.row * pieceSize,



                    child:

                    PuzzlePieceWidget(

                      piece:piece,

                      image:puzzleImage,

                      size:pieceSize,

                    ),


                  );



                }).toList(),


              ),


            ),



          ],


        ),


      ),


    );


  }






  @override
  void dispose(){


    super.dispose();

  }


}