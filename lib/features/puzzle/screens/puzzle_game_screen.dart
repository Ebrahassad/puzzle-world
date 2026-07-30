import 'dart:async';
import 'dart:math';
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

  String get assetPath => widget.level.image;

  late PuzzleController controller;

  late AssetImage puzzleImage;

  ui.Image? image;

  List<PuzzlePiece> pieces = [];

  bool loading = true;
  bool gameReady = false;
  bool completed = false;

  PuzzlePiece? selectedPiece;

  double boardSize = 0;

  double get pieceSize =>
      boardSize / widget.level.gridSize;

  @override
  void initState() {
    super.initState();

    puzzleImage = AssetImage(assetPath);

    loadGame();
  }

  Future<void> loadGame() async {
    try {
      image = await loadImage(assetPath);

      pieces = PuzzleGenerator.generate(
        rows: widget.level.gridSize,
        columns: widget.level.gridSize,
        imageWidth: image!.width.toDouble(),
        imageHeight: image!.height.toDouble(),
      );

      controller = PuzzleController(
        pieces: pieces,
      );

      if (!mounted) return;

      setState(() {
        loading = false;
        gameReady = true;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  Future<ui.Image> loadImage(
      String path,
      ) async {

    final completer =
        Completer<ui.Image>();

    final stream =
        AssetImage(path).resolve(
      const ImageConfiguration(),
    );

    late ImageStreamListener listener;

    listener = ImageStreamListener(

      (info, _) {

        completer.complete(info.image);

        stream.removeListener(listener);

      },

      onError: (error, stack) {

        completer.completeError(
          error,
          stack,
        );

        stream.removeListener(listener);

      },

    );

    stream.addListener(listener);

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!gameReady) {
      return const Scaffold(
        body: Center(
          child: Text("تعذر فتح المرحلة"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xff0E2A47),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff0E2A47),
        centerTitle: true,
        title: Text(widget.level.title),
      ),

      body: SafeArea(
        child: Column(

          children: [

            const SizedBox(height: 12),

            //==================================
            // شريط القطع
            //==================================

            SizedBox(
              height: pieceWidgetSize + 24,

              child: ListView.builder(

                scrollDirection: Axis.horizontal,

                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                ),

                itemCount: pieces.length,

                itemBuilder: (context, index) {

                  final piece = pieces[index];

                  if (piece.placed) {
                    return const SizedBox(width: 6);
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                    ),

                    child: GestureDetector(

                      onPanUpdate: (details) {
                        movePiece(piece, details);
                      },

                      onPanEnd: (_) {
                        dropPiece(piece);
                      },

                      child: AnimatedScale(

                        duration: const Duration(
                          milliseconds: 180,
                        ),

                        scale: 1,

                        child: PuzzlePieceWidget(

                          piece: piece,

                          image: puzzleImage,

                          size: pieceSize,

                        ),

                      ),

                    ),

                  );

                },

              ),

            ),

            const SizedBox(height: 16),

            Expanded(

              child: Center(

                child: Container(

                  width: boardSize,

                  height: boardSize,

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius: BorderRadius.circular(24),

                    boxShadow: const [

                      BoxShadow(
                        blurRadius: 20,
                        color: Colors.black26,
                        offset: Offset(0, 8),
                      ),

                    ],

                  ),

                  child: Stack(

                    clipBehavior: Clip.none,

                    children: [

                      Positioned.fill(

                        child: Opacity(

                          opacity: 0.15,

                          child: Image(
                            image: puzzleImage,
                            fit: BoxFit.cover,
                          ),

                        ),

                      ),
                      //==================================
                      // القطع التي تم تثبيتها
                      //==================================

                      ...pieces.where((p) => p.placed).map(

                        (piece) {

                          return Positioned(

                            left: piece.correctPosition.dx,

                            top: piece.correctPosition.dy,

                            child: PuzzlePieceWidget(

                              piece: piece,

                              image: puzzleImage,

                              size: pieceSize,

                            ),

                          );

                        },

                      ),

                      //==================================
                      // القطعة التي يتم سحبها
                      //==================================

                      ...pieces.where((p) => !p.placed).map(

                        (piece) {

                          return Positioned(

                            left: piece.position.dx,

                            top: piece.position.dy,

                            child: GestureDetector(

                              onPanUpdate: (details) {

                                movePiece(
                                  piece,
                                  details,
                                );

                              },

                              onPanEnd: (_) {

                                dropPiece(piece);

                              },

                              child: PuzzlePieceWidget(

                                piece: piece,

                                image: puzzleImage,

                                size: pieceSize,

                              ),

                            ),

                          );

                        },

                      ),

                    ],

                  ),

                ),

              ),

            ),

            if (controller.isCompleted)

              const Padding(

                padding: EdgeInsets.symmetric(
                  vertical: 20,
                ),

                child: Text(

                  "🎉 اكتملت الصورة بنجاح",

                  style: TextStyle(

                    color: Colors.white,

                    fontSize: 20,

                    fontWeight: FontWeight.bold,

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