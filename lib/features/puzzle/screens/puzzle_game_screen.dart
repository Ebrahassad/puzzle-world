import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../engine/puzzle_controller.dart';
import '../engine/puzzle_generator.dart';
import '../engine/puzzle_painter.dart';
import '../engine/puzzle_piece.dart';

import '../models/puzzle_level_model.dart';



class PuzzleGameScreen extends StatefulWidget {


  final PuzzleLevelModel level;



  const PuzzleGameScreen({

    super.key,

    required this.level,

  });



  @override
  State<PuzzleGameScreen> createState() =>
      _PuzzleGameScreenState();


}





class _PuzzleGameScreenState
    extends State<PuzzleGameScreen> {



  ui.Image? image;



  late PuzzleController controller;



  List<PuzzlePiece> pieces = [];



  bool loading = true;



  final double boardSize = 360;



  final double trayHeight = 110;



  final GlobalKey boardKey = GlobalKey();



  final ScrollController trayController =
      ScrollController();



  Offset boardOffset = Offset.zero;



  @override
  void initState() {


    super.initState();



    _loadImage();


  }







  //==================================================
  // تحميل الصورة
  //==================================================

  Future<void> _loadImage() async {



    final provider = AssetImage(

      widget.level.image,

    );



    final stream = provider.resolve(

      const ImageConfiguration(),

    );

debugPrint("START LOAD: ${widget.level.image}");

    stream.addListener(



      ImageStreamListener(

  (info, _) {

  image = info.image;

  if(mounted){
    setState(() {});
  }

},
  onError:(error, stack){

    debugPrint(
      "IMAGE ERROR: ${widget.level.image}"
    );

    setState(() {
      loading = false;
    });

  },

),


    );


  }








  //==================================================
  // حساب مكان اللوحة
  //==================================================

  void _calculateBoardPosition(){

  WidgetsBinding.instance.addPostFrameCallback((_) {

    if(!mounted){
      return;
    }

    final context = boardKey.currentContext;

    if(context == null){

      debugPrint("BOARD NOT READY");

      Future.delayed(
        const Duration(milliseconds:100),
        (){
          if(mounted){
            _calculateBoardPosition();
          }
        },
      );

      return;
    }

    final RenderBox box =
        context.findRenderObject()
        as RenderBox;


    boardOffset =
        box.localToGlobal(
          Offset.zero,
        );


    debugPrint(
      "BOARD OFFSET = $boardOffset"
    );


    _createPuzzle();

  });

}



  //==================================================
  // إنشاء القطع
  //==================================================

  void _createPuzzle(){

  if(image == null){
    return;
  }


    final pieceSize =

        boardSize /
        widget.level.gridSize;



    pieces = PuzzleGenerator.generate(



      rows: widget.level.gridSize,



      columns: widget.level.gridSize,



      imageSize: Size(

        image!.width.toDouble(),

        image!.height.toDouble(),

      ),



      pieceSize: Size(

        pieceSize,

        pieceSize,

      ),



      traySize: Size(

        MediaQuery.of(context).size.width,

        trayHeight,

      ),



      boardOffset: boardOffset,



    );




    controller = PuzzleController(



      pieces: pieces,



      boardRect: Rect.fromLTWH(

        boardOffset.dx,

        boardOffset.dy,

        boardSize,

        boardSize,

      ),



    );

debugPrint(
  "PUZZLE PIECES = ${pieces.length}"
);

    setState(() {



      loading = false;



    });



  }


  //==================================================
  // تحقق من الفوز
  //==================================================

  void checkWin(){



    if(!controller.isCompleted){

      return;

    }



    Future.delayed(

      const Duration(milliseconds: 400),

      (){


        if(mounted){

          Navigator.pop(context);

        }


      },

    );


  }









  @override
  Widget build(BuildContext context){



    if(loading || image == null){



      return const Scaffold(

        body: Center(

          child: CircularProgressIndicator(),

        ),

      );


    }




    final pieceSize =

        boardSize /

        widget.level.gridSize;







    return Scaffold(



      backgroundColor:

          const Color(0xff18354f),




      body: SafeArea(



        child: Column(



          children: [





            const SizedBox(

              height: 12,

            ),







            //========================================
            // شريط القطع المتحرك
            //========================================


            Container(



              height: trayHeight,



              margin:

              const EdgeInsets.symmetric(

                horizontal: 12,

              ),




              decoration: BoxDecoration(



                color:

                Colors.black26,



                borderRadius:

                BorderRadius.circular(16),




                border: Border.all(

                  color:

                  Colors.white24,

                ),



              ),






              child: ClipRRect(



                borderRadius:

                BorderRadius.circular(16),



                child: SingleChildScrollView(



                  controller:

                  trayController,



                  scrollDirection:

                  Axis.horizontal,



                  child: SizedBox(



                    width:

                    pieces.length *

                        (pieceSize + 12),



                    child: Stack(



                      children:

                      pieces.map((piece){





                        if(piece.state !=

                            PieceState.tray){

                          return const SizedBox();

                        }





                        return Positioned(



                          left:

                          piece.trayPosition.dx,




                          top:

                          piece.trayPosition.dy,




                          child:

                          GestureDetector(



                            onPanStart:

                                (details){



                              controller.pointerDown(

                                details.globalPosition,

                              );



                              setState(() {});



                            },







                            onPanUpdate:

                                (details){



                              controller.pointerMove(

                                details.globalPosition,

                              );



                              setState(() {});



                            },







                            onPanEnd:

                                (_){



                              controller.pointerUp();



                              checkWin();



                              setState(() {});



                            },







                            child: CustomPaint(



                              size: Size(

                                pieceSize,

                                pieceSize,

                              ),



                              painter:

                              PuzzlePainter(



                                piece: piece,



                                image:

                                AssetImage(

                                  widget.level.image,

                                ),



                                cachedImage:

                                image,



                              ),



                            ),



                          ),



                        );





                      }).toList(),



                    ),



                  ),



                ),



              ),



            ),







            const SizedBox(

              height: 20,

            ),



            //========================================
            // لوحة تركيب البازل
            //========================================


            Expanded(



              child: Center(



                child: Container(



                  key: boardKey,



                  width: boardSize,



                  height: boardSize,



                  decoration: BoxDecoration(



                    color:

                    Colors.white.withOpacity(0.06),




                    borderRadius:

                    BorderRadius.circular(18),




                    border:

                    Border.all(

                      color:

                      Colors.white24,

                      width: 2,

                    ),



                  ),







                  child: ClipRRect(



                    borderRadius:

                    BorderRadius.circular(18),




                    child: Stack(



                      children: [





                        //================================
                        // صورة الخلفية الخفيفة
                        //================================


                        Opacity(



                          opacity: 0.07,



                          child: Image.asset(



                            widget.level.image,



                            width: boardSize,



                            height: boardSize,



                            fit: BoxFit.cover,



                          ),



                        ),







                        //================================
                        // قطع البازل داخل اللوحة
                        //================================


                        ...pieces.map((piece){





                          if(piece.state ==

                              PieceState.tray){



                            return const SizedBox();



                          }







                          return Positioned(



                            left:

                            piece.position.dx -

                                boardOffset.dx,





                            top:

                            piece.position.dy -

                                boardOffset.dy,







                            child: GestureDetector(



                              onPanStart:

                                  (details){



                                controller.pointerDown(

                                  details.globalPosition,

                                );



                                setState(() {});



                              },







                              onPanUpdate:

                                  (details){



                                controller.pointerMove(

                                  details.globalPosition,

                                );



                                setState(() {});



                              },







                              onPanEnd:

                                  (_){



                                controller.pointerUp();



                                checkWin();



                                setState(() {});



                              },







                              child: CustomPaint(



                                size: Size(



                                  pieceSize,



                                  pieceSize,



                                ),



                                painter:

                                PuzzlePainter(



                                  piece: piece,



                                  image:

                                  AssetImage(

                                    widget.level.image,

                                  ),



                                  cachedImage:

                                  image,



                                ),



                              ),



                            ),



                          );





                        }).toList(),






                      ],

                    ),



                  ),



                ),



              ),



            ),



          ],



        ),



      ),



    );



  }



}