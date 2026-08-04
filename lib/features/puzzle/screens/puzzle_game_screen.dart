import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import '../engine/puzzle_controller.dart';
import '../engine/puzzle_painter.dart';
import '../engine/tray_controller.dart';
import '../models/puzzle_level_model.dart';
import '../models/puzzle_model.dart';
import '../managers/reward_manager.dart';
import '../managers/puzzle_progress_manager.dart';

import '../widgets/game_toolbar.dart';
import '../widgets/flying_coin.dart';
import 'victory_screen.dart';
import 'puzzle_win_screen.dart';
import '../services/reward_ad_service.dart';
import 'package:audioplayers/audioplayers.dart';

class PuzzleGameScreen extends StatefulWidget {
  final PuzzleLevelModel level;
  final PuzzleModel island;

  const PuzzleGameScreen({
    super.key,
    required this.level,
    required this.island,
  });

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  ui.Image? image;

  late PuzzleController controller;

  bool loading = true;

  bool puzzleCreated = false;
  bool gameFinished = false;
  bool checkingSavedGame = true;
  bool soundEnabled = true;

  Map<String, dynamic>? savedGameData;

  late Stopwatch stopwatch;

  int lastPlacedCount = 0;
  int moves = 0;

  Offset? coinAnimationStart;
  bool showCoinAnimation = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  final double boardSize = 350;
  final double trayHeight = 110;

  final TrayController trayController = TrayController();
  bool trayDragging = false;

  final GlobalKey overlayKey = GlobalKey();
  final GlobalKey boardKey = GlobalKey();
  final GlobalKey trayKey = GlobalKey();

  Rect boardRect = Rect.zero;
  Rect scatterArea = Rect.zero;

  final GlobalKey starKey = GlobalKey();
  final GlobalKey gemKey = GlobalKey();
  final GlobalKey coinKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    stopwatch = Stopwatch();
    _checkSavedGame();
  }

  Future<void> _checkSavedGame() async {
    final saved = await PuzzleProgressManager.loadProgress();

    if (saved != null && saved["levelId"] == widget.level.id) {
      savedGameData = saved;

      if (!mounted) return;

      final resume = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              "توجد لعبة محفوظة",
            ),
            content: const Text(
              "هل تريد الاستمرار في اللعبة السابقة؟",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    false,
                  );
                },
                child: const Text(
                  "لعبة جديدة",
                ),
              ),
              TextButton(
                onPressed: () async {
                  final result = await RewardAdService.showContinueAd();

                  if (!context.mounted) return;

                  Navigator.pop(
                    context,
                    result,
                  );
                },
                child: const Text(
                  "استمرار",
                ),
              ),
            ],
          );
        },
      );

      if (resume != true) {
        await PuzzleProgressManager.clearProgress();
        savedGameData = null;
      }
    }

    if (!mounted) return;

    setState(() {
      checkingSavedGame = false;
    });

    _loadImage();
  }

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

          WidgetsBinding.instance.addPostFrameCallback((_) {
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

  void _calculateBoardPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final overlayContext = overlayKey.currentContext;
      final boardContext = boardKey.currentContext;
      final trayContext = trayKey.currentContext;

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

      final RenderBox overlayBox = overlayContext.findRenderObject() as RenderBox;
      final RenderBox boardBox = boardContext.findRenderObject() as RenderBox;
      final RenderBox trayBox = trayContext.findRenderObject() as RenderBox;

      final boardLocal = overlayBox.globalToLocal(
        boardBox.localToGlobal(
          Offset.zero,
        ),
      );

      final trayLocal = overlayBox.globalToLocal(
        trayBox.localToGlobal(
          Offset.zero,
        ),
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

      _createPuzzle();
    });
  }

  void _createPuzzle() {
    if (image == null || puzzleCreated) {
      return;
    }

    puzzleCreated = true;

    controller = PuzzleController(
      snapTolerance: 28,
    );

    controller.initialize(
      image: image!,
      rows: widget.level.gridSize,
      cols: widget.level.gridSize,
      boardRect: boardRect,
      scatterArea: scatterArea,
    );

    if (savedGameData != null) {
      controller.restoreProgress(
        savedGameData!,
      );
      lastPlacedCount = controller.pieces.where((p) => p.isPlaced).length;
    }

    setState(() {});

    final totalWidth = controller.pieces.fold<double>(
      0,
      (sum, piece) => sum + piece.localBounds.width + 12,
    );

    trayController.setBounds(
      contentWidth: totalWidth,
      viewportWidth: scatterArea.width,
    );

    if (!stopwatch.isRunning) {
      stopwatch.start();
    }
  }

  Future<void> saveCurrentGame() async {
    if (!puzzleCreated) return;

    await PuzzleProgressManager.saveProgress(
      puzzleId: widget.island.id,
      levelId: widget.level.id,
      pieces: controller.pieces,
      moves: moves,
      seconds: stopwatch.elapsed.inSeconds,
    );
  }

  Future<void> restartGame() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("إعادة اللعبة"),
          content: const Text("هل تريد إعادة اللعبة من البداية؟"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("لا"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("نعم"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    if (puzzleCreated) {
      controller.dispose();
    }

    savedGameData = null;

    setState(() {
      puzzleCreated = false;
      gameFinished = false;
      moves = 0;
      lastPlacedCount = 0;
    });

    stopwatch
      ..reset()
      ..start();

    _calculateBoardPosition();
  }

  bool _isTouchingPiece(Offset position) {
    controller.trayOffset = trayController.offsetX;

    for (final piece in controller.pieces) {
      if (!piece.isPlaced &&
          piece.containsPoint(
            position,
            trayController.offsetX,
          )) {
        return true;
      }
    }

    return false;
  }

  Future<void> checkWin() async {
    if (gameFinished) {
      return;
    }

    if (!controller.isSolved) {
      return;
    }

    gameFinished = true;
    stopwatch.stop();

    await RewardManager.completePuzzle(
      rewardKey: widget.level.id,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => VictoryScreen(
          puzzleImage: image!,
          pieces: controller.pieces,
          boardRect: controller.boardRect,
          rows: widget.level.gridSize,
          cols: widget.level.gridSize,
          island: widget.island,
          levelNumber: widget.level.levelNumber,
          isFinalLevel: widget.level.levelNumber == 10,
          starTargetKey: starKey,
          gemTargetKey: gemKey,
          onStarEarned: () {
            RewardManager.addStars(1);
          },
          onGemEarned: () {
            RewardManager.addGems(1);
          },
          onFinished: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => VictoryScreen(
                  currentIsland: widget.island,
                  currentLevel: widget.level.levelNumber,
                  starsEarned: 1,
                  gemEarned: widget.level.levelNumber == 10,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (checkingSavedGame || image == null || loading) {
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
              Color(0xffD8C7A5),
              Color(0xffF3E7CF),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            key: overlayKey,
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 70,
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      child: Center(
                        child: Container(
                          key: boardKey,
                          width: boardSize,
                          height: boardSize,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.35),
                                blurRadius: 25,
                                spreadRadius: 2,
                              ),
                            ],
                            border: Border.all(
                              color: Colors.white.withOpacity(0.18),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Opacity(
                              opacity: 0.18,
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
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  Container(
                    key: trayKey,
                    height: trayHeight,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),

              Positioned(
                top: 0,
                left: 8,
                right: 8,
                child: GameToolbar(
                  starKey: starKey,
                  gemKey: gemKey,
                  coinKey: coinKey,
                  soundEnabled: soundEnabled,
                  onSave: () async {
                    await saveCurrentGame();

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("تم الحفظ بنجاح"),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  onRestart: () {
                    restartGame();
                  },
                  onExit: () async {
                    await saveCurrentGame();
                    stopwatch.stop();

                    if (!mounted) return;

                    Navigator.pop(context);
                  },
                  onSoundChanged: (enabled) {
                    setState(() {
                      soundEnabled = enabled;
                    });
                    _audioPlayer.setVolume(enabled ? 1 : 0);
                  },
                ),
              ),

              if (showCoinAnimation && coinAnimationStart != null)
                FlyingCoin(
                  start: coinAnimationStart!,
                  end: Offset(
                    MediaQuery.of(context).size.width - 50,
                    35,
                  ),
                  onFinished: () {
                    setState(() {
                      showCoinAnimation = false;
                    });
                  },
                ),

              if (puzzleCreated)
                Positioned.fill(
                  child: GestureDetector(
                    onPanStart: (details) {
                      final position = details.localPosition;

                      if (_isTouchingPiece(position)) {
                        trayDragging = false;
                        controller.trayOffset = trayController.offsetX;
                        controller.onPanStart(position);
                      } else {
                        trayDragging = true;
                        trayController.startDrag(
                          position.dx,
                        );
                      }
                    },
                    onPanUpdate: (details) {
                      if (trayDragging) {
                        trayController.updateDrag(
                          details.localPosition.dx,
                        );
                      } else {
                        controller.onPanUpdate(
                          details.localPosition,
                        );
                      }
                    },
                    onPanEnd: (_) async {
                      if (trayDragging) {
                        trayDragging = false;
                      } else {
                        controller.onPanEnd();

                        if (controller.lastPlacedPosition != null) {
                          moves++;
                        }

                        await Future.delayed(
                          const Duration(milliseconds: 100),
                        );

                        if (!mounted) return;

                        final placedCount = controller.pieces
                            .where((p) => p.isPlaced)
                            .length;

                        if (placedCount > lastPlacedCount) {
                          lastPlacedCount = placedCount;

                          await _audioPlayer.play(
                            AssetSource(
                              'audio/piece_correct.mp3',
                            ),
                          );

                          await RewardManager.addCoins(1);

                          if (mounted &&
                              controller.lastPlacedPosition != null) {
                            setState(() {
                              coinAnimationStart =
                                  controller.lastPlacedPosition;
                              showCoinAnimation = true;
                            });
                          }
                        }

                        await checkWin();
                      }
                    },
                    child: CustomPaint(
                      painter: PuzzlePainter(
  pieces: controller.pieces,
  image: image!,
  boardRect: controller.boardRect,
  scatterArea: scatterArea,
  rows: widget.level.gridSize,
  cols: widget.level.gridSize,
  trayOffset: trayController.offsetX,
  repaint: Listenable.merge([
    controller,
    trayController,
  ]),
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
    _audioPlayer.dispose();

    if (puzzleCreated && !gameFinished) {
      PuzzleProgressManager.saveProgress(
        puzzleId: widget.island.id,
        levelId: widget.level.id,
        pieces: controller.pieces,
        moves: moves,
        seconds: stopwatch.elapsed.inSeconds,
      );
    }

    if (puzzleCreated) {
      controller.dispose();
    }
    trayController.dispose();
    super.dispose();
  }
}
