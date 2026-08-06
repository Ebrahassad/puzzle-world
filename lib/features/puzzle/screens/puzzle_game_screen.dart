import 'dart:ui' as ui;
import 'dart:async';
import 'dart:io'; // <--- أضفنا هذه المكتبة لقراءة ملفات الصور المحلية من الجهاز
import 'package:flutter/material.dart';

import '../engine/puzzle_controller.dart';
import '../engine/puzzle_painter.dart';
import '../models/puzzle_level_model.dart';
import '../models/puzzle_model.dart';
import '../managers/reward_manager.dart';
import '../managers/puzzle_progress_manager.dart';

import '../data/puzzle_level_data.dart';

import '../widgets/game_toolbar.dart';
import '../widgets/flying_coin.dart';
import '../widgets/floating_regroup_button.dart';
import 'victory_screen.dart';

import '../services/reward_ad_service.dart';
import 'package:audioplayers/audioplayers.dart';

class PuzzleGameScreen extends StatefulWidget {
  final PuzzleLevelModel? level; // جعلناه اختياري لكي يدعم الصور المخصصة
  final PuzzleModel island;
  final String? customImagePath; // مسار الصورة المخصصة من الاستوديو
  final bool isCustomImage; // علامة لتحديد ما إذا كانت صورة مخصصة

  const PuzzleGameScreen({
    super.key,
    this.level,
    required this.island,
    this.customImagePath,
    this.isCustomImage = false,
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

  Timer? _regroupTimer;

  bool showRegroupButton = false;

  Map<String, dynamic>? savedGameData;

  late Stopwatch stopwatch;

  int lastPlacedCount = 0;
  int moves = 0;

  Offset? coinAnimationStart;
  bool showCoinAnimation = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  final double boardSize = 350;
  final double trayHeight = 110;

  final GlobalKey overlayKey = GlobalKey();
  final GlobalKey boardKey = GlobalKey();
  final GlobalKey trayKey = GlobalKey();

  Rect boardRect = Rect.zero;
  Rect scatterArea = Rect.zero;

  final GlobalKey starKey = GlobalKey();
  final GlobalKey gemKey = GlobalKey();
  final GlobalKey coinKey = GlobalKey();

  // الحصول على عدد شبكة القطع (نفس حجم آخر مرحلة أو حجم افتراضي للصور المخصصة مثل 3x3 أو 4x4)
  int get gridSize {
    if (widget.isCustomImage) {
      return 3; // يمكنك تعديل عدد القطع للصور المخصصة حسب رغبتك (مثلاً 3 أو 4)
    }
    return widget.level?.gridSize ?? 3;
  }

  String get currentLevelId {
    if (widget.isCustomImage) {
      return "custom_image_puzzle";
    }
    return widget.level!.id;
  }

  @override
  void initState() {
    super.initState();

    stopwatch = Stopwatch();

    if (widget.isCustomImage) {
      // الصور المخصصة لا تحتاج فحص حفظ قديم، نبدأ تحميلها فوراً
      setState(() {
        checkingSavedGame = false;
      });
      _loadImage();
    } else {
      _checkSavedGame();
    }

    _startRegroupHelper();
  }

  Future<void> _checkSavedGame() async {
    if (widget.level == null) return;
    final saved = await PuzzleProgressManager.loadProgress();

    if (saved != null && saved["levelId"] == widget.level!.id) {
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
    ImageProvider provider;

    if (widget.isCustomImage && widget.customImagePath != null) {
      // تحميل الصورة من مسار ملف الهاتف المحلي
      provider = FileImage(File(widget.customImagePath!));
    } else {
      // تحميل الصورة العادية للمرحلة من الأصول
      provider = AssetImage(widget.level!.image);
    }

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
          debugPrint("IMAGE ERROR");

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

  Offset? getCoinTargetPosition() {
    final context = coinKey.currentContext;

    if (context == null) return null;

    final box = context.findRenderObject() as RenderBox;

    final global = box.localToGlobal(
      box.size.center(Offset.zero),
    );

    final overlayBox =
        overlayKey.currentContext!.findRenderObject() as RenderBox;

    return overlayBox.globalToLocal(global);
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
      rows: gridSize,
      cols: gridSize,
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

    if (!stopwatch.isRunning) {
      stopwatch.start();
    }
  }

  Future<void> saveCurrentGame() async {
    if (!puzzleCreated || widget.isCustomImage) return;

    await PuzzleProgressManager.saveProgress(
      puzzleId: widget.island.id,
      levelId: currentLevelId,
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

  Future<void> checkWin() async {
    if (gameFinished) {
      return;
    }

    if (!controller.isSolved) {
      return;
    }

    gameFinished = true;
    stopwatch.stop();

    if (!widget.isCustomImage && widget.level != null) {
      await RewardManager.completePuzzle(
        rewardKey: widget.level!.id,
      );
    }

    if (!mounted) return;

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, animation, secondaryAnimation) {
          return VictoryScreen(
            puzzleImage: image!,
            rows: gridSize,
            cols: gridSize,
            boardRect: boardRect,
            island: widget.island,
            levelNumber: widget.isCustomImage ? 10 : widget.level!.levelNumber,
            isFinalLevel: true,
            starTargetKey: starKey,
            onFinished: () {
              Navigator.pop(context);
            },
            onNext: () {
              Navigator.pop(context);
              Navigator.pop(context); // العودة للخريطة في حال الصورة المخصصة
            },
            onMap: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            onReplay: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PuzzleGameScreen(
                    level: widget.level,
                    island: widget.island,
                    customImagePath: widget.customImagePath,
                    isCustomImage: widget.isCustomImage,
                  ),
                ),
              );
            },
          );
        },
        transitionsBuilder: (_, animation, __, child) {
          return child;
        },
      ),
    );
  }

  void _startRegroupHelper() {
    Future.delayed(
      const Duration(minutes: 1),
      () {
        if (!mounted || gameFinished) return;

        _showRegroupButton();

        _regroupTimer = Timer.periodic(
          const Duration(seconds: 60),
          (_) {
            if (!mounted || gameFinished) return;

            _showRegroupButton();
          },
        );
      },
    );
  }

  void _showRegroupButton() {
    if (!mounted || gameFinished) return;

    setState(() {
      showRegroupButton = true;
    });

    Future.delayed(
      const Duration(seconds: 20),
      () {
        if (!mounted || gameFinished) return;

        setState(() {
          showRegroupButton = false;
        });
      },
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
          color: Color(0xFFE8E1F3),
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
                            color: const Color(0xFFDCCFEA),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.35),
                                blurRadius: 25,
                                spreadRadius: 2,
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xFFF7F2FD),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Opacity(
                              opacity: 0.18,
                              child: widget.isCustomImage && widget.customImagePath != null
                                  ? Image.file(
                                      File(widget.customImagePath!),
                                      width: boardSize,
                                      height: boardSize,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      widget.level!.image,
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
                      color: const Color(0xFFDCCFEA),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFFF7F2FD),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),

              if (showCoinAnimation && coinAnimationStart != null)
                Builder(
                  builder: (context) {
                    final target = getCoinTargetPosition();

                    if (target == null) {
                      return const SizedBox.shrink();
                    }

                    return FlyingCoin(
                      start: coinAnimationStart!,
                      end: target,
                      onFinished: () async {
                        await RewardManager.addCoins(1);

                        if (!mounted) return;

                        setState(() {
                          showCoinAnimation = false;
                        });
                      },
                    );
                  },
                ),

              if (puzzleCreated)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onPanStart: (details) {
                      controller.onPanStart(details.localPosition);
                    },
                    onPanUpdate: (details) {
                      controller.onPanUpdate(details.localPosition);
                    },
                    onPanEnd: (_) async {
                      controller.onPanEnd();

                      moves++;

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

                        if (controller.lastPlacedPosition != null) {
                          final RenderBox overlayBox =
                              overlayKey.currentContext!.findRenderObject() as RenderBox;

                          final start = overlayBox.localToGlobal(
                            controller.lastPlacedPosition!,
                          );

                          final localStart = overlayBox.globalToLocal(start);

                          setState(() {
                            coinAnimationStart = localStart;
                            showCoinAnimation = true;
                          });
                        }
                      }

                      await checkWin();
                    },
                    child: CustomPaint(
                      painter: PuzzlePainter(
                        pieces: controller.pieces,
                        image: image!,
                        boardRect: controller.boardRect,
                        rows: gridSize,
                        cols: gridSize,
                        repaint: controller,
                      ),
                    ),
                  ),
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

              if (showRegroupButton)
                FloatingRegroupButton(
                  onPressed: () {
                    controller.regroupPieces();

                    setState(() {
                      showRegroupButton = false;
                    });
                  },
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
    _regroupTimer?.cancel();

    if (puzzleCreated && !gameFinished && !widget.isCustomImage) {
      PuzzleProgressManager.saveProgress(
        puzzleId: widget.island.id,
        levelId: currentLevelId,
        pieces: controller.pieces,
        moves: moves,
        seconds: stopwatch.elapsed.inSeconds,
      );
    }

    if (puzzleCreated) {
      controller.dispose();
    }
    super.dispose();
  }
}
