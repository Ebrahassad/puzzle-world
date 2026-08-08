import 'dart:ui' as ui;
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../core/language/app_language_manager.dart';

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
  //==================================================
  // 🌐 نظام اللغة
  //==================================================

  AppLanguageManager get language =>
      AppLanguageManager.instance;

  //==================================================
  // 🖼️ الصورة
  //==================================================

  ui.Image? image;

  late PuzzleController controller;

  bool loading = true;
  bool puzzleCreated = false;
  bool gameFinished = false;
  bool checkingSavedGame = true;
  bool soundEnabled = true;
  bool showBoardImage = true;

  Timer? _regroupTimer;

  bool showRegroupButton = false;

  Map<String, dynamic>? savedGameData;

  late Stopwatch stopwatch;

  int lastPlacedCount = 0;
  int moves = 0;

  Offset? coinAnimationStart;
  bool showCoinAnimation = false;

  final AudioPlayer _audioPlayer =
      AudioPlayer();

  final double boardSize = 350;
  final double trayHeight = 110;

  final GlobalKey overlayKey =
      GlobalKey();

  final GlobalKey boardKey =
      GlobalKey();

  final GlobalKey trayKey =
      GlobalKey();

  Rect boardRect = Rect.zero;
  Rect scatterArea = Rect.zero;

  final GlobalKey starKey =
      GlobalKey();

  final GlobalKey gemKey =
      GlobalKey();

  final GlobalKey coinKey =
      GlobalKey();

  //==================================================
  // 🔢 حجم الشبكة
  //==================================================

  int get gridSize {
    if (widget.isCustomImage) {
      return widget.customGridSize ?? 3;
    }

    return widget.level?.gridSize ?? 3;
  }

  //==================================================
  // 🆔 معرف المرحلة الحالية
  //==================================================

  String get currentLevelId {
    if (widget.isCustomImage) {
      return "custom_image_puzzle";
    }

    return widget.level!.id;
  }

  //==================================================
  // 🏁 هل هذه المرحلة الأخيرة؟
  //==================================================

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

  //==================================================
  // 🏝️ فتح الجزيرة التالية
  //==================================================

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

  //==================================================
  // 🗺️ العودة إلى خريطة العالم
  //==================================================

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

  //==================================================
  // 🚀 INIT
  //==================================================

  @override
  void initState() {
    super.initState();

    stopwatch = Stopwatch();

    if (widget.isCustomImage) {
      checkingSavedGame = false;
      _loadImage();
    } else {
      _checkSavedGame();
    }

    _startRegroupHelper();
  }

  //==================================================
  // 💾 فحص اللعبة المحفوظة
  //==================================================

  Future<void> _checkSavedGame() async {
    if (widget.level == null) {
      return;
    }

    final saved =
        await PuzzleProgressManager
            .loadProgress();

    if (saved != null &&
        saved["levelId"] ==
            widget.level!.id) {
      savedGameData = saved;

      if (!mounted) {
        return;
      }

      final resume =
          await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(
              language.text(
                ar: "توجد لعبة محفوظة",
                en: "Saved Game Found",
              ),
            ),
            content: Text(
              language.text(
                ar:
                    "هل تريد الاستمرار في اللعبة السابقة؟",
                en:
                    "Do you want to continue the previous game?",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    false,
                  );
                },
                child: Text(
                  language.text(
                    ar: "لعبة جديدة",
                    en: "New Game",
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  AdsManager()
                      .showRewardedAd(
                    onRewardEarned: () {
                      if (!context.mounted) {
                        return;
                      }

                      Navigator.pop(
                        context,
                        true,
                      );
                    },
                    onAdFailed: () {
                      if (!context.mounted) {
                        return;
                      }

                      Navigator.pop(
                        context,
                        false,
                      );
                    },
                  );
                },
                child: Text(
                  language.text(
                    ar: "استمرار",
                    en: "Continue",
                  ),
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

    if (!mounted) {
      return;
    }

    setState(() {
      checkingSavedGame = false;
    });

    _loadImage();
  }

  //==================================================
  // 🖼️ تحميل الصورة
  //==================================================

  Future<void> _loadImage() async {
    ImageProvider provider;

    if (widget.isCustomImage &&
        widget.customImagePath != null) {
      provider = FileImage(
        File(widget.customImagePath!),
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

  //==================================================
  // 📐 حساب مكان اللوحة والصينية
  //==================================================

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

  //==================================================
  // 🪙 مكان وصول العملة
  //==================================================

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

    final overlayBox =
        overlayKey.currentContext!
                .findRenderObject()
            as RenderBox;

    return overlayBox.globalToLocal(
      global,
    );
  }

  //==================================================
  // 🧩 إنشاء البازل
  //==================================================

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
    }

    setState(() {});

    if (!stopwatch.isRunning) {
      stopwatch.start();
    }
  }

  //==================================================
  // 💾 حفظ اللعبة
  //==================================================

  Future<void> saveCurrentGame() async {
    if (!puzzleCreated ||
        widget.isCustomImage) {
      return;
    }

    await PuzzleProgressManager
        .saveProgress(
      puzzleId:
          widget.island?.id ??
              "custom_island",
      levelId: currentLevelId,
      pieces: controller.pieces,
      moves: moves,
      seconds:
          stopwatch.elapsed.inSeconds,
    );
  }

  //==================================================
  // 🔄 إعادة اللعبة
  //==================================================

  Future<void> restartGame() async {
    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            language.text(
              ar: "إعادة اللعبة",
              en: "Restart Game",
            ),
          ),
          content: Text(
            language.text(
              ar:
                  "هل تريد إعادة اللعبة من البداية؟",
              en:
                  "Do you want to restart the game from the beginning?",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                false,
              ),
              child: Text(
                language.text(
                  ar: "لا",
                  en: "No",
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(
                context,
                true,
              ),
              child: Text(
                language.text(
                  ar: "نعم",
                  en: "Yes",
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    if (puzzleCreated) {
      controller.dispose();
    }

    savedGameData = null;

    setState(() {
      puzzleCreated = false;
      gameFinished = false;
      moves = 0;
      lastPlacedCount = 0;
      showBoardImage = true;
    });

    stopwatch
      ..reset()
      ..start();

    _calculateBoardPosition();
  }

  //==================================================
  // ➡️ فتح المرحلة التالية
  //==================================================

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

  //==================================================
  // 🏆 الفوز
  //==================================================

  Future<void> checkWin() async {
    if (gameFinished) {
      return;
    }

    if (!controller.isSolved) {
      return;
    }

    gameFinished = true;

    stopwatch.stop();

    await PuzzleProgressManager
        .completeLevel(
      currentLevelId,
    );

    if (isFinalLevelOfIsland) {
      await _unlockNextIslandIfNeeded();
    } else {
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
            starTargetKey: starKey,
            pieces: controller.pieces,
            onFinished: () {
              Navigator.pop(context);

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
              Navigator.pop(context);

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
                    level: widget.level,
                    island: widget.island,
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

  //==================================================
  // 🔀 مساعد إعادة التجميع
  //==================================================

  void _startRegroupHelper() {
    Future.delayed(
      const Duration(minutes: 1),
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
      const Duration(seconds: 20),
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

  //==================================================
  // 🎨 BUILD
  //==================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return ValueListenableBuilder<Locale>(
      valueListenable:
          language.localeNotifier,
      builder: (
        context,
        locale,
        child,
      ) {
        if (checkingSavedGame ||
            image == null ||
            loading) {
          return Directionality(
            textDirection:
                language.textDirection,
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
              language.textDirection,
          child: Scaffold(
            body: Container(
              decoration:
                  const BoxDecoration(
                color: Color(
                  0xFFE8E1F3,
                ),
              ),
              child: SafeArea(
                child: Stack(
                  key: overlayKey,
                  children: [
                    //==================================================
                    // BOARD + TRAY
                    //==================================================

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
                              child:
                                  Container(
                                key: boardKey,
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
                                    width: 2,
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
                                              child: widget.isCustomImage &&
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
                          key: trayKey,
                          height: trayHeight,
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

                    //==================================================
                    // 🪙 حركة العملة
                    //==================================================

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
                            end: target,
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

                    //==================================================
                    // 🧩 البازل
                    //==================================================

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

                              await _audioPlayer
                                  .play(
                                AssetSource(
                                  'audio/piece_correct.mp3',
                                ),
                              );

                              if (controller
                                      .lastPlacedPosition !=
                                  null) {
                                final RenderBox
                                    overlayBox =
                                    overlayKey
                                        .currentContext!
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

                    //==================================================
                    // 🎮 Toolbar
                    //==================================================

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
                              .of(context)
                              .showSnackBar(
                            SnackBar(
                              content:
                                  Text(
                                language.text(
                                  ar:
                                      "تم الحفظ بنجاح",
                                  en:
                                      "Game saved successfully",
                                ),
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

                    //==================================================
                    // 🔀 زر إعادة التجميع
                    //==================================================

                    if (showRegroupButton)
                      FloatingRegroupButton(
                        onPressed: () {
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
                                  .of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content:
                                      Text(
                                    language.text(
                                      ar:
                                          "لم يتم تشغيل الإعلان، حاول مرة أخرى",
                                      en:
                                          "The ad could not be played. Please try again.",
                                    ),
                                  ),
                                  behavior:
                                      SnackBarBehavior
                                          .floating,
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
      },
    );
  }

  //==================================================
  // 🧹 DISPOSE
  //==================================================

  @override
  void dispose() {
    _audioPlayer.dispose();

    _regroupTimer?.cancel();

    if (puzzleCreated &&
        !gameFinished &&
        !widget.isCustomImage) {
      PuzzleProgressManager
          .saveProgress(
        puzzleId:
            widget.island?.id ??
                "custom_island",
        levelId:
            currentLevelId,
        pieces:
            controller.pieces,
        moves: moves,
        seconds:
            stopwatch.elapsed.inSeconds,
      );
    }

    if (puzzleCreated) {
      controller.dispose();
    }

    super.dispose();
  }
}