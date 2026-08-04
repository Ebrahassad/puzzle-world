import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../managers/reward_manager.dart';
import 'world_map_screen.dart';

/// Lightweight particle used for the celebratory confetti/firework burst
/// when the final chest opens. Kept private to this file — no new files,
/// no changes to the engine models.
class _ConfettiParticle {
  double x;
  double y;
  double vx;
  double vy;
  double rotation;
  double rotationSpeed;
  double opacity;
  double size;
  final Color color;

  _ConfettiParticle({
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

class FinalVictoryScreen extends StatefulWidget {
  final dynamic island;

  const FinalVictoryScreen({
    super.key,
    required this.island,
  });

  @override
  State<FinalVictoryScreen> createState() => _FinalVictoryScreenState();
}

class _FinalVictoryScreenState extends State<FinalVictoryScreen>
    with TickerProviderStateMixin {

  //==============================
  // Chest
  //==============================

  late AnimationController _chestController;
  late Animation<double> _chestDrop;
  late Animation<double> _chestScale;
  late Animation<double> _shake;

  bool _opened = false;

  final GlobalKey _chestKey = GlobalKey();

  //==============================
  // Flash
  //==============================

  late AnimationController _flashController;

  //==============================
  // Confetti / fireworks burst
  //==============================

  late Ticker _confettiTicker;
  final List<_ConfettiParticle> _confetti = [];
  bool _confettiActive = false;

  //==============================
  // Glow pulse behind the chest (hero spotlight)
  //==============================

  late AnimationController _glowController;

  //==============================
  // Gem: pop out of chest, then fly to the on-screen collector badge
  //==============================

  late AnimationController _gemPopController;
  late Animation<double> _gemPopScale;
  late Animation<double> _gemPopRotate;

  late AnimationController _gemFlightController;

  bool _showGemPop = false;
  bool _showGemFlight = false;
  bool _gemAdded = false;

  Offset _gemStart = Offset.zero;
  Offset _gemEnd = Offset.zero;

  final GlobalKey _gemBadgeKey = GlobalKey();

  //==============================
  // Badge landing punch
  //==============================

  late AnimationController _badgePunchController;
  late Animation<double> _badgePunchScale;

  //==============================
  // Hero title text
  //==============================

  late AnimationController _titleController;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;

  @override
  void initState() {
    super.initState();

    _setupAnimations();
    _confettiTicker = createTicker((_) => _updateConfetti());

    _startSequence();
  }

  void _setupAnimations() {
    _chestController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _gemPopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _gemFlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _badgePunchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _chestDrop = Tween<double>(begin: -650, end: 0).animate(
      CurvedAnimation(parent: _chestController, curve: Curves.bounceOut),
    );

    _chestScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.25), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 1), weight: 40),
    ]).animate(
      CurvedAnimation(parent: _chestController, curve: Curves.easeOut),
    );

    _shake = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(
        parent: _chestController,
        curve: const Interval(0.55, 0.75, curve: Curves.easeInOut),
      ),
    );

    _gemPopScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.4), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1), weight: 40),
    ]).animate(
      CurvedAnimation(parent: _gemPopController, curve: Curves.elasticOut),
    );

    _gemPopRotate = Tween<double>(begin: 0, end: math.pi * 2).animate(
      CurvedAnimation(parent: _gemPopController, curve: Curves.easeOut),
    );

    _badgePunchScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.45), weight: 50),
      TweenSequenceItem(
        tween: Tween(begin: 1.45, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
    ]).animate(_badgePunchController);

    _titleOpacity = CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOut,
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOutCubic),
    );
  }

  //==============================
  // Confetti physics
  //==============================

  void _spawnConfetti() {
    if (!mounted) return;

    final size = MediaQuery.of(context).size;
    final origin = Offset(size.width / 2, size.height / 2 - 40);
    final random = math.Random();

    const colors = [
      Color(0xFFFFD54F), // gold
      Color(0xFFFFFFFF), // white
      Color(0xFF64B5F6), // blue
      Color(0xFFFF8A65), // orange
      Color(0xFF81C784), // green
    ];

    _confetti.clear();

    for (var i = 0; i < 60; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final speed = 4 + random.nextDouble() * 9;

      _confetti.add(
        _ConfettiParticle(
          x: origin.dx,
          y: origin.dy,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed - 4,
          rotation: random.nextDouble() * math.pi,
          rotationSpeed: (random.nextDouble() - 0.5) * 0.35,
          opacity: 1,
          size: 6 + random.nextDouble() * 8,
          color: colors[random.nextInt(colors.length)],
        ),
      );
    }

    _confettiActive = true;
    _confettiTicker.start();
  }

  void _updateConfetti() {
    bool active = false;

    for (final p in _confetti) {
      if (p.opacity <= 0) continue;

      active = true;

      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.18; // gravity
      p.vx *= 0.985;
      p.rotation += p.rotationSpeed;
      p.opacity -= 0.012;
    }

    if (mounted) {
      setState(() {});
    }

    if (!active) {
      _confettiTicker.stop();
      _confettiActive = false;
    }
  }

  //==============================
  // Sequence
  //==============================

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // Hero moment: the chest crashes down.
    await _chestController.forward();
    if (!mounted) return;

    setState(() {
      _opened = true;
    });

    // Light + fireworks burst together for maximum impact.
    _spawnConfetti();
    await _flashController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _flashController.reset();

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // Gem pops out of the chest with a spin.
    setState(() {
      _showGemPop = true;
    });
    await _gemPopController.forward();
    if (!mounted) return;

    // Gem flies from the chest to the on-screen collector badge,
    // exactly like the star flying into the toolbar in VictoryScreen.
    await _startGemFlight();
    if (!mounted) return;

    // Hero title celebration text.
    await _titleController.forward();

    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    // العودة تلقائياً إلى خريطة العوالم.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const WorldMapScreen(),
      ),
      (route) => false,
    );
  }

  Future<void> _startGemFlight() async {
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    final size = MediaQuery.of(context).size;

    if (_chestKey.currentContext != null) {
      final box = _chestKey.currentContext!.findRenderObject() as RenderBox;
      _gemStart = box.localToGlobal(box.size.center(Offset.zero));
    } else {
      _gemStart = Offset(size.width / 2, size.height / 2);
    }

    if (_gemBadgeKey.currentContext != null) {
      final box = _gemBadgeKey.currentContext!.findRenderObject() as RenderBox;
      _gemEnd = box.localToGlobal(box.size.center(Offset.zero));
    } else {
      _gemEnd = Offset(size.width - 50, 40);
    }

    setState(() {
      _showGemPop = false;
      _showGemFlight = true;
    });

    _gemFlightController.reset();
    await _gemFlightController.forward();
    if (!mounted) return;

    setState(() {
      _showGemFlight = false;
    });

    // Grant the gem exactly once, right as it lands in the badge.
    if (!_gemAdded) {
      _gemAdded = true;
      RewardManager.addGems(1);
    }

    _badgePunchController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Deep hero-themed gradient backdrop.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff081A3A),
                  Color(0xff020611),
                ],
              ),
            ),
          ),

          // Pulsing golden spotlight behind the chest.
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              final glow = 0.15 + (_glowController.value * 0.25);
              return Container(
                width: 420,
                height: 420,
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

          // Firework / confetti burst.
          if (_confettiActive || _confetti.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ConfettiPainter(List.of(_confetti)),
                ),
              ),
            ),

          // الصندوق النهائي
          AnimatedBuilder(
            animation: _chestController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _chestDrop.value),
                child: Transform.scale(
                  scale: _chestScale.value,
                  child: Transform.rotate(
                    angle: _opened ? 0 : _shake.value,
                    child: Image.asset(
                      _opened
                          ? "assets/images/rewards/reward_chest_open.png"
                          : "assets/images/rewards/reward_chest_closed.png",
                      key: _chestKey,
                      width: 220,
                    ),
                  ),
                ),
              );
            },
          ),

          // الجوهرة تخرج من الصندوق وتدور
          if (_showGemPop)
            AnimatedBuilder(
              animation: _gemPopController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _gemPopRotate.value,
                  child: Transform.scale(
                    scale: _gemPopScale.value,
                    child: Image.asset(
                      "assets/images/rewards/gem.png",
                      width: 100,
                    ),
                  ),
                );
              },
            ),

          // الجوهرة تطير نحو شارة الجمع، تماماً كما تطير النجمة في VictoryScreen
          if (_showGemFlight)
            AnimatedBuilder(
              animation: _gemFlightController,
              builder: (context, child) {
                final t = Curves.easeInOutCubic.transform(
                  _gemFlightController.value,
                );

                final x = _gemStart.dx + (_gemEnd.dx - _gemStart.dx) * t;

                // Slight upward arc instead of a flat line, for a more
                // natural, energetic flight path.
                final arc = -80 * math.sin(math.pi * t);
                final y = _gemStart.dy +
                    (_gemEnd.dy - _gemStart.dy) * t +
                    arc;

                final scale = 1.0 - (t * 0.55);

                return Positioned(
                  left: x - 40,
                  top: y - 40,
                  child: Transform.scale(
                    scale: scale.clamp(0.4, 1.0),
                    child: Image.asset(
                      "assets/images/rewards/gem.png",
                      width: 80,
                    ),
                  ),
                );
              },
            ),

          // شارة جمع الجواهر — تمثل "الشريط" ضمن هذه الشاشة نفسها
          // (لا توجد GameToolbar هنا لأن هذه شاشة احتفالية مستقلة).
          Positioned(
            top: 40,
            right: 24,
            child: AnimatedBuilder(
              animation: _badgePunchController,
              builder: (context, child) {
                final scale = _badgePunchController.isAnimating ||
                        _badgePunchController.value > 0
                    ? _badgePunchScale.value
                    : 1.0;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    key: _gemBadgeKey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.amberAccent.withOpacity(0.6),
                      ),
                    ),
                    child: Image.asset(
                      "assets/images/rewards/gem.png",
                      width: 28,
                    ),
                  ),
                );
              },
            ),
          ),

          // نص البطولة
          FadeTransition(
            opacity: _titleOpacity,
            child: SlideTransition(
              position: _titleSlide,
              child: Padding(
                padding: const EdgeInsets.only(top: 260),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      "🏆 أنت بطل!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.amber,
                            blurRadius: 18,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "لقد أكملت جميع المراحل بنجاح",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // وميض الفتح
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _flashController,
                builder: (context, child) {
                  return Container(
                    color: Colors.white.withOpacity(_flashController.value),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _chestController.dispose();
    _flashController.dispose();
    _glowController.dispose();
    _gemPopController.dispose();
    _gemFlightController.dispose();
    _badgePunchController.dispose();
    _titleController.dispose();
    _confettiTicker.dispose();
    super.dispose();
  }
}

//======================================
// Confetti Painter
//======================================

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;

  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final p in particles) {
      if (p.opacity <= 0) continue;

      paint.color = p.color.withOpacity(p.opacity.clamp(0, 1));

      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}