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

    stream.addListener(

      ImageStreamListener(

        (info, _) {

          image = info.image;

          _createPuzzle();

        },

      ),

    );

  }

  //==================================================
  // إنشاء القطع
  //==================================================

  void _createPuzzle() {

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

    );

    controller = PuzzleController(
      pieces: pieces,
    );

    setState(() {

      loading = false;

    });

  }

  //==================================================
  // تحقق من الفوز
  //==================================================

  void checkWin() {

    if (!controller.isCompleted) {
      return;
    }

    Future.delayed(

      const Duration(milliseconds: 400),

      () {

        if (mounted) {
          Navigator.pop(context);
        }

      },

    );

  }

  @override
  Widget build(BuildContext context) {

    if (loading || image == null) {

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

      backgroundColor: const Color(0xff18354f),

      body: SafeArea(

        child: Column(

          children: [

            const SizedBox(height: 12),

            //========================================
            // شريط القطع (سيتم ربطه بالمحرك لاحقاً)
            //========================================

            Container(

              height: trayHeight,

              margin: const EdgeInsets.symmetric(
                horizontal: 12,
              ),

              decoration: BoxDecoration(

                color: Colors.black26,

                borderRadius:
                    BorderRadius.circular(16),

                border: Border.all(
                  color: Colors.white24,
                ),

              ),

            ),

            const SizedBox(height: 20),

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

                    border: Border.all(

                      color: Colors.white24,

                      width: 2,

                    ),

                  ),

                  child: ClipRRect(

                    borderRadius:
                        BorderRadius.circular(18),

                    child: Stack(

                      children: [

                        Opacity(

                          opacity: 0.07,

                          child: Image.asset(

                            widget.level.image,

                            width: boardSize,

                            height: boardSize,

                            fit: BoxFit.cover,

                          ),

                        ),

                        const SizedBox.expand(),

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