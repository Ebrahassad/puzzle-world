import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../engine/puzzle_controller.dart';
import '../engine/puzzle_painter.dart';

import '../models/puzzle_level_model.dart';
import '../models/puzzle_model.dart';

import '../managers/reward_manager.dart';
import '../managers/puzzle_progress_manager.dart';
import '../managers/ads_manager.dart';

import '../data/puzzle_level_data.dart';

import '../widgets/game_toolbar.dart';
import '../widgets/flying_coin.dart';
import '../widgets/floating_regroup_button.dart';

import 'victory_screen.dart';
import 'world_map_screen.dart';

class PuzzleGameScreen extends StatefulWidget {
  final PuzzleLevelModel? level;
  final PuzzleModel? island;

  final String? customImagePath;
  final bool isCustomImage;
  final int? customGridSize;

  const PuzzleGameScreen({
    super.key,
    this.level,
    this.island,
    this.customImagePath,
    this.isCustomImage = false,
    this.customGridSize,
  });

  @override
  State<PuzzleGameScreen> createState() =>
      _PuzzleGameScreenState();
}

class _PuzzleGameScreenState
    extends State<PuzzleGameScreen> {
  // ============================================================
  // 🖼️ الصورة
  // ============================================================

  ui.Image? image;

  late PuzzleController controller;

  bool loading = true;
  bool puzzleCreated = false;
  bool gameFinished = false;
  bool checkingSavedGame = true;

  bool soundEnabled = true;
  bool showBoardImage = true;

  // ============================================================
  // 🔀 إعادة التجميع
  // ============================================================

  Timer? _regroupTimer;

  bool showRegroupButton = false;

  // ============================================================
  // 💾 الحفظ
  // ============================================================

  Map<String, dynamic>? savedGameData;

  late Stopwatch stopwatch;

  int savedSeconds = 0;

  int lastPlacedCount = 0;
  int moves = 0;

  // ============================================================
  // 🪙 العملة
  // ============================================================

  Offset? coinAnimationStart;

  bool showCoinAnimation = false;

  // ============================================================
  // 🔊 الصوت
  // ============================================================

  final AudioPlayer _audioPlayer =
      AudioPlayer();

  // ============================================================
  // 📐 أحجام اللعبة
  // ============================================================

  final double boardSize = 350;
  final double trayHeight = 110;

  // ============================================================
  // 🔑 Keys
  // ============================================================

  final GlobalKey overlayKey =
      GlobalKey();

  final GlobalKey boardKey =
      GlobalKey();

  final GlobalKey trayKey =
      GlobalKey();

  final GlobalKey starKey =
      GlobalKey();

  final GlobalKey gemKey =
      GlobalKey();

  final GlobalKey coinKey =
      GlobalKey();

  // ============================================================
  // 📍 مواقع اللعبة
  // ============================================================

  Rect boardRect = Rect.zero;

  Rect scatterArea = Rect.zero;

  // ============================================================
  // 🔢 حجم الشبكة
  // ============================================================

  int get gridSize {
    // ----------------------------------------------------------
    // 🏝️ الجزيرة الخاصة
    // ----------------------------------------------------------

    if (widget.isCustomImage) {
      final savedSize =
          savedGameData?["customGridSize"];

      if (savedSize is num &&
          savedSize.toInt() >= 2) {
        return savedSize.toInt();
      }

      return widget.customGridSize ?? 3;
    }

    // ----------------------------------------------------------
    // 🌍 المراحل العادية
    // ----------------------------------------------------------

    return widget.level?.gridSize ?? 3;
  }

  // ============================================================
  // 🆔 معرف المرحلة
  // ============================================================

  String get currentLevelId {
    if (widget.isCustomImage) {
      return "custom_image_puzzle";
    }

    return widget.level!.id;
  }

  // ============================================================
  // 🆔 معرف البازل العادي
  // ============================================================

  String get normalPuzzleId {
    return widget.island?.id ??
        "unknown_island";
  }

  // ============================================================
  // 🏝️ معرف الجزيرة الخاصة
  // ============================================================

  static const String customPuzzleId =
      "custom_island";

  // ============================================================
  // ⏱️ الوقت
  // ============================================================

  int get currentElapsedSeconds {
    return savedSeconds +
        stopwatch.elapsed.inSeconds;
  }

  // ============================================================
  // 🏁 آخر مرحلة في الجزيرة
  // ============================================================

  bool get isFinalLevelOfIsland {
    if (widget.isCustomImage) {
      return false;
    }

    if (widget.level == null ||
        widget.island == null) {
      return false;
    }

    final levels =
        PuzzleLevelData.getLevels(
      widget.island!.id,
    );

    return widget.level!.levelNumber ==
        levels.length;
  }

  // ============================================================
  // 🏝️ فتح الجزيرة التالية
  // ============================================================

  Future<void>
      _unlockNextIslandIfNeeded() async {
    if (!isFinalLevelOfIsland) {
      return;
    }

    if (widget.island == null) {
      return;
    }

    await PuzzleProgressManager
        .unlockNextIsland(
      widget.island!.id,
    );
  }

  // ============================================================
  // 🗺️ العودة لخريطة العالم
  // ============================================================

  void _returnToWorldMap() {
    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const WorldMapScreen(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // 🚀 INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    stopwatch = Stopwatch();

    _checkSavedGame();

    _startRegroupHelper();
  }

  // ============================================================
  // 💾 حذف حفظ الجزيرة الخاصة
  // ============================================================
  //
  // مهم:
  // لا نستخدم SharedPreferences هنا.
  //
  // الجزيرة الخاصة لديها نظام حفظ مستقل داخل
  // PuzzleProgressManager.
  // ============================================================

  Future<void>
      _clearCustomSavedGame() async {
    await PuzzleProgressManager
        .clearPrivateIslandGameState();
  }

  // ============================================================
  // 💾 فحص حفظ الجزيرة الخاصة
  // ============================================================

  Future<void>
      _checkCustomSavedGame() async {
    final saved =
        await PuzzleProgressManager
            .loadPrivateIslandGameState();

    // ----------------------------------------------------------
    // لا يوجد حفظ
    // ----------------------------------------------------------

    if (saved == null ||
        saved.isEmpty) {
      savedGameData = null;
      return;
    }

    final savedPuzzleId =
        saved["puzzleId"];

    final savedLevelId =
        saved["levelId"];

    final savedImagePath =
        saved["customImagePath"];

    // ----------------------------------------------------------
    // التأكد أن الحفظ:
    //
    // 1. للجزيرة الخاصة
    // 2. لنفس اللعبة
    // 3. لنفس الصورة
    // ----------------------------------------------------------

    final isSameGame =
        savedPuzzleId ==
                customPuzzleId &&
            savedLevelId ==
                currentLevelId &&
            savedImagePath ==
                widget.customImagePath;

    if (!isSameGame) {
      savedGameData = null;
      return;
    }

    savedGameData = saved;

    if (!mounted) {
      return;
    }

    // ----------------------------------------------------------
    // سؤال المستخدم عن استكمال اللعبة
    // ----------------------------------------------------------

    final resume =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
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
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                "لعبة جديدة",
              ),
            ),
            TextButton(
              onPressed: () {
                AdsManager()
                    .showRewardedAd(
                  onRewardEarned: () {
                    if (!dialogContext.mounted) {
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },
                  onAdFailed: () {
                    if (!dialogContext.mounted) {
                      return;
                    }

                    // الإعلان غير متوفر،
                    // يسمح بالاستمرار مباشرة.
                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },
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

    // ----------------------------------------------------------
    // 🆕 لعبة جديدة
    // ----------------------------------------------------------

    if (resume != true) {
      await _clearCustomSavedGame();

      savedGameData = null;
    }
  }

  // ============================================================
  // 💾 فحص حفظ البازل العادي
  // ============================================================

  Future<void>
      _checkNormalSavedGame() async {
    final saved =
        await PuzzleProgressManager
            .loadProgress();

    if (saved == null) {
      savedGameData = null;
      return;
    }

    final samePuzzle =
        saved["puzzleId"] ==
            normalPuzzleId;

    final sameLevel =
        saved["levelId"] ==
            currentLevelId;

    if (!samePuzzle || !sameLevel) {
      savedGameData = null;
      return;
    }

    savedGameData = saved;

    if (!mounted) {
      return;
    }

    final resume =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
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
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                "لعبة جديدة",
              ),
            ),
            TextButton(
              onPressed: () {
                AdsManager()
                    .showRewardedAd(
                  onRewardEarned: () {
                    if (!dialogContext.mounted) {
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },
                  onAdFailed: () {
                    if (!dialogContext.mounted) {
                      return;
                    }

                    Navigator.pop(
                      dialogContext,
                      true,
                    );
                  },
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
      await PuzzleProgressManager
          .clearProgress();

      savedGameData = null;
    }
  }

  // ============================================================
  // 💾 فحص الحفظ
  // ============================================================

  Future<void> _checkSavedGame() async {
    // ----------------------------------------------------------
    // 🏝️ الجزيرة الخاصة
    // ----------------------------------------------------------

    if (widget.isCustomImage) {
      await _checkCustomSavedGame();

      if (!mounted) {
        return;
      }

      setState(() {
        checkingSavedGame = false;
      });

      _loadImage();

      return;
    }

    // ----------------------------------------------------------
    // 🌍 المراحل العادية
    // ----------------------------------------------------------

    if (widget.level == null) {
      if (!mounted) {
        return;
      }

      setState(() {
        checkingSavedGame = false;
      });

      return;
    }

    await _checkNormalSavedGame();

    if (!mounted) {
      return;
    }

    setState(() {
      checkingSavedGame = false;
    });

    _loadImage();
  }

  // ============================================================
  // 🖼️ تحميل الصورة
  // ============================================================

  Future<void> _loadImage() async {
    late ImageProvider provider;

    if (widget.isCustomImage &&
        widget.customImagePath != null) {
      provider = FileImage(
        File(
          widget.customImagePath!,
        ),
      );
    } else {
      provider = AssetImage(
        widget.level!.image,
      );
    }

    final stream = provider.resolve(
      const ImageConfiguration(),
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

          WidgetsBinding.instance
              .addPostFrameCallback(
            (_) {
              _calculateBoardPosition();
            },
          );
        },
        onError: (error, stack) {
          debugPrint(
            "IMAGE ERROR: $error",
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

  // ============================================================
  // 📐 حساب مكان اللوحة والصينية
  // ============================================================

  void _calculateBoardPosition() {
    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

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
            const Duration(
              milliseconds: 100,
            ),
            () {
              if (mounted) {
                _calculateBoardPosition();
              }
            },
          );

          return;
        }

        final RenderBox overlayBox =
            overlayContext
                    .findRenderObject()
                as RenderBox;

        final RenderBox boardBox =
            boardContext
                    .findRenderObject()
                as RenderBox;

        final RenderBox trayBox =
            trayContext
                    .findRenderObject()
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
      },
    );
  }

  // ============================================================
  // 🪙 مكان وصول العملة
  // ============================================================

  Offset? getCoinTargetPosition() {
    final context =
        coinKey.currentContext;

    if (context == null) {
      return null;
    }

    final box =
        context.findRenderObject()
            as RenderBox;

    final global =
        box.localToGlobal(
      box.size.center(
        Offset.zero,
      ),
    );

    final overlayContext =
        overlayKey.currentContext;

    if (overlayContext == null) {
      return null;
    }

    final overlayBox =
        overlayContext.findRenderObject()
            as RenderBox;

    return overlayBox.globalToLocal(
      global,
    );
  }

  // ============================================================
  // 🧩 إنشاء البازل
  // ============================================================

  void _createPuzzle() {
    if (image == null ||
        puzzleCreated) {
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

    // ----------------------------------------------------------
    // 💾 استرجاع الحفظ
    // ----------------------------------------------------------

    if (savedGameData != null) {
      controller.restoreProgress(
        savedGameData!,
      );

      lastPlacedCount =
          controller.pieces
              .where(
                (p) => p.isPlaced,
              )
              .length;

      moves =
          savedGameData!["moves"] is num
              ? (savedGameData!["moves"]
                      as num)
                  .toInt()
              : 0;

      savedSeconds =
          savedGameData!["seconds"] is num
              ? (savedGameData!["seconds"]
                      as num)
                  .toInt()
              : 0;

      stopwatch
        ..reset()
        ..start();
    } else {
      savedSeconds = 0;

      stopwatch
        ..reset()
        ..start();
    }

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // 💾 بناء بيانات الحفظ
  // ============================================================

  Map<String, dynamic> _buildSaveData() {
    return {
      "puzzleId":
          widget.isCustomImage
              ? customPuzzleId
              : normalPuzzleId,

      "levelId":
          currentLevelId,

      "moves":
          moves,

      "seconds":
          currentElapsedSeconds,

      "pieces":
          controller.pieces.map((piece) {
        return {
          "id": piece.id,
          "row": piece.row,
          "column": piece.col,
          "x":
              piece.currentPosition.dx,
          "y":
              piece.currentPosition.dy,
          "placed":
              piece.isPlaced,
        };
      }).toList(),

      // --------------------------------------------------------
      // 🏝️ بيانات الجزيرة الخاصة
      // --------------------------------------------------------

      if (widget.isCustomImage &&
          widget.customImagePath != null)
        "customImagePath":
            widget.customImagePath,

      if (widget.isCustomImage)
        "customGridSize":
            gridSize,
    };
  }

  // ============================================================
  // 💾 حفظ الجزيرة الخاصة
  // ============================================================

  Future<void> _saveCustomGame() async {
    if (!puzzleCreated ||
        gameFinished) {
      return;
    }

    final state =
        _buildSaveData();

    // ----------------------------------------------------------
    // 🏝️ نظام الجزيرة الخاصة فقط
    // ----------------------------------------------------------

    await PuzzleProgressManager
        .savePrivateIslandGameState(
      state,
    );

    // ----------------------------------------------------------
    // 🖼️ حفظ مسار الصورة في نظام الجزيرة الخاصة
    // ----------------------------------------------------------

    if (widget.customImagePath != null) {
      await PuzzleProgressManager
          .savePrivateIslandImagePath(
        widget.customImagePath!,
      );
    }
  }

  // ============================================================
  // 💾 حفظ المرحلة العادية
  // ============================================================

  Future<void> _saveNormalGame() async {
    if (!puzzleCreated ||
        gameFinished) {
      return;
    }

    await PuzzleProgressManager
        .saveProgress(
      puzzleId:
          normalPuzzleId,
      levelId:
          currentLevelId,
      pieces:
          controller.pieces,
      moves:
          moves,
      seconds:
          currentElapsedSeconds,
    );
  }

  // ============================================================
  // 💾 الحفظ العام
  // ============================================================

  Future<void> saveCurrentGame() async {
    if (!puzzleCreated ||
        gameFinished) {
      return;
    }

    if (widget.isCustomImage) {
      await _saveCustomGame();
    } else {
      await _saveNormalGame();
    }
  }

  // ============================================================
  // 🗑️ حذف الحفظ الحالي
  // ============================================================

  Future<void>
      _clearCurrentSavedGame() async {
    if (widget.isCustomImage) {
      await PuzzleProgressManager
          .clearPrivateIslandGameState();
    } else {
      await PuzzleProgressManager
          .clearProgress();
    }
  }

  // ============================================================
  // 🔄 إعادة اللعبة
  // ============================================================

  Future<void> restartGame() async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "إعادة اللعبة",
          ),
          content: const Text(
            "هل تريد إعادة اللعبة من البداية؟",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                "لا",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                "نعم",
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    // ----------------------------------------------------------
    // إيقاف البازل الحالي
    // ----------------------------------------------------------

    if (puzzleCreated) {
      controller.dispose();
    }

    savedGameData = null;

    // ----------------------------------------------------------
    // حذف الحفظ فقط
    //
    // لا نحذف صورة الجزيرة الخاصة.
    // ----------------------------------------------------------

    await _clearCurrentSavedGame();

    if (!mounted) {
      return;
    }

    setState(() {
      puzzleCreated = false;
      gameFinished = false;

      moves = 0;
      savedSeconds = 0;
      lastPlacedCount = 0;

      showBoardImage = true;
    });

    stopwatch
      ..reset()
      ..start();

    _calculateBoardPosition();
  }

  // ============================================================
  // ➡️ فتح المرحلة التالية
  // ============================================================

  void openNextLevel() {
    if (widget.isCustomImage) {
      return;
    }

    if (widget.level == null ||
        widget.island == null) {
      return;
    }

    if (isFinalLevelOfIsland) {
      _returnToWorldMap();
      return;
    }

    final currentNumber =
        widget.level!.levelNumber;

    final nextLevel =
        PuzzleLevelData.getLevels(
      widget.island!.id,
    ).firstWhere(
      (level) =>
          level.levelNumber ==
          currentNumber + 1,
      orElse: () =>
          widget.level!,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PuzzleGameScreen(
          level: nextLevel,
          island: widget.island,
        ),
      ),
    );
  }

  // ============================================================
  // 🏆 الفوز
  // ============================================================

  Future<void> checkWin() async {
    if (gameFinished) {
      return;
    }

    if (!controller.isSolved) {
      return;
    }

    gameFinished = true;

    stopwatch.stop();

    // ----------------------------------------------------------
    // 🧹 حذف الحفظ المناسب فقط
    // ----------------------------------------------------------

    if (widget.isCustomImage) {
      // 🏝️ الجزيرة الخاصة
      await PuzzleProgressManager
          .clearPrivateIslandGameState();

      // 🖼️ حذف الصورة المرتبطة باللعبة
      await PuzzleProgressManager
          .clearPrivateIslandImage();
    } else {
      // 🌍 البازل العادي
      await PuzzleProgressManager
          .clearProgress();
    }

    // ----------------------------------------------------------
    // 🏆 إكمال المرحلة العادية
    // ----------------------------------------------------------

    if (!widget.isCustomImage) {
      await PuzzleProgressManager
          .completeLevel(
        currentLevelId,
      );
    }

    // ----------------------------------------------------------
    // 🔓 فتح التالي
    // ----------------------------------------------------------

    if (isFinalLevelOfIsland) {
      await _unlockNextIslandIfNeeded();
    } else if (!widget.isCustomImage) {
      await PuzzleProgressManager
          .unlockNextLevel(
        widget.island!.id,
        widget.level!.levelNumber,
      );
    }

    if (mounted) {
      setState(() {
        showBoardImage = false;
      });
    }

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor:
            Colors.transparent,
        pageBuilder:
            (_, animation, secondaryAnimation) {
          return VictoryScreen(
            puzzleImage: image!,
            rows: gridSize,
            cols: gridSize,
            boardRect: boardRect,
            island: widget.island,
            levelNumber:
                widget.isCustomImage
                    ? 10
                    : widget.level!
                        .levelNumber,
            isFinalLevel:
                isFinalLevelOfIsland,
            starTargetKey:
                starKey,
            pieces:
                controller.pieces,

            onFinished: () {
              Navigator.pop(
                context,
              );

              if (isFinalLevelOfIsland) {
                Future.delayed(
                  const Duration(
                    milliseconds: 100,
                  ),
                  () {
                    if (!mounted) {
                      return;
                    }

                    _returnToWorldMap();
                  },
                );
              }
            },

            onNext: () async {
              Navigator.pop(
                context,
              );

              await Future.delayed(
                const Duration(
                  milliseconds: 100,
                ),
              );

              if (!mounted) {
                return;
              }

              if (isFinalLevelOfIsland) {
                _returnToWorldMap();
              } else {
                openNextLevel();
              }
            },

            onMap: () {
              _returnToWorldMap();
            },

            onReplay: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PuzzleGameScreen(
                    level:
                        widget.level,
                    island:
                        widget.island,
                    customImagePath:
                        widget.customImagePath,
                    isCustomImage:
                        widget.isCustomImage,
                    customGridSize:
                        widget.customGridSize,
                  ),
                ),
              );
            },
          );
        },
        transitionsBuilder:
            (_, animation, __, child) {
          return child;
        },
      ),
    );
  }

  // ============================================================
  // 🔀 مساعد إعادة التجميع
  // ============================================================

  void _startRegroupHelper() {
    Future.delayed(
      const Duration(
        minutes: 1,
      ),
      () {
        if (!mounted ||
            gameFinished) {
          return;
        }

        _showRegroupButton();

        _regroupTimer =
            Timer.periodic(
          const Duration(
            seconds: 60,
          ),
          (_) {
            if (!mounted ||
                gameFinished) {
              return;
            }

            _showRegroupButton();
          },
        );
      },
    );
  }

  void _showRegroupButton() {
    if (!mounted ||
        gameFinished) {
      return;
    }

    setState(() {
      showRegroupButton = true;
    });

    Future.delayed(
      const Duration(
        seconds: 20,
      ),
      () {
        if (!mounted ||
            gameFinished) {
          return;
        }

        setState(() {
          showRegroupButton = false;
        });
      },
    );
  }

  // ============================================================
  // 🎨 BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    if (checkingSavedGame ||
        image == null ||
        loading) {
      return const Directionality(
        textDirection:
            TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child:
                CircularProgressIndicator(),
          ),
        ),
      );
    }

    return Directionality(
      textDirection:
          TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration:
              const BoxDecoration(
            color:
                Color(0xFFE8E1F3),
          ),
          child: SafeArea(
            child: Stack(
              key: overlayKey,
              children: [
                // ==================================================
                // BOARD + TRAY
                // ==================================================

                Column(
                  children: [
                    const SizedBox(
                      height: 70,
                    ),

                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 8,
                        ),
                        child: Center(
                          child: Container(
                            key:
                                boardKey,
                            width:
                                boardSize,
                            height:
                                boardSize,
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFFDCCFEA,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                24,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors
                                      .black
                                      .withOpacity(
                                    0.35,
                                  ),
                                  blurRadius:
                                      25,
                                  spreadRadius:
                                      2,
                                ),
                              ],
                              border:
                                  Border.all(
                                color:
                                    const Color(
                                  0xFFF7F2FD,
                                ),
                                width:
                                    2,
                              ),
                            ),
                            child:
                                showBoardImage
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(
                                          18,
                                        ),
                                        child:
                                            Opacity(
                                          opacity:
                                              0.18,
                                          child:
                                              widget.isCustomImage &&
                                                      widget.customImagePath !=
                                                          null
                                                  ? Image.file(
                                                      File(
                                                        widget.customImagePath!,
                                                      ),
                                                      width:
                                                          boardSize,
                                                      height:
                                                          boardSize,
                                                      fit:
                                                          BoxFit.cover,
                                                    )
                                                  : Image.asset(
                                                      widget.level!.image,
                                                      width:
                                                          boardSize,
                                                      height:
                                                          boardSize,
                                                      fit:
                                                          BoxFit.cover,
                                                    ),
                                        ),
                                      )
                                    : const SizedBox
                                        .shrink(),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    Container(
                      key:
                          trayKey,
                      height:
                          trayHeight,
                      margin:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 12,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFFDCCFEA,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          22,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .black
                                .withOpacity(
                              0.25,
                            ),
                            blurRadius:
                                20,
                            offset:
                                const Offset(
                              0,
                              8,
                            ),
                          ),
                        ],
                        border:
                            Border.all(
                          color:
                              const Color(
                            0xFFF7F2FD,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 15,
                    ),
                  ],
                ),

                // ==================================================
                // 🪙 حركة العملة
                // ==================================================

                if (showCoinAnimation &&
                    coinAnimationStart !=
                        null)
                  Builder(
                    builder:
                        (context) {
                      final target =
                          getCoinTargetPosition();

                      if (target ==
                          null) {
                        return const SizedBox
                            .shrink();
                      }

                      return FlyingCoin(
                        start:
                            coinAnimationStart!,
                        end:
                            target,
                        onFinished:
                            () async {
                          await RewardManager
                              .addCoins(
                            1,
                          );

                          if (!mounted) {
                            return;
                          }

                          setState(() {
                            showCoinAnimation =
                                false;
                          });
                        },
                      );
                    },
                  ),

                // ==================================================
                // 🧩 البازل
                // ==================================================

                if (puzzleCreated)
                  Positioned.fill(
                    child:
                        GestureDetector(
                      behavior:
                          HitTestBehavior
                              .translucent,

                      onPanStart:
                          (details) {
                        controller
                            .onPanStart(
                          details
                              .localPosition,
                        );
                      },

                      onPanUpdate:
                          (details) {
                        controller
                            .onPanUpdate(
                          details
                              .localPosition,
                        );
                      },

                      onPanEnd:
                          (_) async {
                        controller
                            .onPanEnd();

                        moves++;

                        await Future.delayed(
                          const Duration(
                            milliseconds:
                                100,
                          ),
                        );

                        if (!mounted) {
                          return;
                        }

                        final placedCount =
                            controller
                                .pieces
                                .where(
                                  (p) =>
                                      p.isPlaced,
                                )
                                .length;

                        if (placedCount >
                            lastPlacedCount) {
                          lastPlacedCount =
                              placedCount;

                          if (soundEnabled) {
                            await _audioPlayer
                                .play(
                              AssetSource(
                                'audio/piece_correct.mp3',
                              ),
                            );
                          }

                          if (controller
                                  .lastPlacedPosition !=
                              null) {
                            final overlayContext =
                                overlayKey
                                    .currentContext;

                            if (overlayContext !=
                                null) {
                              final RenderBox
                                  overlayBox =
                                  overlayContext
                                      .findRenderObject()
                                      as RenderBox;

                              final start =
                                  overlayBox
                                      .localToGlobal(
                                controller
                                    .lastPlacedPosition!,
                              );

                              final localStart =
                                  overlayBox
                                      .globalToLocal(
                                start,
                              );

                              setState(() {
                                coinAnimationStart =
                                    localStart;

                                showCoinAnimation =
                                    true;
                              });
                            }
                          }
                        }

                        // ==================================================
                        // 💾 حفظ آخر حالة
                        // ==================================================

                        await saveCurrentGame();

                        // ==================================================
                        // 🏆 فحص الفوز
                        // ==================================================

                        await checkWin();
                      },

                      child:
                          CustomPaint(
                        painter:
                            PuzzlePainter(
                          pieces:
                              controller
                                  .pieces,
                          image:
                              image!,
                          boardRect:
                              controller
                                  .boardRect,
                          rows:
                              gridSize,
                          cols:
                              gridSize,
                          repaint:
                              controller,
                        ),
                      ),
                    ),
                  ),

                // ==================================================
                // 🎮 Toolbar
                // ==================================================

                Positioned(
                  top: 0,
                  left: 8,
                  right: 8,
                  child:
                      GameToolbar(
                    starKey:
                        starKey,
                    gemKey:
                        gemKey,
                    coinKey:
                        coinKey,
                    soundEnabled:
                        soundEnabled,

                    onSave:
                        () async {
                      await saveCurrentGame();

                      if (!mounted) {
                        return;
                      }

                      ScaffoldMessenger
                              .of(
                            context,
                          )
                          .showSnackBar(
                        const SnackBar(
                          content:
                              Text(
                            "تم الحفظ بنجاح",
                          ),
                          behavior:
                              SnackBarBehavior
                                  .floating,
                        ),
                      );
                    },

                    onRestart:
                        () {
                      restartGame();
                    },

                    onExit:
                        () async {
                      await saveCurrentGame();

                      stopwatch.stop();

                      if (!mounted) {
                        return;
                      }

                      Navigator.pop(
                        context,
                      );
                    },

                    onSoundChanged:
                        (enabled) {
                      setState(() {
                        soundEnabled =
                            enabled;
                      });

                      _audioPlayer
                          .setVolume(
                        enabled
                            ? 1
                            : 0,
                      );
                    },
                  ),
                ),

                // ==================================================
                // 🔀 زر إعادة التجميع
                // ==================================================

                if (showRegroupButton)
                  FloatingRegroupButton(
                    onPressed:
                        () {
                      AdsManager()
                          .showRewardedAd(
                        onRewardEarned:
                            () {
                          if (!mounted) {
                            return;
                          }

                          controller
                              .regroupPieces();

                          setState(() {
                            showRegroupButton =
                                false;
                          });
                        },

                        onAdFailed:
                            () {
                          if (!mounted) {
                            return;
                          }

                          ScaffoldMessenger
                                  .of(
                                context,
                              )
                              .showSnackBar(
                            const SnackBar(
                              content:
                                  Text(
                                "التجميع غير متوفر حاليًا، حاول لاحقًا",
                                textAlign:
                                    TextAlign
                                        .center,
                              ),
                              behavior:
                                  SnackBarBehavior
                                      .floating,
                              duration:
                                  Duration(
                                seconds:
                                    2,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🧹 DISPOSE
  // ============================================================

  @override
  void dispose() {
    _audioPlayer.dispose();

    _regroupTimer?.cancel();

    // ----------------------------------------------------------
    // 💾 حفظ آخر حالة عند الخروج
    //
    // لا نستعمل await داخل dispose.
    //
    // الجزيرة الخاصة → نظام الحفظ الخاص بها.
    // البازل العادي → نظام progress.
    // ----------------------------------------------------------

    if (puzzleCreated &&
        !gameFinished) {
      if (widget.isCustomImage) {
        final state =
            _buildSaveData();

        PuzzleProgressManager
            .savePrivateIslandGameState(
          state,
        );

        if (widget.customImagePath !=
            null) {
          PuzzleProgressManager
              .savePrivateIslandImagePath(
            widget.customImagePath!,
          );
        }
      } else {
        PuzzleProgressManager
            .saveProgress(
          puzzleId:
              normalPuzzleId,
          levelId:
              currentLevelId,
          pieces:
              controller.pieces,
          moves:
              moves,
          seconds:
              currentElapsedSeconds,
        );
      }
    }

    if (puzzleCreated) {
      controller.dispose();
    }

    super.dispose();
  }
}