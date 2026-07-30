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
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  String get assetPath => widget.level.image;

  final Random _random = Random();

  late PuzzleController controller;
  late AssetImage puzzleImage;

  List<PuzzlePiece> pieces = [];
  ui.Image? image;

  bool loading = true;
  bool gameReady = false;
  bool completed = false;

  final double boardSize = 300;

  double get pieceSize => boardSize / widget.level.gridSize;

  /// المسافة التي نُزحزح بها القطعة بصرياً حتى لا تُقص tabs
  double get pieceVisualInset => pieceSize * 0.18;

  /// الحجم الفعلي الذي يرسمه PuzzlePieceWidget داخلياً
  double get pieceWidgetSize => pieceSize + (pieceSize * 0.36);

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

      _scatterPiecesOnTop();

      if (!mounted) return;

      setState(() {
        loading = false;
        gameReady = true;
      });
    } catch (e, stack) {
      debugPrint("PUZZLE ERROR: $e");
      debugPrint(stack.toString());

      if (!mounted) return;

      setState(() {
        loading = false;
        gameReady = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("خطأ: $e"),
        ),
      );
    }
  }

  void _scatterPiecesOnTop() {
    final maxX = (boardSize - pieceSize).clamp(0.0, boardSize);
    final topAreaHeight = boardSize * 0.28;
    final maxY = (topAreaHeight - pieceSize).clamp(0.0, boardSize);

    for (final piece in pieces) {
      piece.position = Offset(
        _random.nextDouble() * maxX,
        _random.nextDouble() * (maxY == 0 ? 1 : maxY),
      );
    }
  }

  Future<ui.Image> loadImage(String path) async {
    final completer = Completer<ui.Image>();

    final stream = AssetImage(path).resolve(
      const ImageConfiguration(),
    );

    late ImageStreamListener listener;

    listener = ImageStreamListener(
      (ImageInfo info, bool _) {
        if (!completer.isCompleted) {
          completer.complete(info.image);
        }
        stream.removeListener(listener);
      },
      onError: (error, stack) {
        completer.completeError(error, stack);
        stream.removeListener(listener);
      },
    );

    stream.addListener(listener);
    return completer.future;
  }

  void movePiece(
    PuzzlePiece piece,
    DragUpdateDetails details,
  ) {
    if (piece.placed || !gameReady) {
      return;
    }

    setState(() {
      piece.position += details.delta;

      piece.position = Offset(
        piece.position.dx.clamp(
          0,
          boardSize - pieceSize,
        ),
        piece.position.dy.clamp(
          0,
          boardSize - pieceSize,
        ),
      );
    });
  }

  void dropPiece(
    PuzzlePiece piece,
  ) {
    if (piece.placed) {
      return;
    }

    final correct = controller.checkPiecePosition(
      piece,
      pieceSize,
    );

    if (correct) {
      setState(() {
        piece.placed = true;
      });
    } else {
      setState(() {});
    }

    if (controller.isCompleted && !completed) {
      completed = true;
      showWinDialog();
    }
  }

  void showWinDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("🎉 أحسنت"),
          content: const Text("أكملت البازل"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("ممتاز"),
            ),
          ],
        );
      },
    );
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
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: Text(widget.level.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // لوحة واحدة فقط: الصورة + القطع + أماكن التركيب في نفس المكان
              Container(
                width: boardSize,
                height: boardSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // صورة الخلفية كمرجع خفيف
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.22,
                        child: Image(
                          image: puzzleImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // القطع كلها في نفس اللوحة
                    ...pieces.map((piece) {
                      final left = piece.position.dx - pieceVisualInset;
                      final top = piece.position.dy - pieceVisualInset;

                      return Positioned(
                        left: left,
                        top: top,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            movePiece(piece, details);
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
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (controller.isCompleted)
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    "اكتملت الصورة بنجاح",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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
    super.dispose();
  }
}