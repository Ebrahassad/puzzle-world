import 'dart:async';
import 'dart:math' as math;
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



  // القطعة أثناء السحب
  PuzzlePiece? draggingPiece;



  // موضع السحب الحالي
  Offset dragPosition = Offset.zero;



  // مكان لوحة البازل
  Offset boardPosition = Offset.zero;



  final GlobalKey boardKey = GlobalKey();



  bool _boardPositionReady = false;



  double get boardSize {
    final size = MediaQuery.of(context).size;
    return size.width * 0.90;
  }



  double get pieceSize =>
      boardSize / widget.level.gridSize;



  // حجم الشريط يبقى ثابت تقريباً حتى في المراحل المتقدمة
  double get trayPieceSize {
    return math.max(
      92,
      math.min(
        118,
        boardSize * 0.26,
      ),
    );
  }



  double get trayHeight {
    final topPadding = MediaQuery.of(context).padding.top;
    return trayPieceSize + 44 + topPadding;
  }



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
      imageWidth: image!.width.toDouble(),
      imageHeight: image!.height.toDouble(),
    );

    controller = PuzzleController(
      pieces: pieces,
    );

    preparePieces();

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateBoardPosition();
    });
  }



  Future<ui.Image> loadImage(
    String path,
  ) async {
    final completer = Completer<ui.Image>();

    final stream = AssetImage(path).resolve(
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
      onError: (error, stackTrace) {
        completer.completeError(
          error,
          stackTrace,
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



  void preparePieces() {
    pieces.shuffle();

    for (final piece in pieces) {
      piece.position = Offset.zero;
      piece.placed = false;
      piece.dragOffset = null;
    }
  }



  //=========================================
  // تحديث موقع لوحة البازل
  //=========================================

  void updateBoardPosition() {
    final renderBox = boardKey.currentContext?.findRenderObject()
        as RenderBox?;

    if (renderBox != null) {
      boardPosition = renderBox.localToGlobal(
        Offset.zero,
      );

      _boardPositionReady = true;
    }
  }



  //=========================================
  // بداية سحب القطعة
  //=========================================

  void startDrag(
    PuzzlePiece piece,
    Offset globalPosition,
  ) {
    if (piece.placed) return;

    updateBoardPosition();

    controller.startDragging(piece);

    final currentPieceSize =
        piece.placed ? pieceSize : trayPieceSize;

    if (piece.position == Offset.zero) {
      piece.dragOffset = Offset(
        currentPieceSize / 2,
        currentPieceSize / 2,
      );
    } else {
      final currentTopLeftGlobal =
          boardPosition + piece.position;

      piece.dragOffset =
          globalPosition - currentTopLeftGlobal;
    }

    setState(() {
      draggingPiece = piece;
      dragPosition = globalPosition;
    });
  }



  //=========================================
  // تحريك القطعة
  //=========================================

  void updateDrag(
    DragUpdateDetails details,
  ) {
    if (draggingPiece == null) return;

    final piece = draggingPiece!;

    setState(() {
      dragPosition += details.delta;

      final anchor = piece.dragOffset ??
          Offset(
            trayPieceSize / 2,
            trayPieceSize / 2,
          );

      final topLeftGlobal = dragPosition - anchor;

      piece.position = topLeftGlobal - boardPosition;
    });
  }



  //=========================================
  // نهاية السحب
  //=========================================

  void endDrag() {
    if (draggingPiece == null) return;

    final piece = draggingPiece!;

    updateBoardPosition();

    final currentPieceSize =
        piece.placed ? pieceSize : trayPieceSize;

    final topLeftGlobal = boardPosition + piece.position;

    final centerGlobal = topLeftGlobal +
        Offset(
          currentPieceSize / 2,
          currentPieceSize / 2,
        );

    final inTrayArea = centerGlobal.dy <= trayHeight;

    final correct = controller.checkPiecePosition(
      piece,
      pieceSize,
    );

    setState(() {
      if (correct) {
        piece.dragOffset = null;
      } else if (inTrayArea && !piece.placed) {
        piece.position = Offset.zero;
        piece.dragOffset = null;
        controller.unlockPiece(piece);
      }

      draggingPiece = null;
      controller.endDragging(piece);
    });

    checkComplete();
  }



  void checkComplete() {
    if (controller.isCompleted && !completed) {
      completed = true;

      Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
        () {
          if (!mounted) return;

          showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: const Text(
                  "🎉 أحسنت",
                ),
                content: const Text(
                  "اكتملت الصورة",
                ),
              );
            },
          );
        },
      );
    }
  }



  bool _isFreeOverlayPiece(PuzzlePiece piece) {
    return !piece.placed &&
        piece.position != Offset.zero &&
        draggingPiece != piece;
  }



  Widget _buildTrayPiece(
    PuzzlePiece piece,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        startDrag(
          piece,
          details.globalPosition,
        );
      },
      onPanUpdate: updateDrag,
      onPanEnd: (_) {
        endDrag();
      },
      child: AnimatedScale(
        duration: const Duration(
          milliseconds: 160,
        ),
        curve: Curves.easeOutCubic,
        scale: draggingPiece == piece ? 1.08 : 1.0,
        child: PuzzlePieceWidget(
          piece: piece,
          image: puzzleImage,
          size: trayPieceSize,
          isActive: draggingPiece == piece,
        ),
      ),
    );
  }



  Widget _buildFreeOverlayPiece(
    PuzzlePiece piece,
  ) {
    final topLeft = boardPosition + piece.position;

    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: (details) {
          startDrag(
            piece,
            details.globalPosition,
          );
        },
        onPanUpdate: updateDrag,
        onPanEnd: (_) {
          endDrag();
        },
        child: AnimatedScale(
          duration: const Duration(
            milliseconds: 160,
          ),
          curve: Curves.easeOutCubic,
          scale: draggingPiece == piece ? 1.10 : 1.0,
          child: PuzzlePieceWidget(
            piece: piece,
            image: puzzleImage,
            size: trayPieceSize,
            isActive: draggingPiece == piece,
          ),
        ),
      ),
    );
  }



  Widget _buildPlacedPiece(
    PuzzlePiece piece,
  ) {
    return Positioned(
      left: piece.column * pieceSize,
      top: piece.row * pieceSize,
      child: PuzzlePieceWidget(
        piece: piece,
        image: puzzleImage,
        size: pieceSize,
        isActive: false,
      ),
    );
  }



  Widget _buildBoard() {
    return Container(
      key: boardKey,
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 25,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.10,
                  child: Image.asset(
                    widget.level.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            ...pieces
                .where((p) => p.placed)
                .map(_buildPlacedPiece),
          ],
        ),
      ),
    );
  }



  Widget _buildTray() {
    final trayItems = pieces.where((piece) {
      return !piece.placed &&
          piece.position == Offset.zero &&
          draggingPiece != piece;
    }).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      height: trayHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
        ),
        itemCount: trayItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return SizedBox(
            width: trayPieceSize + 10,
            child: Center(
              child: _buildTrayPiece(
                trayItems[index],
              ),
            ),
          );
        },
      ),
    );
  }



  Widget _buildDraggingOverlay() {
    final piece = draggingPiece!;
    final currentSize = piece.placed ? pieceSize : trayPieceSize;
    final anchor = piece.dragOffset ??
        Offset(
          currentSize / 2,
          currentSize / 2,
        );

    final topLeft = dragPosition - anchor;

    return Positioned(
      left: topLeft.dx,
      top: topLeft.dy,
      child: IgnorePointer(
        child: AnimatedScale(
          duration: const Duration(
            milliseconds: 120,
          ),
          curve: Curves.easeOutCubic,
          scale: 1.10,
          child: PuzzlePieceWidget(
            piece: piece,
            image: puzzleImage,
            size: piece.placed ? pieceSize : trayPieceSize,
            isActive: true,
          ),
        ),
      ),
    );
  }



  @override
  Widget build(
    BuildContext context,
  ) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_boardPositionReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateBoardPosition();
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xff10233d),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTray(),

                const SizedBox(
                  height: 12,
                ),

                Expanded(
                  child: Center(
                    child: _buildBoard(),
                  ),
                ),
              ],
            ),

            ...pieces.where(_isFreeOverlayPiece).map(
              _buildFreeOverlayPiece,
            ),

            if (draggingPiece != null)
              _buildDraggingOverlay(),
          ],
        ),
      ),
    );
  }



  @override
  void dispose() {
    draggingPiece = null;
    super.dispose();
  }
}