import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

// --- Audio Helper (Replace with your actual audio manager) ---
void _playSound(String soundName) {
  debugPrint("🎵 Playing Sound: $soundName");
}

// --- Data Models ---
class PuzzlePiece {
  final Rect sourceRect;
  final Path path; 
  
  double x = 0.0;
  double y = 0.0;
  double rotationZ = 0.0;
  double scale = 1.0;
  double opacity = 1.0;
  
  // Velocity vectors
  double vx = 0.0;
  double vy = 0.0;
  double vr = 0.0;

  PuzzlePiece({required this.sourceRect, required this.path});
}

class _Particle {
  double distance = 0.0;
  double angle = 0.0;
  double speed = 0.0;
  double radius = 0.0;
  double alpha = 1.0;
  bool active = false;
}

// --- Main Victory Screen ---
class VictoryScreen extends StatefulWidget {
  final ui.Image puzzleImage;
  final List<PuzzlePiece> pieces;
  final VoidCallback onReplay;
  final VoidCallback onNextLevel;
  final bool isFinalLevel;
  final VoidCallback onFinished;
  
  // Added as an optional parameter to maintain backwards compatibility
  final GlobalKey? targetIconKey; 

  const VictoryScreen({
    Key? key,
    required this.puzzleImage,
    required this.pieces,
    required this.onReplay,
    required this.onNextLevel,
    this.isFinalLevel = false,
    required this.onFinished,
    this.targetIconKey,
  }) : super(key: key);

  @override
  _VictoryScreenState createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen> with TickerProviderStateMixin {
  // Sequence Controllers (No Future.delayed)
  late AnimationController _pauseController;
  late AnimationController _chestSequenceController;
  late AnimationController _flightController;
  late AnimationController _chestFadeController;
  late AnimationController _uiController;
  
  // Animation States
  bool _showPuzzle = true;
  bool _shatterStarted = false;
  bool _showChest = false;
  bool _chestOpened = false;
  bool _showRewardFlight = false;
  bool _rewardGranted = false;

  // Tickers for Physics (Updates handled strictly outside CustomPainters)
  late Ticker _puzzlePhysicsTicker;
  late Ticker _particleTicker;
  
  // Disney-Style Chest Animations
  late Animation<double> _chestFallBounce;
  late Animation<double> _chestAnticipation;
  late Animation<double> _chestShake;
  late Animation<double> _chestPop;
  
  // Particle System
  final int _maxParticles = 25;
  late List<_Particle> _particles;

  // Bezier Flight Path
  Offset _flightStart = Offset.zero;
  Offset _flightEnd = Offset.zero;

  @override
  void initState() {
    super.initState();
    _initParticles();
    _setupControllers();
    _setupAnimations();
    
    // Start Sequence: Assemble puzzle -> wait briefly
    _playSound("puzzle_complete");
    _pauseController.forward();
  }

  void _initParticles() {
    final rnd = Random();
    _particles = List.generate(_maxParticles, (index) => _Particle()
      ..angle = rnd.nextDouble() * 2 * pi
      ..speed = 3.0 + rnd.nextDouble() * 5.0
      ..radius = rnd.nextDouble() * 3.0 + 2.0
      ..active = false
    );
  }

  void _setupControllers() {
    // 1. Pause after puzzle assembly
    _pauseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _pauseController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _triggerShatterAndChestFall();
      }
    });

    // 2. Chest Disney Sequence (Fall, Bounce, Squash, Shake, Open)
    _chestSequenceController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
    _chestSequenceController.addListener(_chestSequenceAudioListener);
    _chestSequenceController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _triggerRewardFlight();
      }
    });

    // 3. Reward Flight
    _flightController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _flightController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _triggerFinalization();
      }
    });

    // 4. Chest Fade Out
    _chestFadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    // 5. UI Fade In
    _uiController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    // Tickers
    _puzzlePhysicsTicker = createTicker((_) => _updatePuzzlePhysics());
    _particleTicker = createTicker((_) => _updateParticlePhysics());
  }

  void _setupAnimations() {
    // Fall & Bounce
    _chestFallBounce = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: -500.0, end: 0.0).chain(CurveTween(curve: Curves.easeInCubic)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -60.0).chain(CurveTween(curve: Curves.easeOutQuad)), weight: 15),
      TweenSequenceItem(tween: Tween(begin: -60.0, end: 0.0).chain(CurveTween(curve: Curves.easeInQuad)), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -20.0).chain(CurveTween(curve: Curves.easeOutQuad)), weight: 10),
      TweenSequenceItem(tween: Tween(begin: -20.0, end: 0.0).chain(CurveTween(curve: Curves.bounceOut)), weight: 30),
    ]).animate(CurvedAnimation(parent: _chestSequenceController, curve: const Interval(0.0, 0.4)));

    // Anticipation (Squash)
    _chestAnticipation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
    ]).animate(CurvedAnimation(parent: _chestSequenceController, curve: const Interval(0.45, 0.55)));

    // Shake
    _chestShake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.15, end: -0.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.15, end: 0.15), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.15, end: -0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _chestSequenceController, curve: const Interval(0.55, 0.75)));

    // Open Overshoot
    _chestPop = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25).chain(CurveTween(curve: Curves.easeOutBack)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0).chain(CurveTween(curve: Curves.easeOut)), weight: 60),
    ]).animate(CurvedAnimation(parent: _chestSequenceController, curve: const Interval(0.75, 0.9)));
  }

  bool _chestLandedPlayed = false;
  bool _chestOpenedPlayed = false;
  
  void _chestSequenceAudioListener() {
    final val = _chestSequenceController.value;
    
    // Fall finishes at 0.4 interval
    if (val >= 0.4 && !_chestLandedPlayed) {
      _chestLandedPlayed = true;
      _playSound("chest_landing");
    }
    
    // Open starts at 0.75 interval
    if (val >= 0.75 && !_chestOpenedPlayed) {
      _chestOpenedPlayed = true;
      _playSound("chest_opening");
      
      setState(() {
        _chestOpened = true;
      });
      
      // Start magical particle burst
      _playSound("magical_burst");
      for (var p in _particles) {
        p.active = true;
        p.distance = 0.0;
        p.alpha = 1.0;
      }
      _particleTicker.start();
    }
  }

  void _triggerShatterAndChestFall() {
    setState(() {
      _shatterStarted = true;
      _showChest = true;
    });
    
    _playSound("explosion");
    
    final random = Random();
    for (var piece in widget.pieces) {
      // Strong upward impulse
      piece.vx = (random.nextDouble() - 0.5) * 25; 
      piece.vy = -15 - (random.nextDouble() * 18);
      piece.vr = (random.nextDouble() - 0.5) * 0.4;
      piece.opacity = 1.0;
    }
    
    _puzzlePhysicsTicker.start();
    _chestSequenceController.forward();
  }

  void _updatePuzzlePhysics() {
    bool piecesActive = false;
    setState(() {
      for (var piece in widget.pieces) {
        if (piece.opacity <= 0.01) continue;
        piecesActive = true;
        
        piece.x += piece.vx;
        piece.y += piece.vy;
        
        piece.vy += 0.9; // Gravity
        
        // Air resistance
        piece.vx *= 0.97;
        piece.vy *= 0.97;
        piece.vr *= 0.97;

        piece.rotationZ += piece.vr;
        
        piece.scale = max(0.0, piece.scale - 0.008);
        piece.opacity = max(0.0, piece.opacity - 0.02);
      }
    });

    if (!piecesActive && _shatterStarted) {
      _puzzlePhysicsTicker.stop();
      setState(() {
        _showPuzzle = false;
      });
    }
  }

  void _updateParticlePhysics() {
    bool particlesActive = false;
    setState(() {
      for (var p in _particles) {
        if (!p.active) continue;
        particlesActive = true;
        
        p.distance += p.speed;
        p.alpha = max(0.0, p.alpha - 0.02); // Fade out as they burst outward
        
        if (p.alpha <= 0.01) {
          p.active = false;
        }
      }
    });

    if (!particlesActive) {
      _particleTicker.stop();
    }
  }

  void _triggerRewardFlight() {
    _playSound("reward_flying");
    
    // Calculate accurate screen positions
    final size = MediaQuery.of(context).size;
    _flightStart = Offset(size.width / 2, size.height / 2);
    
    if (widget.targetIconKey != null && widget.targetIconKey!.currentContext != null) {
      final RenderBox box = widget.targetIconKey!.currentContext!.findRenderObject() as RenderBox;
      _flightEnd = box.localToGlobal(Offset(box.size.width / 2, box.size.height / 2));
    } else {
      // Fallback
      _flightEnd = Offset(size.width - 40, 40);
    }

    setState(() {
      _showRewardFlight = true;
    });
    
    _flightController.forward();
  }

  void _triggerFinalization() {
    if (_rewardGranted) return;
    _rewardGranted = true;
    
    _playSound("reward_collected");
    
    setState(() {
      _showRewardFlight = false; // Hide gem once it hits the UI
    });

    _chestFadeController.forward();

    if (widget.isFinalLevel) {
      widget.onFinished();
    } else {
      _uiController.forward();
    }
  }

  @override
  void dispose() {
    _pauseController.dispose();
    _chestSequenceController.dispose();
    _flightController.dispose();
    _chestFadeController.dispose();
    _uiController.dispose();
    _puzzlePhysicsTicker.dispose();
    _particleTicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Stack(
        children: [
          // 1. Puzzle Shatter
          if (_showPuzzle)
            RepaintBoundary(
              child: CustomPaint(
                painter: PuzzleShatterPainter(
                  image: widget.puzzleImage,
                  pieces: widget.pieces,
                ),
                size: Size.infinite,
              ),
            ),

          // 2. Chest & Particles
          if (_showChest)
            RepaintBoundary(
              child: FadeTransition(
                opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_chestFadeController),
                child: AnimatedBuilder(
                  animation: _chestSequenceController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _chestFallBounce.value),
                      child: Transform.scale(
                        scale: _chestOpened ? _chestPop.value : _chestAnticipation.value,
                        child: Transform.rotate(
                          angle: _chestShake.value,
                          child: Center(
                            child: _chestOpened 
                                ? ChestOpenedEffect(particles: _particles) 
                                : Image.asset('assets/chest_closed.png', width: 160),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // 3. Cinematic Reward Flight
          if (_showRewardFlight)
            AnimatedBuilder(
              animation: _flightController,
              builder: (context, child) {
                // EaseInOutCubic curve application
                final t = Curves.easeInOutCubic.transform(_flightController.value);
                
                final control = Offset(_flightStart.dx + 150, _flightStart.dy - 100);
                final pos = _calculateBezier(t, _flightStart, control, _flightEnd);
                
                final scale = 1.0 + sin(t * pi) * 0.8; 
                final rotation = t * pi * 4;

                return Positioned(
                  left: pos.dx - 25,
                  top: pos.dy - 25,
                  child: CustomPaint(
                    painter: GemTrailPainter(progress: t),
                    child: Transform.scale(
                      scale: scale,
                      child: Transform.rotate(
                        angle: rotation,
                        child: Image.asset('assets/gem.png', width: 50, height: 50),
                      ),
                    ),
                  ),
                );
              },
            ),

          // 4. UI Actions (Hidden on Final Level)
          if (!widget.isFinalLevel)
            RepaintBoundary(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: FadeTransition(
                    opacity: _uiController,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: widget.onReplay, 
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                          child: const Text("Replay", style: TextStyle(fontSize: 18))
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: widget.onNextLevel,
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)), 
                          child: const Text("Next Level", style: TextStyle(fontSize: 18))
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

  Offset _calculateBezier(double t, Offset p0, Offset p1, Offset p2) {
    double u = 1 - t;
    double tt = t * t;
    double uu = u * u;
    
    double dx = uu * p0.dx + 2 * u * t * p1.dx + tt * p2.dx;
    double dy = uu * p0.dy + 2 * u * t * p1.dy + tt * p2.dy;
    return Offset(dx, dy);
  }
}

// --- Puzzle Shatter Painter ---
class PuzzleShatterPainter extends CustomPainter {
  final ui.Image image;
  final List<PuzzlePiece> pieces;
  
  static final Paint _imagePaint = Paint()..isAntiAlias = true;

  PuzzleShatterPainter({required this.image, required this.pieces});

  @override
  void paint(Canvas canvas, Size size) {
    for (var piece in pieces) {
      if (piece.opacity <= 0.01) continue;

      canvas.save();
      
      // Hardware accelerated translation only
      canvas.translate(piece.sourceRect.left + piece.x, piece.sourceRect.top + piece.y);
      
      final halfWidth = piece.sourceRect.width / 2;
      final halfHeight = piece.sourceRect.height / 2;
      
      canvas.translate(halfWidth, halfHeight);
      canvas.rotate(piece.rotationZ);
      canvas.scale(piece.scale);
      canvas.translate(-halfWidth, -halfHeight);

      // Fade out opacity using color filter
      _imagePaint.color = Color.fromRGBO(255, 255, 255, piece.opacity);

      // EXACT Real Jigsaw path clipping
      canvas.clipPath(piece.path);
      
      final drawRect = Rect.fromLTWH(0, 0, piece.sourceRect.width, piece.sourceRect.height);
      canvas.drawImageRect(image, piece.sourceRect, drawRect, _imagePaint);
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant PuzzleShatterPainter oldDelegate) => true; // Re-paints dictated by Ticker
}

// --- Chest Flare & Particles ---
class ChestOpenedEffect extends StatefulWidget {
  final List<_Particle> particles;
  
  const ChestOpenedEffect({Key? key, required this.particles}) : super(key: key);

  @override
  _ChestOpenedEffectState createState() => _ChestOpenedEffectState();
}

class _ChestOpenedEffectState extends State<ChestOpenedEffect> with SingleTickerProviderStateMixin {
  late AnimationController _flareController;

  @override
  void initState() {
    super.initState();
    _flareController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  }

  @override
  void dispose() {
    _flareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        AnimatedBuilder(
          animation: _flareController,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(350, 350),
              painter: ChestRadialFlarePainter(
                rotation: _flareController.value * 2 * pi,
                particles: widget.particles,
              ),
            );
          },
        ),
        Image.asset('assets/chest_open.png', width: 170),
      ],
    );
  }
}

class ChestRadialFlarePainter extends CustomPainter {
  final double rotation;
  final List<_Particle> particles;
  
  static final Paint _flarePaint = Paint()..style = PaintingStyle.fill;
  static final Paint _particlePaint = Paint()..style = PaintingStyle.fill; // No expensive MaskFilter blur

  ChestRadialFlarePainter({required this.rotation, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Magical radial light sweep
    final sweepGradient = SweepGradient(
      center: Alignment.center,
      colors: const [
        Color(0x00FFD700), Color(0x99FFEA00), Color(0x00FFD700),
        Color(0x99FFEA00), Color(0x00FFD700),
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
      transform: GradientRotation(rotation),
    );

    _flarePaint.shader = sweepGradient.createShader(Rect.fromCircle(center: center, radius: size.width / 2));
    canvas.drawCircle(center, size.width / 2, _flarePaint);

    // Burst sparks (physics computed outside in Ticker)
    for (var p in particles) {
      if (!p.active) continue;
      
      final px = center.dx + cos(p.angle) * p.distance;
      final py = center.dy + sin(p.angle) * p.distance;
      
      _particlePaint.color = Color.fromRGBO(255, 255, 255, p.alpha);
      canvas.drawCircle(Offset(px, py), p.radius, _particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ChestRadialFlarePainter oldDelegate) => true; 
}

// --- Reward Flight Trail ---
class GemTrailPainter extends CustomPainter {
  final double progress;
  static final Paint _trailPaint = Paint()
    ..color = const Color(0x55FFFFFF) // Lightweight transparency, no blur
    ..style = PaintingStyle.fill;

  GemTrailPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, 8 * (1 - progress), _trailPaint);
  }

  @override
  bool shouldRepaint(covariant GemTrailPainter oldDelegate) => true;
}
