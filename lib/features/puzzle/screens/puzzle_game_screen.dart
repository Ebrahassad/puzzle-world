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
  }
