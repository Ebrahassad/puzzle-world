import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';

import '../engine/puzzle_piece.dart';

/// Data used only for cinematic explosion.
/// We do not modify PuzzlePiece because it is the engine model.
class _ExplosionData {
  double vx;
  double vy;
  double gravity;
  double rotation;
  double opacity;
  double scale;
  double x;
  double y;

  _ExplosionData({
    this.vx = 0,
    this.vy = 0,
    this.gravity = 0.65,
    this.rotation = 0,
    this.opacity = 1,
    this.scale = 1,
    this.x = 0,
    this.y = 0,
  });
}

/// Cinematic victory sequence:
/// Puzzle explosion -> chest -> reward -> toolbar animation
class VictoryScreen extends StatefulWidget {
  final ui.Image puzzleImage;
  final List<PuzzlePiece> pieces;
  final Rect boardRect;
  final int rows;
  final int cols;

  final dynamic island;
  final int levelNumber;
  final bool isFinalLevel;

  final GlobalKey? starTargetKey;
  final GlobalKey? gemTargetKey;

  final VoidCallback onStarEarned;
  final VoidCallback onGemEarned;
  final VoidCallback onFinished;

  const VictoryScreen({
    super.key,
    required this.puzzleImage,
    required this.pieces,
    required this.boardRect,
    required this.rows,
    required this.cols,
    required this.island,
    required this.levelNumber,
    this.isFinalLevel = false,
    this.starTargetKey,
    this.gemTargetKey,
    required this.onStarEarned,
    required this.onGemEarned,
    required this.onFinished,
  });

  @override
  State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen>
    with TickerProviderStateMixin {

  //==============================
  // Explosion
  //==============================

  final Map<PuzzlePiece, _ExplosionData> _explosionData = {};

  late Ticker _physicsTicker;

  bool _explosionStarted = false;
  bool _showPuzzle = true;

  //==============================
  // Chest
  //==============================

  late AnimationController _chestController;
  late AnimationController _gemChestController;

  late Animation<double> _chestFall;
  late Animation<double> _chestScale;
  late Animation<double> _chestShake;

  late Animation<double> _gemChestScale;
  late Animation<double> _gemChestFall;

  bool _showChest = false;
  bool _chestOpened = false;

  bool _finalGemSequence = false;
  bool _showGem = false;

  double _flash = 0;

  final GlobalKey _chestKey = GlobalKey();

  //==============================
  // Reward
  //==============================

  late AnimationController _rewardController;

  bool _showReward = false;
  bool _rewardSent = false;

  Offset _rewardStart = Offset.zero;
  Offset _rewardEnd = Offset.zero;

  @override
  void initState() {
    super.initState();

    _showGem = false;
    _rewardSent = false;

    _prepareExplosion();

    _physicsTicker = createTicker((_) {
      _updateExplosion();
    });

    _setupChestAnimation();
    _setupGemChestAnimation();
    _setupRewardAnimation();

    // small pause so player sees completed puzzle
    Future.delayed(
      const Duration(milliseconds: 900),
      () {
        if (!mounted) return;
        _startExplosion();
      },
    );
  }

  void _prepareExplosion() {
    final random = Random();

    for (final piece in widget.pieces) {
      _explosionData[piece] = _ExplosionData(
        vx: (random.nextDouble() - 0.5) * 25,
        vy: -12 - random.nextDouble() * 22,
        gravity: 0.4 + random.nextDouble() * 0.8,
        rotation: (random.nextDouble() - 0.5) * 0.3,
      )
        ..x = 0
        ..y = 0;
    }
  }

  void _startExplosion() {
    if (_explosionStarted) return;

    _explosionStarted = true;
    setState(() {});
    _physicsTicker.start();
  }

  void _updateExplosion() {
    bool active = false;

    for (final piece in widget.pieces) {
      final data = _explosionData[piece];

      if (data == null) continue;
      if (data.opacity <= 0) continue;

      active = true;

      data.x += data.vx;
      data.y += data.vy;

      data.vy += data.gravity;

      if (data.y > 220) {
        data.y = 220;
        data.vy *= -0.45;
        data.vx *= 0.8;
      }

      data.vx *= 0.97;
      data.vy *= 0.97;

      data.rotation += 0.025;
      data.opacity -= 0.008;

      data.scale = max(0.75, data.scale - 0.0015);
    }

    if (mounted) {
      setState(() {});
    }

    if (!active && mounted) {
      _physicsTicker.stop();

      setState(() {
        _showPuzzle = false;
        _showChest = true;
      });

      Future.delayed(
        const Duration(milliseconds: 400),
        () {
          if (mounted && !_chestController.isAnimating) {
            _chestController.forward();
          }
        },
      );
    }
  }

  void _setupChestAnimation() {
    _chestController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _chestFall = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: -500.0, end: 0.0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -60.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -60.0, end: 0.0).chain(
          CurveTween(curve: Curves.bounceOut),
        ),
        weight: 45,
      ),
    ]).animate(_chestController);

    _chestScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.8, end: 1.15).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 1.0),
        weight: 50,
      ),
    ]).animate(_chestController);

    _chestShake = Tween<double>(
      begin: -0.08,
      end: 0.08,
    ).animate(
      CurvedAnimation(
        parent: _chestController,
        curve: const Interval(0.55, 0.75, curve: Curves.easeInOut),
      ),
    );

    _chestController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _chestOpened = true;
          _flash = 1;
        });

        Future.delayed(
          const Duration(milliseconds: 300),
          () {
            if (mounted) {
              setState(() {
                _flash = 0;
              });
            }
          },
        );

        Future.delayed(
          const Duration(milliseconds: 700),
          () {
            if (!mounted) return;
            _startRewardFlight();
          },
        );
      }
    });
  }

  void _setupGemChestAnimation() {
    _gemChestController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _gemChestFall = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: -700.0, end: 40.0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 40.0, end: 0.0).chain(
          CurveTween(curve: Curves.bounceOut),
        ),
        weight: 30,
      ),
    ]).animate(_gemChestController);

    _gemChestScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.6, end: 1.3).chain(
          CurveTween(curve: Curves.elasticOut),
        ),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0),
        weight: 30,
      ),
    ]).animate(_gemChestController);
  }

  void _setupRewardAnimation() {
    _rewardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  void _startFinalGemSequence() {
    if (_finalGemSequence) return;

    _finalGemSequence = true;
    _rewardSent = false;

    setState(() {
      _flash = 0;
      _showGem = false;
      _showReward = false;
      _showChest = true;
      _chestOpened = false;
    });

    _gemChestController.reset();

    _gemChestController.forward().then((_) {
      if (!mounted) return;

      setState(() {
        _chestOpened = true;
        _flash = 1;
      });

      Future.delayed(
        const Duration(milliseconds: 300),
        () {
          if (mounted) {
            setState(() {
              _flash = 0;
            });
          }
        },
      );

      Future.delayed(
        const Duration(milliseconds: 500),
        () {
          if (!mounted) return;
          _showGem = true;
          _startRewardFlight();
        },
      );
    });
  }

  Future<void> _startRewardFlight() async {
    if (_rewardSent) return;

    _rewardSent = true;

    await Future.delayed(const Duration(milliseconds: 100));

    final size = MediaQuery.of(context).size;

    if (_chestKey.currentContext != null) {
      final box = _chestKey.currentContext!.findRenderObject() as RenderBox;
      _rewardStart = box.localToGlobal(box.size.center(Offset.zero));
    } else {
      _rewardStart = Offset(size.width / 2, size.height / 2);
    }

    final targetKey = _showGem ? widget.gemTargetKey : widget.starTargetKey;

    if (targetKey != null && targetKey.currentContext != null) {
      final box = targetKey.currentContext!.findRenderObject() as RenderBox;
      _rewardEnd = box.localToGlobal(box.size.center(Offset.zero));
    } else {
      _rewardEnd = Offset(size.width - 50, 40);
    }

    setState(() {
      _showReward = true;
    });

    _rewardController.reset();
    _rewardController.forward().then((_) {
      if (!mounted) return;

      if (_showGem) {
        widget.onGemEarned();

        Future.delayed(
          const Duration(milliseconds: 500),
          () {
            if (mounted) {
              widget.onFinished();
            }
          },
        );
      } else {
        widget.onStarEarned();

        if (widget.isFinalLevel) {
          Future.delayed(
            const Duration(milliseconds: 1500),
            () {
              if (mounted) {
                _startFinalGemSequence();
              }
            },
          );
        } else {
          widget.onFinished();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        alignment: Alignment.center,
        children: [
          if (_showPuzzle)
            Positioned.fill(
              child: CustomPaint(
                painter: PuzzleExplosionPainter(
                  image: widget.puzzleImage,
                  pieces: widget.pieces,
                  data: _explosionData,
                  boardRect: widget.boardRect,
                  rows: widget.rows,
                  cols: widget.cols,
                ),
              ),
            ),

          if (_showChest)
            AnimatedBuilder(
              animation: _finalGemSequence ? _gemChestController : _chestController,
              builder: (context, child) {
                return Transform.translate(
                  offset: _finalGemSequence
                      ? Offset(0, _gemChestFall.value)
                      : Offset(0, _chestFall.value),
                  child: Transform.scale(
                    scale: _finalGemSequence ? _gemChestScale.value : _chestScale.value,
                    child: Transform.rotate(
                      angle: _finalGemSequence ? 0 : _chestShake.value,
                      child: Container(
                        key: _chestKey,
                        child: Image.asset(
                          _chestOpened
                              ? 'assets/images/rewards/reward_chest_open.png'
                              : 'assets/images/rewards/reward_chest_closed.png',
                          width: 170,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

          if (_showReward)
            AnimatedBuilder(
              animation: _rewardController,
              builder: (context, child) {
                final t = Curves.easeInOutCubic.transform(_rewardController.value);

                final x = _rewardStart.dx + (_rewardEnd.dx - _rewardStart.dx) * t;
                final y = _rewardStart.dy + (_rewardEnd.dy - _rewardStart.dy) * t;
                final currentScale = 1.0 - (_rewardController.value * 0.35);

                return Positioned(
                  left: x - 35,
                  top: y - 35,
                  child: Transform.scale(
                    scale: currentScale.clamp(0.65, 1.0),
                    child: Image.asset(
                      _showGem
                          ? 'assets/images/rewards/gem.png'
                          : 'assets/images/rewards/Star_gold.png',
                      width: _showGem ? 80 : 70,
                    ),
                  ),
                );
              },
            ),

          if (_flash > 0)
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: _flash,
                  child: Container(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _physicsTicker.dispose();
    _chestController.dispose();
    _gemChestController.dispose();
    _rewardController.dispose();
    super.dispose();
  }
}

//======================================
// Explosion Painter
//======================================

class PuzzleExplosionPainter extends CustomPainter {
  final ui.Image image;
  final List<PuzzlePiece> pieces;
  final Map<PuzzlePiece, _ExplosionData> data;

  final Rect boardRect;
  final int rows;
  final int cols;

  PuzzleExplosionPainter({
    required this.image,
    required this.pieces,
    required this.data,
    required this.boardRect,
    required this.rows,
    required this.cols,
  });

  static final Paint _paint = Paint()..filterQuality = FilterQuality.high;

  @override
  void paint(Canvas canvas, Size size) {
    final pieceWidth = boardRect.width / cols;
    final pieceHeight = boardRect.height / rows;

    for (final piece in pieces) {
      final d = data[piece];

      if (d == null || d.opacity <= 0) continue;

      canvas.save();

      // المكان الأصلي للقطعة + الانفجار
      final center = Offset(
        boardRect.left + piece.correctPosition.dx + pieceWidth / 2,
        boardRect.top + piece.correctPosition.dy + pieceHeight / 2,
      );

      canvas.translate(center.dx + d.x, center.dy + d.y);
      canvas.rotate(d.rotation);
      canvas.scale(d.scale);
      canvas.translate(-pieceWidth / 2, -pieceHeight / 2);

      // قص قطعة البازل بشكل صحيح
      canvas.save();

      final localPath = Path();
      localPath.addPath(
        piece.path,
        Offset(-center.dx, -center.dy),
      );

      canvas.clipPath(localPath);

      final source = Rect.fromLTWH(
        piece.col * image.width / cols,
        piece.row * image.height / rows,
        image.width / cols,
        image.height / rows,
      );

      final destination = Rect.fromLTWH(0, 0, pieceWidth, pieceHeight);

      _paint.color = Colors.white.withOpacity(d.opacity);

      canvas.drawImageRect(image, source, destination, _paint);

      // ظل خفيف أثناء الانفجار
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(d.opacity * 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

      canvas.drawPath(localPath, shadowPaint);

      canvas.restore();
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant PuzzleExplosionPainter oldDelegate) {
    return true;
  }
}
