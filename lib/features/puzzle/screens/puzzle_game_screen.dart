import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../engine/puzzle_controller.dart';
import '../engine/puzzle_generator.dart';
import '../engine/puzzle_piece.dart';

import '../models/puzzle_level_model.dart';
import '../models/puzzle_model.dart';

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


  late AssetImage puzzleImage;


  ui.Image? image;


  late PuzzleController controller;



  List<PuzzlePiece> pieces = [];



  bool loading = true;

  bool completed = false;



  PuzzlePiece? selectedPiece;



  final GlobalKey boardKey = GlobalKey();



  double get boardSize {


    final size = MediaQuery.of(context).size;


    return size.width * 0.88;


  }



  double get pieceSize =>


      boardSize / widget.level.gridSize;




  @override
  void initState() {

    super.initState();


    puzzleImage = AssetImage(

      widget.level.image,

    );


    loadGame();

  }





  Future<void> loadGame() async {


    image = await loadImage(

      widget.level.image,

    );



    pieces = PuzzleGenerator.generate(

      rows: widget.level.gridSize,

      columns: widget.level.gridSize,

      imageWidth:

          image!.width.toDouble(),

      imageHeight:

          image!.height.toDouble(),

    );



    controller = PuzzleController(

      pieces: pieces,

    );



    _preparePieces();



    if (!mounted) return;



    setState(() {


      loading = false;


    });


  }

  Future<ui.Image> loadImage(

    String path,

  ) async {


    final completer =

        Completer<ui.Image>();



    final stream = AssetImage(path)

        .resolve(

          const ImageConfiguration(),

        );



    late ImageStreamListener listener;



    listener = ImageStreamListener(

      (info, _) {


        if (!completer.isCompleted) {


          completer.complete(

            info.image,

          );


        }


        stream.removeListener(

          listener,

        );


      },


      onError: (error, stack) {


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





  void _preparePieces() {


    pieces.shuffle();



    for (final piece in pieces) {


      piece.position = Offset.zero;


      piece.placed = false;


    }


  }





  void selectPiece(

    PuzzlePiece piece,

  ) {


    if (piece.placed) return;



    setState(() {


      selectedPiece = piece;


    });


  }





  void placePiece(

    PuzzlePiece piece,

  ) {


    if (piece.placed) return;



    final correct =

        controller.checkPiecePosition(

          piece,

          pieceSize,

        );



    if (correct) {


      setState(() {


        piece.placed = true;


        selectedPiece = null;


      });



    } else {


      // إرجاع القطعة للشريط

      setState(() {


        piece.position = Offset.zero;


        selectedPiece = null;


      });


    }



    if (controller.isCompleted &&

        !completed) {


      completed = true;


      showCompleted();


    }


  }





  void showCompleted() {


    Future.delayed(

      const Duration(

        milliseconds: 400,

      ),


      () {


        if (!mounted) return;



        showDialog(

          context: context,

          builder: (_) => AlertDialog(

            title:

                const Text(

              "🎉 أحسنت",

            ),


            content:

                const Text(

              "اكتملت الصورة",

            ),


          ),

        );


      },

    );


  }
  void movePiece(

    PuzzlePiece piece,

    DragUpdateDetails details,

  ) {


    if (piece.placed) return;



    setState(() {


      piece.position += details.delta;



    });


  }





  @override
  Widget build(

    BuildContext context,

  ) {


    if (loading) {


      return const Scaffold(

        body: Center(

          child:

              CircularProgressIndicator(),

        ),

      );


    }



    return Scaffold(


      backgroundColor:

          const Color(0xff10233d),



      appBar: AppBar(


        backgroundColor:

            Colors.transparent,


        elevation: 0,


        title:

            Text(

          widget.level.title,

        ),


      ),




      body: SafeArea(


        child: Column(


          children: [





            //=================================
            // شريط القطع العلوي
            //=================================


            SizedBox(


              height:

                  pieceSize + 30,



              child:

                  ListView.builder(


                scrollDirection:

                    Axis.horizontal,



                padding:

                    const EdgeInsets.symmetric(

                  horizontal: 15,

                ),



                itemCount:

                    pieces.length,



                itemBuilder:

                    (context, index) {


                  final piece =

                      pieces[index];



                  if (piece.placed) {


                    return const SizedBox(

                      width: 5,

                    );


                  }



                  return GestureDetector(


                    onTap: () {


                      selectPiece(

                        piece,

                      );


                    },



                    onPanUpdate:

                        (details) {


                      movePiece(

                        piece,

                        details,

                      );


                    },



                    onPanEnd:

                        (_) {


                      placePiece(

                        piece,

                      );


                    },



                    child:

                        AnimatedScale(


                      duration:

                          const Duration(

                        milliseconds: 200,

                      ),



                      scale:

                          selectedPiece == piece

                              ? 1.18

                              : 1,



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


                },


              ),


            ),





            const SizedBox(

              height: 20,

            ),






            //=================================
            // لوحة تركيب البازل
            //=================================


            Expanded(


              child:

                  Center(


                child:

                    Container(


                  key:

                      boardKey,



                  width:

                      boardSize,



                  height:

                      boardSize,



                  decoration:

                      BoxDecoration(


                    borderRadius:

                        BorderRadius.circular(25),



                    color:

                        Colors.black26,



                    boxShadow: const [


                      BoxShadow(


                        color:

                            Colors.black38,


                        blurRadius:

                            20,


                        offset:

                            Offset(

                          0,

                          10,

                        ),


                      ),


                    ],


                  ),



                  child:

                      Stack(


                    clipBehavior:

                        Clip.none,



                    children:

                        [


                      // القطع المثبتة


                      ...pieces

                          .where(

                            (p) =>

                                p.placed,

                          )

                          .map(


                            (piece) {


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


                        },


                      ),


                    ],


                  ),


                ),


              ),


            ),



          ],


        ),


      ),


    );


  }
  @override
  void dispose() {

    super.dispose();

  }


}