import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../engine/puzzle_controller.dart';
import '../engine/puzzle_painter.dart';
import '../models/puzzle_level_model.dart';
import '../models/game_result_model.dart';

import '../widgets/game_toolbar.dart';

import 'puzzle_result_animation_screen.dart';


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



class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  ui.Image? image;


  late PuzzleController controller;


  bool loading = true;


  bool puzzleCreated = false;

int moves = 0;

late Stopwatch stopwatch;

  //==============================
  // صورة الفوز
  //==============================

  



  final double boardSize = 360;


  final double trayHeight = 110;



  final GlobalKey overlayKey = GlobalKey();


  final GlobalKey boardKey = GlobalKey();


  final GlobalKey trayKey = GlobalKey();



  Rect boardRect = Rect.zero;


  Rect scatterArea = Rect.zero;


final GlobalKey starKey = GlobalKey();

final GlobalKey coinKey = GlobalKey();


  //==============================
  // بداية الشاشة
  //==============================

  @override
  void initState() {

    super.initState();

stopwatch = Stopwatch()..start();
    


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


    stream.addListener(
      ImageStreamListener(
        (info, _) {

          if (!mounted) return;


          image = info.image;


          setState(() {
            loading = false;
          });


          WidgetsBinding.instance
              .addPostFrameCallback((_) {

            _calculateBoardPosition();

          });

        },

        onError: (error, stack) {

          debugPrint(
            "IMAGE ERROR ${widget.level.image}",
          );


          if (mounted) {

            setState(() {
              loading = false;
            });

          }

        },
      ),
    );

  }







  //==================================================
  // حساب أماكن اللوحة والشريط
  //==================================================

  void _calculateBoardPosition() {


    WidgetsBinding.instance
        .addPostFrameCallback((_) {


      if (!mounted) return;



      final overlayContext =
          overlayKey.currentContext;


      final boardContext =
          boardKey.currentContext;


      final trayContext =
          trayKey.currentContext;



      if (overlayContext == null ||
          boardContext == null ||
          trayContext == null) {


        Future.delayed(
          const Duration(milliseconds: 100),
              () {

            if (mounted) {
              _calculateBoardPosition();
            }

          },
        );


        return;

      }





      final RenderBox overlayBox =
          overlayContext.findRenderObject()
          as RenderBox;



      final RenderBox boardBox =
          boardContext.findRenderObject()
          as RenderBox;



      final RenderBox trayBox =
          trayContext.findRenderObject()
          as RenderBox;





      final boardLocal =
          overlayBox.globalToLocal(
            boardBox.localToGlobal(
              Offset.zero,
            ),
          );



      final trayLocal =
          overlayBox.globalToLocal(
            trayBox.localToGlobal(
              Offset.zero,
            ),
          );




      boardRect =
          Rect.fromLTWH(
            boardLocal.dx,
            boardLocal.dy,
            boardSize,
            boardSize,
          );



      scatterArea =
          Rect.fromLTWH(
            trayLocal.dx,
            trayLocal.dy,
            trayBox.size.width,
            trayBox.size.height,
          );



      _createPuzzle();


    });

  }







  //==================================================
  // إنشاء البازل
  //==================================================

  void _createPuzzle() {


    if (image == null || puzzleCreated) {
      return;
    }



    puzzleCreated = true;



    controller =
        PuzzleController(
          snapTolerance: 28,
        );



    controller.initialize(
      image: image!,
      rows: widget.level.gridSize,
      cols: widget.level.gridSize,
      boardRect: boardRect,
      scatterArea: scatterArea,
    );



    setState(() {});


  }







  //==================================================
  // فحص الفوز
  //==================================================

  void checkWin() {

  if (!controller.isSolved) {
    return;
  }
stopwatch.stop();

  Navigator.pushReplacement(

    context,

    MaterialPageRoute(

      builder: (_) => PuzzleResultAnimationScreen(

        image: widget.level.image,

        starKey: starKey,

        level: widget.level,

        result: GameResultModel(
  stars: 3,
  moves: moves,
  time: stopwatch.elapsed,
),

      ),

    ),

  );

}


  @override
  Widget build(BuildContext context) {


    if (image == null || loading) {

      return const Scaffold(

        body: Center(

          child: CircularProgressIndicator(),

        ),

      );

    }




    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(

          gradient: LinearGradient(

            begin: Alignment.topCenter,

            end: Alignment.bottomCenter,

            colors: [

              Color(0xff10283d),

              Color(0xff1c4966),

            ],

          ),

        ),




        child: SafeArea(

          child: Stack(

            key: overlayKey,

            children: [




              //==========================================
              // Game Toolbar
              //==========================================

              Positioned(

                top: 8,

                left: 8,

                right: 8,

                child: GameToolbar(

                  starKey: starKey,

                  coinKey: coinKey,

                ),

              ),






              Column(

                children: [


                  const SizedBox(

                    height: 75,

                  ),





                  //==========================================
                  // شريط القطع
                  //==========================================

                  Container(

                    key: trayKey,

                    height: trayHeight,


                    margin: const EdgeInsets.symmetric(

                      horizontal: 12,

                    ),



                    decoration: BoxDecoration(


                      color: Colors.white.withOpacity(0.08),


                      borderRadius:
                      BorderRadius.circular(22),



                      boxShadow: [


                        BoxShadow(

                          color:
                          Colors.black.withOpacity(0.25),

                          blurRadius: 20,

                          offset:
                          const Offset(0,8),

                        ),


                      ],



                      border: Border.all(

                        color:
                        Colors.white.withOpacity(0.15),

                      ),


                    ),


                  ),





                  const SizedBox(

                    height: 20,

                  ),





                  //==========================================
                  // لوحة البازل
                  //==========================================

                  Expanded(

                    child: Center(


                      child: Container(

                        key: boardKey,


                        width: boardSize,

                        height: boardSize,



                        decoration: BoxDecoration(


                          color:
                          Colors.white.withOpacity(0.05),



                          borderRadius:
                          BorderRadius.circular(24),



                          boxShadow: [


                            BoxShadow(

                              color:
                              Colors.black.withOpacity(0.35),

                              blurRadius: 25,

                              spreadRadius: 2,

                            ),


                          ],



                          border: Border.all(

                            color:
                            Colors.white.withOpacity(0.18),

                            width: 2,

                          ),


                        ),





                        child: ClipRRect(


                          borderRadius:
                          BorderRadius.circular(18),



                          child: Opacity(


                            opacity: 0.07,



                            child: Image.asset(

                              widget.level.image,


                              width: boardSize,

                              height: boardSize,


                              fit: BoxFit.cover,

                            ),


                          ),


                        ),


                      ),


                    ),


                  ),


                ],

              ),




            //==========================================
              // طبقة رسم وسحب القطع
              // (لم يتم تعديل منطق اللعب)
              //==========================================

              if (puzzleCreated)

                Positioned.fill(

                  child: GestureDetector(

                    onPanStart: (details) {

                      controller.onPanStart(
                        details.localPosition,
                      );

                    },


                    onPanUpdate: (details) {

                      controller.onPanUpdate(
                        details.localPosition,
                      );

                    },


                    onPanEnd: (_) {

                      controller.onPanEnd();

moves++;

checkWin();
                    },


                    child: CustomPaint(

                      painter: PuzzlePainter(

                        pieces: controller.pieces,

                        image: image!,


                        boardRect: controller.boardRect,


                        rows: widget.level.gridSize,


                        cols: widget.level.gridSize,


                        repaint: controller,

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






  @override
  void dispose() {


    if (puzzleCreated) {

      controller.dispose();

    }


    


    super.dispose();


  }


}