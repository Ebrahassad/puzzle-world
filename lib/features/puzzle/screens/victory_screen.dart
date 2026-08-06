import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'final_victory_screen.dart';
import '../managers/reward_manager.dart';
import '../engine/puzzle_piece.dart';
import '../engine/puzzle_generator.dart';
import '../widgets/victory_puzzle_preview.dart';
import '../models/puzzle_model.dart';
import 'package:audioplayers/audioplayers.dart';

/// Decorative sparkle particle for the chest-opening celebration burst.
/// Purely cosmetic — kept private to this file.
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

class _PieceExplosionData {
  final PuzzlePiece piece;

  double vx = 0;
  double vy = 0;
  double gravity = 0.3;

  double rotation = 0;
  double rotationSpeed = 0;

  double opacity = 1;
  double scale = 1;

  _PieceExplosionData(this.piece);
}

/// Cinematic victory sequence.
///
/// VictoryScreen is fully self-contained using PuzzleGenerator to build
/// and animate the exact puzzle pieces.
///
/// Timeline (mirrors assets/audio/puzzle_win.mp3, ~15s total):
///
///   0s  -  2s : the full completed image is shown via VictoryPuzzlePreview.
///   2s  -  5s : the image is torn into pieces which explode outward,
///               fading from opacity 1 -> 0 slowly and linearly across
///               the whole 3 seconds.
///   5s  - 10s : a chest falls in, bounces, shakes, then opens with a
///               sparkle celebration.
///   10s - 12s : the star appears, pauses ~0.5s, then flies into the
///               real GameToolbar star slot via widget.starTargetKey.
///   12s - 15s : persistent navigation buttons fade + float in (Next /
///               Map / Replay) — they never auto-hide.
class VictoryScreen extends StatefulWidget {
  final ui.Image puzzleImage;
  final int rows;
  final int cols;
  final Rect boardRect;

  final PuzzleModel? island;
  final int levelNumber;
  final bool isFinalLevel;

  final GlobalKey? starTargetKey;

  final VoidCallback onFinished;

  /// Optional dedicated handlers for the end-of-scene buttons. Each falls
  /// back to [onFinished] when not provided.
  final VoidCallback? onNext;
  final VoidCallback? onMap;
  final VoidCallback? onReplay;

  const VictoryScreen({
    super.key,
    required this.puzzleImage,
    required this.rows,
    required this.cols,
    required this.boardRect,
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
  //==============================
  // Master timing schedule (ms)
  //==============================

  static const int kImagePhaseMs = 2000;
  static const int kExplosionPhaseMs = 3000;
  static const int kChestPhaseMs = 5000;

  //==============================
  // Puzzle pieces generated via PuzzleGenerator
  //==============================

  List<PuzzlePiece> _pieces = [];
  List<_PieceExplosionData> _explosionPieces = [];

  //==============================
  // Intro (completed image reveal)
  //==============================

  bool _introVisible = false;
  bool _showPieces = true;

  //==============================
  // Explosion physics
  //==============================

  late Ticker _physicsTicker;
  double _lastElapsedMs = 0;

  //==============================
  // Chest
  //==============================

  late AnimationController _chestController;

  late Animation<double> _chestFall;
  late Animation<double> _chestScale;
  late Animation<double> _chestShake;

  bool _showChest = false;
  bool _chestOpened = false;

  final GlobalKey _chestKey = GlobalKey();

  //==============================
  // Chest-open celebration (glow + sparkles + star preview)
  //==============================

  late AnimationController _glowController;

  late Ticker _sparkleTicker;
  final List<_ConfettiSpark> _sparkles = [];
  bool _sparklesActive = false;

  late AnimationController _starPreviewController;
  bool _showStarPreview = false;

  //==============================
  // Reward flight (star -> GameToolbar)
  //==============================

  late AnimationController _rewardController;

  bool _showReward = false;
  bool _rewardSent = false;

  Offset _rewardStart = Offset.zero;
  Offset _rewardEnd = Offset.zero;

  //==============================
  // End-of-scene navigation buttons
  //==============================

  bool _showButtons = false;
  late AnimationController _buttonsFloatController;

  final AudioPlayer _victoryAudio = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _rewardSent = false;

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
    )..repeat(reverse: true);

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
      _victoryAudio.play(
        AssetSource('audio/puzzle_win.mp3'),
      );
    });
  }

  //==============================
  // Generate and setup puzzle pieces
  //==============================

  void _preparePieces() {
    _pieces = PuzzleGenerator.generate(
      image: widget.puzzleImage,
      rows: widget.rows,
      cols: widget.cols,
      boardRect: widget.boardRect,
      scatterArea: widget.boardRect,
      seed: 1,
    );

    for (final piece in _pieces) {
      piece.currentPosition = piece.correctPosition;
    }

    _explosionPieces = _pieces
        .map((piece) => _PieceExplosionData(piece))
        .toList();

    setState(() {});
  }

  //==============================
  // Explosion physics + fade
  //==============================

  void _startExplosion() {
    final random = Random();

    for (final data in _explosionPieces) {
      data.vx = (random.nextDouble() - 0.5) * 14;
      data.vy = -6.0 - random.nextDouble() * 12.0;
      data.gravity = 0.28 + random.nextDouble() * 0.35;
      data.rotationSpeed = (random.nextDouble() - 0.5) * 0.06;
      data.rotation = 0;
      data.opacity = 1;
      data.scale = 1;
    }

    _lastElapsedMs = 0;
    _physicsTicker.start();
  }

  void _updateExplosion(Duration elapsed) {
    final elapsedMs = elapsed.inMilliseconds.toDouble();
    final dt = ((elapsedMs - _lastElapsedMs) / (1000 / 60)).clamp(0.2, 3.0);
    _lastElapsedMs = elapsedMs;

    final fadeT = (elapsedMs / kExplosionPhaseMs).clamp(0.0, 1.0);
    final targetOpacity = (1.0 - fadeT).clamp(0.0, 1.0);

    final floorY = widget.boardRect.top + widget.boardRect.height + 260;

    for (final data in _explosionPieces) {
      final piece = data.piece;

      piece.currentPosition += Offset(
        data.vx * dt,
        data.vy * dt,
      );

      data.vy += data.gravity * dt;

      if (piece.currentPosition.dy > floorY) {
        piece.currentPosition = Offset(piece.currentPosition.dx, floorY);
        data.vy *= -0.45;
        data.vx *= 0.8;
      }

      final damping = pow(0.985, dt).toDouble();
      data.vx *= damping;
      data.vy *= damping;

      data.rotation += data.rotationSpeed * dt;
      data.opacity = targetOpacity;
      data.scale = max(0.82, data.scale - 0.0006 * dt);
    }

    if (mounted) {
      setState(() {});
    }
  }

  //==============================
  // Chest animation setup
  //==============================

  void _setupChestAnimation() {
    _chestController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _chestFall = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: -650.0, end: 0.0).chain(
          CurveTween(curve: Curves.easeInCubic),
        ),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -70.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -70.0, end: 0.0).chain(
          CurveTween(curve: Curves.bounceOut),
        ),
        weight: 30,
      ),
    ]).animate(_chestController);

    _chestScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.75, end: 1.2).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0),
        weight: 45,
      ),
    ]).animate(_chestController);

    _chestShake = Tween<double>(
      begin: -0.09,
      end: 0.09,
    ).animate(
      CurvedAnimation(
        parent: _chestController,
        curve: const Interval(0.62, 0.82, curve: Curves.easeInOut),
      ),
    );

    _chestController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;

        setState(() {
          _chestOpened = true;
          _showStarPreview = true;
        });

        _glowController.repeat(reverse: true);
        _spawnSparkles();
      }
    });
  }

  //==============================
  // Chest-open sparkle burst
  //==============================

  void _spawnSparkles() {
    if (!mounted) return;

    final size = MediaQuery.of(context).size;
    final origin = Offset(size.width / 2, size.height / 2);
    final random = Random();

    const colors = [
      Color(0xFFFFD54F),
      Color(0xFFFFFFFF),
      Color(0xFFFFE082),
      Color(0xFF64B5F6),
    ];

    _sparkles.clear();

    for (var i = 0; i < 45; i++) {
      final angle = random.nextDouble() * pi * 2;
      final speed = 3 + random.nextDouble() * 7;

      _sparkles.add(
        _ConfettiSpark(
          x: origin.dx,
          y: origin.dy,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed - 3,
          rotation: random.nextDouble() * pi,
          rotationSpeed: (random.nextDouble() - 0.5) * 0.3,
          opacity: 1,
          size: 5 + random.nextDouble() * 7,
          color: colors[random.nextInt(colors.length)],
        ),
      );
    }

    _sparklesActive = true;
    _sparkleTicker.start();
  }

  void _updateSparkles(Duration elapsed) {
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

  //==============================
  // Reward flight
  //==============================

  Future<void> _startRewardFlight() async {
    if (_rewardSent) return;
    _rewardSent = true;

    if (!mounted) return;

    final size = MediaQuery.of(context).size;

    if (_chestKey.currentContext != null) {
      final box = _chestKey.currentContext!.findRenderObject() as RenderBox;
      _rewardStart = box.localToGlobal(box.size.center(Offset.zero));
    } else {
      _rewardStart = Offset(size.width / 2, size.height / 2);
    }

    final targetKey = widget.starTargetKey;

    if (targetKey != null && targetKey.currentContext != null) {
      final box = targetKey.currentContext!.findRenderObject() as RenderBox;
      _rewardEnd = box.localToGlobal(box.size.center(Offset.zero));
    } else {
      _rewardEnd = Offset(size.width - 50, 40);
    }

    setState(() {
      _showStarPreview = false;
      _showReward = true;
    });

    _rewardController.reset();
    await _rewardController.forward();
    if (!mounted) return;

    RewardManager.addStars(1);

    setState(() {
      _showReward = false;
    });
  }

  //==============================
  // Master sequence
  //==============================

  Future<void> _runSequence() async {
    setState(() => _introVisible = true);

    await Future.delayed(const Duration(milliseconds: kImagePhaseMs));
    if (!mounted) return;

    _startExplosion();
    await Future.delayed(const Duration(milliseconds: kExplosionPhaseMs));
    if (!mounted) return;

    _physicsTicker.stop();
    setState(() {
      _showChest = true;
    });

    await Future.delayed(
      const Duration(milliseconds: 120),
    );

    setState(() {
      _showPieces = false;
    });

    _chestController.forward();
    await Future.delayed(const Duration(milliseconds: kChestPhaseMs));
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    await _startRewardFlight();
    if (!mounted) return;

    if (widget.isFinalLevel) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => FinalVictoryScreen(
            island: widget.island,
          ),
        ),
      );
      return;
    }

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    setState(() {
      _showButtons = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          if (_showPieces && _explosionPieces.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: _introVisible ? 1 : 0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutBack,
                    scale: _introVisible ? 1 : 0.9,
                    child: VictoryPuzzlePreview(
                      image: widget.puzzleImage,
                      pieces: _explosionPieces.map((e) {
                        return VictoryPieceRenderData(
                          piece: e.piece,
                          position: e.piece.currentPosition,
                          rotation: e.rotation,
                          opacity: e.opacity,
                          scale: e.scale,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),

          if (_showChest && _chestOpened)
            IgnorePointer(
              child: Center(
                child: AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    final glow = 0.18 + (_glowController.value * 0.22);
                    return Container(
                      width: 460,
                      height: 460,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.amber.withOpacity(glow),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          if (_sparklesActive || _sparkles.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ConfettiSparkPainter(List.of(_sparkles)),
                ),
              ),
            ),

          if (_showChest)
            Center(
              child: AnimatedBuilder(
                animation: _chestController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _chestFall.value),
                    child: Transform.scale(
                      scale: _chestScale.value,
                      child: Transform.rotate(
                        angle: _chestShake.value,
                        child: Container(
                          key: _chestKey,
                          child: SizedBox(
                            width: 250,
                            height: 250,
                            child: Image.asset(
                              _chestOpened
                                  ? 'assets/images/rewards/reward_chest_open.png'
                                  : 'assets/images/rewards/reward_chest_closed.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          if (_showStarPreview)
            IgnorePointer(
              child: Center(
                child: AnimatedBuilder(
                  animation: _starPreviewController,
                  builder: (context, child) {
                    final t = _starPreviewController.value;
                    final scale = 0.9 + (t * 0.2);
                    return Transform.translate(
                      offset: const Offset(0, -110),
                      child: Opacity(
                        opacity: 0.85 + (t * 0.15),
                        child: Transform.scale(
                          scale: scale,
                          child: Image.asset(
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
                      'assets/images/rewards/Star_gold.png',
                      width: 70,
                    ),
                  ),
                );
              },
            ),

          if (_showButtons)
            Positioned(
              left: 0,
              right: 0,
              bottom: 56,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                builder: (context, fadeT, child) {
                  return Opacity(
                    opacity: fadeT,
                    child: Transform.translate(
                      offset: Offset(0, (1 - fadeT) * 20),
                      child: child,
                    ),
                  );
                },
                child: AnimatedBuilder(
                  animation: _buttonsFloatController,
                  builder: (context, child) {
                    final bob = sin(_buttonsFloatController.value * 2 * pi) * 6;
                    return Transform.translate(
                      offset: Offset(0, bob),
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // زر المستوى التالي (next_play.png)
                      _VictoryImageActionButton(
                        imagePath: 'assets/images/ui/next_play.png',
                        onTap: widget.onNext ?? widget.onFinished,
                      ),
                      const SizedBox(width: 16),
                      // زر الخريطة (home_map.png)
                      _VictoryImageActionButton(
                        imagePath: 'assets/images/ui/home_map.png',
                        onTap: widget.onMap ?? widget.onFinished,
                      ),
                      const SizedBox(width: 16),
                      // زر إعادة اللعب (again_play.png)
                      _VictoryImageActionButton(
                        imagePath: 'assets/images/ui/again_play.png',
                        onTap: widget.onReplay ?? widget.onFinished,
                      ),
                    ],
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
    _victoryAudio.dispose();
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

    super.dispose();
  }
}

class _VictoryImageActionButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _VictoryImageActionButton({
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        height: 70,
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _ConfettiSparkPainter extends CustomPainter {
  final List<_ConfettiSpark> sparks;

  _ConfettiSparkPainter(this.sparks);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final s in sparks) {
      if (s.opacity <= 0) continue;

      paint.color = s.color.withOpacity(s.opacity.clamp(0, 1));

      canvas.save();
      canvas.translate(s.x, s.y);
      canvas.rotate(s.rotation);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: s.size, height: s.size * 0.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiSparkPainter oldDelegate) => true;
}
