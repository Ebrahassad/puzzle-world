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


  // حالة قطع البازل
  late List<PuzzlePiece> pieces;


  // التحكم بحركة وفحص القطع
  late PuzzleController controller;



  // المؤقت
  Timer? timer;



  // عدد الحركات
  int moves = 0;


  // الوقت بالثواني
  int seconds = 0;


  // عدد التلميحات
  int hints = 0;



  // حالة التحميل
  bool loading = true;


  // منع التكرار عند الفوز
  bool finishing = false;



  // حجم لوحة اللعب
  final double boardSize = 350;



  // حجم القطعة
  double get pieceSize =>
      boardSize / widget.level.gridSize;





  @override
  void initState() {

    super.initState();

    createGame();

  }







  // إنشاء لعبة جديدة

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

    // تحميل تقدم اللاعب

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



        moves =
            saved["moves"] ?? 0;


        seconds =
            saved["seconds"] ?? 0;



      } else {


        // حذف المرحلة المحفوظة والبدء من جديد

        await PuzzleProgressManager
            .clearProgress();


      }


    }



    await loadHints();



    if(mounted) {

      setState(() {

        loading = false;

      });

    }



    startTimer();


  }







  // تحميل عدد التلميحات

  Future<void> loadHints() async {


    final value =
        await PuzzleHintManager.getHints();



    if(!mounted) return;



    setState(() {

      hints = value;

    });


  }







  // نافذة متابعة اللعبة المحفوظة

  Future<bool> showContinueDialog() async {


    final result =
        await showDialog<bool>(

      context: context,

      barrierDismissible: false,


      builder:(context) {


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



                if(context.mounted) {


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



                if(watched && context.mounted) {


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
  
  // تشغيل عداد الوقت

  void startTimer() {


    timer?.cancel();



    timer = Timer.periodic(

      const Duration(seconds: 1),

          (_) {


        if(!mounted || finishing) {

          return;

        }



        setState(() {

          seconds++;

        });


      },

    );


  }







  // حفظ تقدم اللعبة

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

  // وضع قطعة البازل في مكانها

  Future<void> dropPiece(

      PuzzlePiece piece,

      Offset globalPosition,

      ) async {


    if(piece.placed || finishing) {

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





    setState(() {


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







  // فحص انتهاء المرحلة

  void checkCompleted() {


    if(controller.isCompleted && !finishing) {


      finishGame();


    }


  }







  // استخدام تلميح

  Future<void> usePuzzleHint() async {


    if(finishing) {

      return;

    }



    bool available =

    await PuzzleHintManager.consumeHint();





    if(!available) {


      final watched =

      await RewardAdService.showRewardAd();




      if(watched) {


        await PuzzleHintManager.addHints(3);


        available = true;


      }


    }





    if(!available) {

      return;

    }





    final piece =

    PuzzleHintManager.findAvailablePiece(

      pieces,

    );





    if(piece == null) {

      return;

    }





    setState(() {


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

  // إنهاء المرحلة

  Future<void> finishGame() async {


    if(finishing) {

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



    if(!mounted) {

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

);

  }







  @override
  void dispose() {


    timer?.cancel();


    super.dispose();


  }

  @override
  Widget build(BuildContext context) {


    if(loading) {

      return const Scaffold(

        body: Center(

          child: CircularProgressIndicator(),

        ),

      );

    }



    return Scaffold(

      backgroundColor: Colors.blue.shade50,


      appBar: AppBar(

        title: Text(

          widget.level.title,

        ),

        centerTitle: true,


      ),



      body: Column(

        children: [



          const SizedBox(height: 15),




          // معلومات المرحلة

          Row(

            mainAxisAlignment:

            MainAxisAlignment.spaceEvenly,

            children: [


              Text(

                "🧩 الحركات: $moves",

                style: const TextStyle(

                  fontSize: 18,

                  fontWeight: FontWeight.bold,

                ),

              ),



              Text(

                "⏱ $seconds",

                style: const TextStyle(

                  fontSize: 18,

                  fontWeight: FontWeight.bold,

                ),

              ),



              TextButton(

                onPressed: usePuzzleHint,

                child: Text(

                  "💡 $hints",

                  style: const TextStyle(

                    fontSize: 18,

                  ),

                ),

              ),


            ],

          ),





          const SizedBox(height: 15),





          // لوحة البازل

          SizedBox(

            width: boardSize,

            height: boardSize,


            child: Stack(


              children: pieces.map((piece) {

return PuzzlePieceWidget(

  key: ValueKey(piece.id),

  piece: piece,

  image: AssetImage(
    widget.puzzle.image,
  ),

  size: pieceSize,

);        

              }).cast<Widget>().toList(),


            ),

          ),





          const SizedBox(height: 20),





          ElevatedButton.icon(

            onPressed: () async {


              await saveGame();



              if(context.mounted) {


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


            icon: const Icon(

              Icons.save,

            ),


            label: const Text(

              "حفظ اللعبة",

            ),


          ),



        ],

      ),

    );


  }


}
