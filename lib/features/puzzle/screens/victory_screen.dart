import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../engine/puzzle_piece.dart';
import '../managers/ads_manager.dart';
import '../managers/reward_manager.dart';
import '../models/puzzle_model.dart';
import '../widgets/victory_puzzle_preview.dart';
import '../../../core/language/app_language_manager.dart';

import 'final_victory_screen.dart';

/// ============================================================
/// ✨ Decorative sparkle particle
/// ============================================================

class _ConfettiSpark {
  double x;
  double y;
  double vx;
  double vy;
  double rotation;
  double rotationSpeed;
  double opacity;
  double size;

  final Color color;

  _ConfettiSpark({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.opacity,
    required this.size,
    required this.color,
  });
}

/// ============================================================
/// 🧩 Puzzle explosion data
/// ============================================================

class _PieceExplosionData {
  final PuzzlePiece piece;

  Offset position;

  double vx = 0;
  double vy = 0;
  double gravity = 0.3;

  double rotation = 0;
  double rotationSpeed = 0;

  double opacity = 1;
  double scale = 1;

  _PieceExplosionData(this.piece)
      : position = piece.correctPosition;
}

/// ============================================================
/// 🏆 VictoryScreen
///
/// Levels 1 - 9:
///   ⭐ 1 Star
///   🪙 100 Coins
///
/// Optional rewarded ad:
///   ⭐ +1 Star
///   🪙 +100 Coins
///
/// Level 10:
///   FinalVictoryScreen handles all final rewards.
/// ============================================================

class VictoryScreen extends StatefulWidget {
  final ui.Image puzzleImage;
  final int rows;
  final int cols;
  final Rect boardRect;

  final List<PuzzlePiece> pieces;

  final PuzzleModel? island;
  final int levelNumber;

  final bool isFinalLevel;

  final GlobalKey? starTargetKey;

  final VoidCallback onFinished;

  final VoidCallback? onNext;
  final VoidCallback? onMap;
  final VoidCallback? onReplay;

  const VictoryScreen({
    super.key,
    required this.puzzleImage,
    required this.rows,
    required this.cols,
    required this.boardRect,
    required this.pieces,
    this.island,
    required this.levelNumber,
    this.isFinalLevel = false,
    this.starTargetKey,
    required this.onFinished,
    this.onNext,
    this.onMap,
    this.onReplay,
  });

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // 🌐 Language
  // ============================================================

  AppLanguageManager get language =>
      AppLanguageManager.instance;

  // ============================================================
  // ⏱ Master timing
  // ============================================================

  static const int kImagePhaseMs = 2000;
  static const int kExplosionPhaseMs = 3000;
  static const int kChestPhaseMs = 5000;

  // ============================================================
  // 🧩 Puzzle pieces
  // ============================================================

  List<PuzzlePiece> _pieces = [];

  List<_PieceExplosionData> _explosionPieces = [];

  bool _introVisible = false;
  bool _showPieces = true;

  // ============================================================
  // 🎯 Centering
  // ============================================================

  Offset _puzzleCenterOffset = Offset.zero;

  // ============================================================
  // 💥 Explosion
  // ============================================================

  late Ticker _physicsTicker;

  double _lastElapsedMs = 0;

  // ============================================================
  // 🎁 Chest
  // ============================================================

  late AnimationController _chestController;

  late Animation<double> _chestFall;
  late Animation<double> _chestScale;
  late Animation<double> _chestShake;

  bool _showChest = false;
  bool _chestOpened = false;

  bool _hideChestAfterReward = false;
  bool _chestDisappearing = false;

  final GlobalKey _chestKey = GlobalKey();

  // ============================================================
  // ✨ Sparkles
  // ============================================================

  late AnimationController _glowController;

  late Ticker _sparkleTicker;

  final List<_ConfettiSpark> _sparkles = [];

  bool _sparklesActive = false;

  // ============================================================
  // ⭐ Star preview
  // ============================================================

  late AnimationController _starPreviewController;

  bool _showStarPreview = false;

  // ============================================================
  // ⭐ Reward flight
  // ============================================================

  late AnimationController _rewardController;

  bool _showReward = false;

  bool _rewardSent = false;
  bool _rewardGranted = false;

  Offset _rewardStart = Offset.zero;
  Offset _rewardEnd = Offset.zero;

  // ============================================================
  // 🎮 Navigation
  // ============================================================

  bool _showButtons = false;

  late AnimationController _buttonsFloatController;

  // ============================================================
  // 📺 Rewarded ad
  // ============================================================

  bool _doubleRewardAsked = false;
  bool _rewardAdFinished = false;
  bool _doubleRewardCompleted = false;

  // ============================================================
  // 🔊 Audio
  // ============================================================

  final AudioPlayer _victoryAudio = AudioPlayer();

  // ============================================================
  // 🚦 Sequence protection
  // ============================================================

  bool _sequenceFinished = false;
  bool _finalNavigationStarted = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _physicsTicker = createTicker(_updateExplosion);
    _sparkleTicker = createTicker(_updateSparkles);

    _setupChestAnimation();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _starPreviewController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _rewardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _buttonsFloatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _preparePieces();

      _runSequence();

      Future.microtask(() async {
        try {
          await _victoryAudio.play(
            AssetSource('audio/puzzle_win.mp3'),
          );
        } catch (_) {}
      });
    });
  }

  // ============================================================
  // 🧩 Prepare puzzle pieces
  //
  // مهم:
  // يتم حساب مركز اللغز أولاً ثم تطبيق التوسيط مباشرة
  // على جميع القطع.
  //
  // بهذا تكون الصورة كاملة ومرتبة ومتمركزة منذ أول ظهور
  // وقبل بداية الانفجار.
  // ============================================================

  void _preparePieces() {
    _pieces = widget.pieces.toList();

    // ----------------------------------------------------------
    // حساب الإزاحة أولاً
    // ----------------------------------------------------------

    _calculatePuzzleCenter();

    // ----------------------------------------------------------
    // إنشاء بيانات القطع مع تطبيق التوسيط مباشرة
    // ----------------------------------------------------------

    _explosionPieces = _pieces.map((piece) {
      final data = _PieceExplosionData(piece);

      data.position = _centeredPosition(
        piece.correctPosition,
      );

      return data;
    }).toList();

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // 🎯 Calculate puzzle center
  //
  // نعتمد فقط على boardRect كمصدر موثوق لمركز البازل.
  //
  // لا نستخدم:
  // physicalSize
  // devicePixelRatio
  // minX / maxX / minY / maxY
  // أو متوسط أكثر من نظام إحداثيات.
  // ============================================================

  void _calculatePuzzleCenter() {
    if (!mounted) {
      _puzzleCenterOffset = Offset.zero;
      return;
    }

    final screenSize = MediaQuery.of(context).size;

    final screenCenter = Offset(
      screenSize.width / 2,
      screenSize.height / 2,
    );

    final boardCenter = widget.boardRect.center;

    // ----------------------------------------------------------
    // إزاحة واحدة فقط:
    //
    // مركز الشاشة - مركز البورد
    // ----------------------------------------------------------

    _puzzleCenterOffset =
        screenCenter - boardCenter;
  }

  // ============================================================
  // 🎯 Get centered piece position
  // ============================================================

  Offset _centeredPosition(
    Offset original,
  ) {
    return original + _puzzleCenterOffset;
  }

  // ============================================================
  // 💥 Start explosion
  // ============================================================

  void _startExplosion() {
    final random = Random();

    for (final data in _explosionPieces) {
      data.position = _centeredPosition(
        data.piece.correctPosition,
      );

      data.vx =
          (random.nextDouble() - 0.5) * 10;

      data.vy =
          -4.0 - random.nextDouble() * 8.0;

      data.gravity =
          0.18 + random.nextDouble() * 0.25;

      data.rotationSpeed =
          (random.nextDouble() - 0.5) * 0.04;

      data.rotation = 0;
      data.opacity = 1;
      data.scale = 1;
    }

    _lastElapsedMs = 0;

    _physicsTicker.start();
  }

  // ============================================================
  // 💥 Explosion physics
  // ============================================================

  void _updateExplosion(Duration elapsed) {
    final elapsedMs =
        elapsed.inMilliseconds.toDouble();

    final dt = (
      (elapsedMs - _lastElapsedMs) /
      (1000 / 60)
    ).clamp(0.2, 3.0);

    _lastElapsedMs = elapsedMs;

    final fadeT =
        (elapsedMs / kExplosionPhaseMs)
            .clamp(0.0, 1.0);

    final targetOpacity =
        1.0 - Curves.easeOut.transform(fadeT);

    final floorY =
        MediaQuery.of(context).size.height +
        250;

    for (final data in _explosionPieces) {
      data.position += Offset(
        data.vx * dt,
        data.vy * dt,
      );

      data.vy += data.gravity * dt;

      if (data.position.dy > floorY) {
        data.position = Offset(
          data.position.dx,
          floorY,
        );

        data.vy *= -0.45;
        data.vx *= 0.8;
      }

      final damping =
          pow(0.985, dt).toDouble();

      data.vx *= damping;
      data.vy *= damping;

      data.rotation +=
          data.rotationSpeed * dt;

      data.opacity = targetOpacity;

      data.scale = max(
        0.82,
        data.scale - 0.0006 * dt,
      );
    }

    if (mounted) {
      setState(() {});
    }

    if (elapsedMs >= kExplosionPhaseMs) {
      _physicsTicker.stop();
    }
  }

  // ============================================================
  // 🎁 Chest animation
  // ============================================================

  void _setupChestAnimation() {
    _chestController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 3200,
      ),
    );

    _chestFall = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: -650.0,
          end: 0.0,
        ).chain(
          CurveTween(
            curve: Curves.easeInCubic,
          ),
        ),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -70.0,
        ).chain(
          CurveTween(
            curve: Curves.easeOut,
          ),
        ),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -70.0,
          end: 0.0,
        ).chain(
          CurveTween(
            curve: Curves.bounceOut,
          ),
        ),
        weight: 30,
      ),
    ]).animate(_chestController);

    _chestScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.75,
          end: 1.2,
        ).chain(
          CurveTween(
            curve: Curves.easeOutBack,
          ),
        ),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.2,
          end: 1.0,
        ),
        weight: 45,
      ),
    ]).animate(_chestController);

    _chestShake = Tween<double>(
      begin: -0.09,
      end: 0.09,
    ).animate(
      CurvedAnimation(
        parent: _chestController,
        curve: const Interval(
          0.62,
          0.82,
          curve: Curves.easeInOut,
        ),
      ),
    );

    _chestController.addStatusListener(
      (status) {
        if (status != AnimationStatus.completed) {
          return;
        }

        if (!mounted) return;

        setState(() {
          _chestOpened = true;

          if (!widget.isFinalLevel) {
            _showStarPreview = true;

            _starPreviewController.repeat(
              reverse: true,
            );
          } else {
            _showStarPreview = false;

            _starPreviewController.stop();
          }
        });

        _glowController.repeat(
          reverse: true,
        );

        _spawnSparkles();
      },
    );
  }

  // ============================================================
  // ✨ Sparkles
  // ============================================================

  void _spawnSparkles() {
    if (!mounted) return;

    final size =
        MediaQuery.of(context).size;

    final origin = Offset(
      size.width / 2,
      size.height / 2,
    );

    final random = Random();

    const colors = [
      Color(0xFFFFD54F),
      Color(0xFFFFFFFF),
      Color(0xFFFFE082),
      Color(0xFF64B5F6),
    ];

    _sparkles.clear();

    for (var i = 0; i < 45; i++) {
      final angle =
          random.nextDouble() * pi * 2;

      final speed =
          3 + random.nextDouble() * 7;

      _sparkles.add(
        _ConfettiSpark(
          x: origin.dx,
          y: origin.dy,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed - 3,
          rotation:
              random.nextDouble() * pi,
          rotationSpeed:
              (random.nextDouble() - 0.5) * 0.3,
          opacity: 1,
          size:
              5 + random.nextDouble() * 7,
          color: colors[
            random.nextInt(colors.length)
          ],
        ),
      );
    }

    _sparklesActive = true;

    _sparkleTicker.start();
  }

  // ============================================================
  // ✨ Update sparkles
  // ============================================================

  void _updateSparkles(
    Duration elapsed,
  ) {
    bool active = false;

    for (final s in _sparkles) {
      if (s.opacity <= 0) continue;

      active = true;

      s.x += s.vx;
      s.y += s.vy;

      s.vy += 0.16;
      s.vx *= 0.985;

      s.rotation += s.rotationSpeed;

      s.opacity -= 0.014;
    }

    if (mounted) {
      setState(() {});
    }

    if (!active) {
      _sparkleTicker.stop();
      _sparklesActive = false;
    }
  }

  // ============================================================
  // ⭐ Find reward target
  // ============================================================

  Offset _getRewardTarget() {
    final targetKey = widget.starTargetKey;

    if (targetKey != null &&
        targetKey.currentContext != null) {
      try {
        final renderObject =
            targetKey.currentContext!
                .findRenderObject();

        if (renderObject is RenderBox &&
            renderObject.hasSize) {
          return renderObject.localToGlobal(
            renderObject.size.center(
              Offset.zero,
            ),
          );
        }
      } catch (_) {}
    }

    final size =
        MediaQuery.of(context).size;

    return Offset(
      size.width - 50,
      40,
    );
  }

  // ============================================================
  // ⭐ Start reward flight
  // ============================================================

  Future<void> _startRewardFlight() async {
    if (_rewardSent) return;

    if (widget.isFinalLevel) return;

    _rewardSent = true;

    if (!mounted) return;

    final size =
        MediaQuery.of(context).size;

    // ----------------------------------------------------------
    // نقطة بداية النجمة
    // ----------------------------------------------------------

    try {
      if (_chestKey.currentContext != null) {
        final renderObject =
            _chestKey.currentContext!
                .findRenderObject();

        if (renderObject is RenderBox &&
            renderObject.hasSize) {
          _rewardStart =
              renderObject.localToGlobal(
            renderObject.size.center(
              Offset.zero,
            ),
          );
        } else {
          _rewardStart = Offset(
            size.width / 2,
            size.height / 2,
          );
        }
      } else {
        _rewardStart = Offset(
          size.width / 2,
          size.height / 2,
        );
      }
    } catch (_) {
      _rewardStart = Offset(
        size.width / 2,
        size.height / 2,
      );
    }

    _rewardEnd = _getRewardTarget();

    setState(() {
      _showStarPreview = false;

      _starPreviewController.stop();

      _showReward = true;
    });

    // ----------------------------------------------------------
    // ⭐ حركة النجمة
    // ----------------------------------------------------------

    try {
      _rewardController.reset();

      await _rewardController.forward();
    } catch (_) {}

    if (!mounted) return;

    // ----------------------------------------------------------
    // ⭐ المكافأة الأساسية
    // ----------------------------------------------------------

    await _grantBaseReward();

    if (!mounted) return;

    setState(() {
      _showReward = false;
    });
  }

  // ============================================================
  // ⭐ Base reward
  // ============================================================

  Future<void> _grantBaseReward() async {
    if (_rewardGranted) return;

    _rewardGranted = true;

    try {
      await RewardManager.addStars(1);
    } catch (_) {}

    try {
      await RewardManager.addCoins(100);
    } catch (_) {}
  }

  // ============================================================
  // 📺 Double reward dialog
  // ============================================================

  Future<void> _showDoubleRewardDialog() async {
    if (_doubleRewardAsked) return;

    _doubleRewardAsked = true;

    if (!mounted) return;

    bool? doubleReward;

    try {
      doubleReward = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          final lang =
              AppLanguageManager.instance;

          return AlertDialog(
            backgroundColor:
                const Color(0xff1D1730),

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(22),
            ),

            title: Text(
              lang.text(
                ar: 'مكافأة إضافية',
                en: 'Extra Reward',
              ),
              style: const TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),

            content: Text(
              lang.text(
                ar:
                    'هل تريد مضاعفة مكافأتك؟\n\n'
                    'شاهد إعلاناً واحصل على مكافأة إضافية.',
                en:
                    'Do you want to double your reward?\n\n'
                    'Watch an ad to receive an extra reward.',
              ),
              style: const TextStyle(
                color: Colors.white70,
                height: 1.5,
              ),
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    false,
                  );
                },
                child: Text(
                  lang.text(
                    ar: 'لاحقاً',
                    en: 'Later',
                  ),
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    true,
                  );
                },
                child: Text(
                  lang.text(
                    ar: 'مضاعفة',
                    en: 'Double',
                  ),
                ),
              ),
            ],
          );
        },
      );
    } catch (_) {
      doubleReward = false;
    }

    if (!mounted || doubleReward != true) {
      return;
    }

    await _watchDoubleRewardAd();
  }

  // ============================================================
  // 📺 Watch rewarded ad
  // ============================================================

  Future<void> _watchDoubleRewardAd() async {
    _rewardAdFinished = false;

    try {
      final ads = AdsManager();

      if (!ads.isInitialized) {
        await ads.initAds();
      }

      ads.showRewardedAd(
        onRewardEarned: () async {
          if (_doubleRewardCompleted) {
            _rewardAdFinished = true;
            return;
          }

          _doubleRewardCompleted = true;

          try {
            await RewardManager.addStars(1);
          } catch (_) {}

          try {
            await RewardManager.addCoins(100);
          } catch (_) {}

          _rewardAdFinished = true;
        },
        onAdFailed: () {
          _rewardAdFinished = true;

          if (!mounted) return;

          final lang =
              AppLanguageManager.instance;

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                lang.text(
                  ar: 'الإعلان غير متوفر حالياً',
                  en:
                      'The ad is not available right now',
                ),
              ),
            ),
          );
        },
      );
    } catch (_) {
      _rewardAdFinished = true;
    }

    // ----------------------------------------------------------
    // ⏳ Timeout protection
    // ----------------------------------------------------------

    const maxWait =
        Duration(seconds: 15);

    final stopwatch = Stopwatch()
      ..start();

    while (!_rewardAdFinished &&
        stopwatch.elapsed < maxWait) {
      await Future.delayed(
        const Duration(milliseconds: 200),
      );

      if (!mounted) {
        return;
      }
    }

    stopwatch.stop();

    _rewardAdFinished = true;
  }

  // ============================================================
  // 🏆 Finish normal victory sequence
  // ============================================================

  Future<void> _finishNormalVictory() async {
    if (_sequenceFinished) return;

    _sequenceFinished = true;

    if (!mounted) return;

    setState(() {
      _chestDisappearing = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    setState(() {
      _hideChestAfterReward = true;
      _showButtons = true;
    });
  }

  // ============================================================
  // 🏆 Master sequence
  // ============================================================

  Future<void> _runSequence() async {
    if (!mounted) return;

    setState(() {
      _introVisible = true;
    });

    // ----------------------------------------------------------
    // 🧩 صورة البازل كاملة
    // ----------------------------------------------------------

    await Future.delayed(
      const Duration(
        milliseconds: kImagePhaseMs,
      ),
    );

    if (!mounted) return;

    // ----------------------------------------------------------
    // 💥 الانفجار
    // ----------------------------------------------------------

    _startExplosion();

    await Future.delayed(
      const Duration(
        milliseconds: kExplosionPhaseMs,
      ),
    );

    if (!mounted) return;

    if (_physicsTicker.isActive) {
      _physicsTicker.stop();
    }

    // ----------------------------------------------------------
    // 🎁 الصندوق
    // ----------------------------------------------------------

    setState(() {
      _showChest = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 120),
    );

    if (!mounted) return;

    setState(() {
      _showPieces = false;
    });

    try {
      await _chestController.forward();
    } catch (_) {}

    // ----------------------------------------------------------
    // ⏳ وقت عرض الصندوق المفتوح
    // ----------------------------------------------------------

    await Future.delayed(
      const Duration(
        milliseconds: kChestPhaseMs,
      ),
    );

    if (!mounted) return;

    // ----------------------------------------------------------
    // 💎 المرحلة النهائية
    // ----------------------------------------------------------

    if (widget.isFinalLevel) {
      await Future.delayed(
        const Duration(seconds: 5),
      );

      if (!mounted) return;

      _goToFinalVictory();

      return;
    }

    // ----------------------------------------------------------
    // ⭐ تسليم النجمة إلى Toolbar
    // ----------------------------------------------------------

    await _startRewardFlight();

    if (!mounted) return;

    // ----------------------------------------------------------
    // 📺 عرض خيار المضاعفة
    // ----------------------------------------------------------

    await _showDoubleRewardDialog();

    if (!mounted) return;

    // ----------------------------------------------------------
    // 🎮 إنهاء المشهد
    // ----------------------------------------------------------

    await _finishNormalVictory();
  }

  // ============================================================
  // 💎 Navigate to final victory
  // ============================================================

  void _goToFinalVictory() {
    if (_finalNavigationStarted) return;

    _finalNavigationStarted = true;

    try {
      _chestController.stop();
      _glowController.stop();

      if (_sparkleTicker.isActive) {
        _sparkleTicker.stop();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              FinalVictoryScreen(
            island: widget.island,
          ),
        ),
      );
    } catch (_) {
      _finalNavigationStarted = false;
    }
  }

  // ============================================================
  // 🎨 Build
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Material(
      type: MaterialType.transparency,

      child: Stack(
        children: [
          // ======================================================
          // 🧩 Puzzle
          // ======================================================

          if (_showPieces &&
              _explosionPieces.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration:
                      const Duration(milliseconds: 500),

                  opacity:
                      _introVisible ? 1 : 0,

                  child: AnimatedScale(
                    duration:
                        const Duration(milliseconds: 500),

                    curve:
                        Curves.easeOutBack,

                    scale:
                        _introVisible ? 1 : 0.9,

                    child:
                        VictoryPuzzlePreview(
                      image:
                          widget.puzzleImage,

                      rows:
                          widget.rows,

                      cols:
                          widget.cols,

                      pieces:
                          _explosionPieces
                              .map(
                        (e) {
                          return VictoryPieceRenderData(
                            piece:
                                e.piece,

                            position:
                                e.position,

                            rotation:
                                e.rotation,

                            opacity:
                                e.opacity,

                            scale:
                                e.scale,
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              ),
            ),

          // ======================================================
          // ✨ Chest glow
          // ======================================================

          if (_showChest &&
              _chestOpened &&
              !_hideChestAfterReward)
            IgnorePointer(
              child: Center(
                child: AnimatedBuilder(
                  animation:
                      _glowController,

                  builder:
                      (context, child) {
                    final glow =
                        0.18 +
                        (_glowController
                                .value *
                            0.22);

                    return Container(
                      width: 460,
                      height: 460,

                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,

                        gradient:
                            RadialGradient(
                          colors: [
                            Colors.amber
                                .withOpacity(
                              glow,
                            ),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // ======================================================
          // ✨ Sparkles
          // ======================================================

          if (_sparklesActive ||
              _sparkles.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter:
                      _ConfettiSparkPainter(
                    List.of(_sparkles),
                  ),
                ),
              ),
            ),

          // ======================================================
          // 🎁 Chest
          // ======================================================

          if (_showChest &&
              !_hideChestAfterReward)
            Center(
              child: AnimatedBuilder(
                animation:
                    _chestController,

                builder:
                    (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      _chestFall.value,
                    ),

                    child:
                        AnimatedOpacity(
                      duration:
                          const Duration(
                        milliseconds: 500,
                      ),

                      opacity:
                          _chestDisappearing
                              ? 0
                              : 1,

                      child:
                          Transform.scale(
                        scale:
                            _chestScale.value,

                        child:
                            Transform.rotate(
                          angle:
                              _chestShake.value,

                          child:
                              SizedBox(
                            key:
                                _chestKey,

                            width: 250,
                            height: 250,

                            child:
                                Image.asset(
                              _chestOpened
                                  ? 'assets/images/rewards/reward_chest_open.png'
                                  : 'assets/images/rewards/reward_chest_closed.png',

                              fit:
                                  BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // ======================================================
          // ⭐ Star preview
          // ======================================================

          if (_showStarPreview &&
              !widget.isFinalLevel)
            IgnorePointer(
              child: Center(
                child: AnimatedBuilder(
                  animation:
                      _starPreviewController,

                  builder:
                      (context, child) {
                    final t =
                        _starPreviewController
                            .value;

                    final scale =
                        0.9 + (t * 0.2);

                    return Transform.translate(
                      offset:
                          const Offset(
                        0,
                        -110,
                      ),

                      child: Opacity(
                        opacity:
                            0.85 +
                            (t * 0.15),

                        child:
                            Transform.scale(
                          scale: scale,

                          child:
                              Image.asset(
                            'assets/images/rewards/Star_gold.png',

                            width: 60,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // ======================================================
          // ⭐ Star flight
          // ======================================================

          if (_showReward &&
              !widget.isFinalLevel)
            AnimatedBuilder(
              animation:
                  _rewardController,

              builder:
                  (context, child) {
                final t =
                    Curves.easeInOutCubic
                        .transform(
                  _rewardController
                      .value,
                );

                final x =
                    _rewardStart.dx +
                    (_rewardEnd.dx -
                            _rewardStart.dx) *
                        t;

                final y =
                    _rewardStart.dy +
                    (_rewardEnd.dy -
                            _rewardStart.dy) *
                        t;

                final currentScale =
                    1.0 -
                    Curves.easeIn
                            .transform(
                          _rewardController
                              .value,
                        ) *
                        0.45;

                return Positioned(
                  left: x - 35,
                  top: y - 35,

                  child:
                      Transform.scale(
                    scale:
                        currentScale.clamp(
                      0.55,
                      1.0,
                    ),

                    child:
                        Image.asset(
                      'assets/images/rewards/Star_gold.png',

                      width: 70,
                    ),
                  ),
                );
              },
            ),

          // ======================================================
          // 🎮 Navigation buttons
          // ======================================================

          if (_showButtons)
            Positioned.fill(
              child: Center(
                child:
                    TweenAnimationBuilder<
                        double>(
                  tween: Tween(
                    begin: 0,
                    end: 1,
                  ),

                  duration:
                      const Duration(
                    milliseconds: 600,
                  ),

                  curve:
                      Curves.easeOutBack,

                  builder: (
                    context,
                    fadeT,
                    child,
                  ) {
                    return Opacity(
                      opacity: fadeT,

                      child:
                          Transform.translate(
                        offset: Offset(
                          0,
                          (1 - fadeT) * 50,
                        ),

                        child: child,
                      ),
                    );
                  },

                  child:
                      AnimatedBuilder(
                    animation:
                        _buttonsFloatController,

                    builder:
                        (context, child) {
                      final bob =
                          sin(
                            _buttonsFloatController
                                    .value *
                                2 *
                                pi,
                          ) *
                          4;

                      return Transform.translate(
                        offset: Offset(
                          0,
                          bob,
                        ),

                        child: child,
                      );
                    },

                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,

                      children: [
                        // المستوى التالي
                        _VictoryImageActionButton(
                          imagePath:
                              'assets/images/ui/next_play.png',

                          onTap: () {
                            if (widget.onNext !=
                                null) {
                              widget.onNext!();
                            } else {
                              widget.onFinished();
                            }
                          },
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        // إعادة اللعب
                        _VictoryImageActionButton(
                          imagePath:
                              'assets/images/ui/again_play.png',

                          onTap:
                              widget.onReplay ??
                                  widget.onFinished,
                        ),

                        const SizedBox(
                          height: 20,
                        ),

                        // الخريطة
                        _VictoryImageActionButton(
                          imagePath:
                              'assets/images/ui/home_map.png',

                          onTap:
                              widget.onMap ??
                                  widget.onFinished,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // 🧹 Dispose
  // ============================================================

  @override
  void dispose() {
    if (_physicsTicker.isActive) {
      _physicsTicker.stop();
    }

    if (_sparkleTicker.isActive) {
      _sparkleTicker.stop();
    }

    _physicsTicker.dispose();
    _sparkleTicker.dispose();

    _chestController.dispose();
    _glowController.dispose();
    _starPreviewController.dispose();
    _rewardController.dispose();
    _buttonsFloatController.dispose();

    _victoryAudio.stop();
    _victoryAudio.dispose();

    super.dispose();
  }
}

/// ============================================================
/// 🎮 Image action button
/// ============================================================

class _VictoryImageActionButton
    extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _VictoryImageActionButton({
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final size =
        (MediaQuery.of(context)
                    .size
                    .width *
                0.25)
            .clamp(
              90.0,
              130.0,
            );

    return GestureDetector(
      onTap: onTap,

      child: SizedBox(
        width: size,
        height: size,

        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// ============================================================
/// ✨ Sparkle painter
/// ============================================================

class _ConfettiSparkPainter
    extends CustomPainter {
  final List<_ConfettiSpark> sparks;

  _ConfettiSparkPainter(
    this.sparks,
  );

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint();

    for (final s in sparks) {
      if (s.opacity <= 0) continue;

      paint.color =
          s.color.withOpacity(
        s.opacity.clamp(0, 1),
      );

      canvas.save();

      canvas.translate(
        s.x,
        s.y,
      );

      canvas.rotate(
        s.rotation,
      );

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: s.size,
          height: s.size * 0.5,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(
    covariant _ConfettiSparkPainter
        oldDelegate,
  ) {
    return true;
  }
}