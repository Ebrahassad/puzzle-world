import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../engine/puzzle_controller.dart';
import '../engine/puzzle_painter.dart';
import 'puzzle_win_screen.dart';
import '../models/game_result_model.dart';
import '../models/puzzle_level_model.dart';




class PuzzleGameScreen extends StatefulWidget {
  final PuzzleLevelModel level;

  const PuzzleGameScreen({
    super.key,
    required this.level,
  });

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  ui.Image? image;

  late PuzzleController controller;

  bool loading = true;

  bool puzzleCreated = false;

  final double boardSize = 360;

  final double trayHeight = 110;

  final GlobalKey overlayKey = GlobalKey();

  final GlobalKey boardKey = GlobalKey();

  final GlobalKey trayKey = GlobalKey();

  Rect boardRect = Rect.zero;

  Rect scatterArea = Rect.zero;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  //==================================================
  // تحميل الصورة فقط
  //==================================================

  Future<void> _loadImage() async {
    final provider = AssetImage(
      widget.level.image,
    );

    final stream = provider.resolve(
      const ImageConfiguration(),
    );

    debugPrint(
      "START LOAD: ${widget.level.image}",
    );

    stream.addListener(
      ImageStreamListener(
        (info, _) {
          if (!mounted) {
            return;
          }

          image = info.image;

          setState(() {
            loading = false;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _calculateBoardPosition();
          });
        },
        onError: (error, stack) {
          debugPrint(
            "IMAGE ERROR: ${widget.level.image}",
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
  // حساب مكان اللوحة وشريط القطع
  //==================================================

  void _calculateBoardPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final overlayContext = overlayKey.currentContext;
      final boardContext = boardKey.currentContext;
      final trayContext = trayKey.currentContext;

      if (overlayContext == null ||
          boardContext == null ||
          trayContext == null) {
        debugPrint(
          "BOARD NOT READY",
        );

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
          overlayContext.findRenderObject() as RenderBox;

      final RenderBox boardBox =
          boardContext.findRenderObject() as RenderBox;

      final RenderBox trayBox =
          trayContext.findRenderObject() as RenderBox;

      final boardLocal = overlayBox.globalToLocal(
        boardBox.localToGlobal(Offset.zero),
      );

      final trayLocal = overlayBox.globalToLocal(
        trayBox.localToGlobal(Offset.zero),
      );

      boardRect = Rect.fromLTWH(
        boardLocal.dx,
        boardLocal.dy,
        boardSize,
        boardSize,
      );

      scatterArea = Rect.fromLTWH(
        trayLocal.dx,
        trayLocal.dy,
        trayBox.size.width,
        trayBox.size.height,
      );

      debugPrint(
        "BOARD RECT = $boardRect",
      );

      _createPuzzle();
    });
  }

  //==================================================
  // إنشاء قطع البازل فقط
  //==================================================

  void _createPuzzle() {
    if (image == null || puzzleCreated) {
      return;
    }

    puzzleCreated = true;

    controller = PuzzleController(snapTolerance: 28);

    controller.initialize(
      image: image!,
      rows: widget.level.gridSize,
      cols: widget.level.gridSize,
      boardRect: boardRect,
      scatterArea: scatterArea,
    );

    debugPrint(
      "PUZZLE PIECES = ${controller.pieces.length}",
    );

    setState(() {});
  }

  //==================================================
  // تحقق من الفوز
  //==================================================

  void checkWin() {
  if (!controller.isSolved) {
    return;
  }

  Future.delayed(
    const Duration(milliseconds: 500),
    () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PuzzleWinScreen(
            result: GameResultModel(
              moves: controller.moves,
              seconds: controller.seconds,
              stars: 3,
            ),
            difficulty: widget.level.gridSize,
            worldId: widget.level.worldId,
            level: widget.level.levelNumber,
          ),
        ),
      );
    },
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
      backgroundColor: const Color(0xff18354f),
      body: SafeArea(
        child: Stack(
          key: overlayKey,
          children: [
            Column(
              children: [
                const SizedBox(
                  height: 12,
                ),

                //==============================
                // شريط القطع
                //==============================

                Container(
                  key: trayKey,
                  height: trayHeight,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white24,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                //==============================
                // لوحة البازل
                //==============================

                Expanded(
                  child: Center(
                    child: Container(
                      key: boardKey,
                      width: boardSize,
                      height: boardSize,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white24,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
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

            //==============================
            // طبقة رسم وسحب القطع الموحدة
            //==============================

            if (puzzleCreated)
              Positioned.fill(
                child: GestureDetector(
                  onPanStart: (details) {
                    controller.onPanStart(details.localPosition);
                  },
                  onPanUpdate: (details) {
                    controller.onPanUpdate(details.localPosition);
                  },
                  onPanEnd: (_) {
                    controller.onPanEnd();
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
