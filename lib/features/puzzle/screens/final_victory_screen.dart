import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../managers/ads_manager.dart';
import '../managers/reward_manager.dart';
import '../widgets/game_toolbar.dart';
import 'world_map_screen.dart';

enum _RewardType { star, coin, gem }

class _FlightParticle {
  final GlobalKey key;
  final String asset;
  final double size;
  final Offset start;
  final Offset end;
  final double arcHeight;

  const _FlightParticle({
    required this.key,
    required this.asset,
    required this.size,
    required this.start,
    required this.end,
    required this.arcHeight,
  });
}

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
  final GlobalKey _starKey = GlobalKey();
  final GlobalKey _coinKey = GlobalKey();
  final GlobalKey _gemKey = GlobalKey();

  final GlobalKey _chestKey = GlobalKey();

  late final AudioPlayer _audioPlayer;

  late final AnimationController _bgController;
  late final Animation<double> _bgScale;
  late final Animation<double> _bgShift;

  late final AnimationController _chestController;
  late final Animation<double> _chestDrop;
  late final Animation<double> _chestScale;
  late final Animation<double> _chestShake;

  late final AnimationController _flashController;
  late final AnimationController _glowController;
  late final AnimationController _titleController;

  late final AnimationController _flightController;
  late final AnimationController _floatController;
  late final AnimationController _badgePunchController;

  late Ticker _confettiTicker;
  final List<_ConfettiParticle> _confetti = [];
  bool _confettiActive = false;

  bool _opened = false;
  bool _showChest = false;
  bool _showTitle = false;
  bool _showRewardFlights = false;
  bool _running = true;
  bool _doubleAsked = false;
  bool _adInProgress = false;

  final List<_RewardType> _rewardOrder = const [
    _RewardType.star,
    _RewardType.coin,
    _RewardType.gem,
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);

    _bgScale = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    _bgShift = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    _chestController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _chestDrop = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: -700.0, end: 0.0).chain(
          CurveTween(curve: Curves.easeInCubic),
        ),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -75.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -75.0, end: 0.0).chain(
          CurveTween(curve: Curves.bounceOut),
        ),
        weight: 30,
      ),
    ]).animate(_chestController);

    _chestScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.72, end: 1.22).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.22, end: 1.0),
        weight: 45,
      ),
    ]).animate(_chestController);

    _chestShake = Tween<double>(
      begin: -0.08,
      end: 0.08,
    ).animate(
      CurvedAnimation(
        parent: _chestController,
        curve: const Interval(0.62, 0.84, curve: Curves.easeInOut),
      ),
    );

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _badgePunchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _confettiTicker = createTicker((_) => _updateConfetti());

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _runSequence();
    });
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() {
      _showChest = true;
    });

    try {
      await _audioPlayer.play(AssetSource('audio/puzzle_win.mp3'));
    } catch (_) {}

    await _chestController.forward();
    if (!mounted) return;

    setState(() {
      _opened = true;
    });

    _spawnConfetti();
    _glowController.repeat(reverse: true);
    _flashController.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    setState(() {
      _showTitle = true;
    });
    _titleController.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    await _playRewardFlights(
      grantRewards: true,
      replayOnly: false,
    );
    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    await _showDoubleRewardDialog();

    if (!mounted) return;

    if (!_adInProgress) {
      _goHome();
    }
  }

  Future<void> _playRewardFlights({
    required bool grantRewards,
    required bool replayOnly,
  }) async {
    setState(() {
      _showRewardFlights = true;
    });

    await _waitForToolbarTargets();

    if (!mounted) return;

    for (final reward in _rewardOrder) {
      await _flyOneReward(reward);
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 120));
    }

    if (grantRewards && !replayOnly) {
      await RewardManager.addStars(1);
      await RewardManager.addCoins(100);
      await RewardManager.addGems(1);
    }

    _badgePunchController.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 120));

    if (mounted) {
      setState(() {
        _showRewardFlights = false;
      });
    }
  }

  Future<void> _flyOneReward(_RewardType type) async {
    final target = _rewardTarget(type);
    if (target == null) return;

    final start = _getChestCenter();
    final asset = _rewardAsset(type);
    final size = _rewardSize(type);
    final arc = _rewardArc(type);

    final particle = _FlightParticle(
      key: GlobalKey(),
      asset: asset,
      size: size,
      start: start,
      end: target,
      arcHeight: arc,
    );

    final overlayEntry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: _flightController,
          builder: (context, child) {
            final t = Curves.easeInOutCubic.transform(_flightController.value);
            final x = particle.start.dx + (particle.end.dx - particle.start.dx) * t;
            final y = particle.start.dy +
                (particle.end.dy - particle.start.dy) * t +
                (-particle.arcHeight * math.sin(math.pi * t));
            final scale = 1.0 - (t * 0.4);

            return Positioned(
              left: x - particle.size / 2,
              top: y - particle.size / 2,
              child: Transform.scale(
                scale: scale.clamp(0.55, 1.0),
                child: child,
              ),
            );
          },
          child: Image.asset(
            particle.asset,
            key: particle.key,
            width: particle.size,
            height: particle.size,
            fit: BoxFit.contain,
          ),
        );
      },
    );

    final overlay = Overlay.of(context);
    overlay.insert(overlayEntry);

    _flightController.reset();
    await _flightController.forward();

    overlayEntry.remove();
  }

  Offset? _rewardTarget(_RewardType type) {
    final key = switch (type) {
      _RewardType.star => _starKey,
      _RewardType.coin => _coinKey,
      _RewardType.gem => _gemKey,
    };

    final context = key.currentContext;
    if (context == null) return null;

    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;

    return box.localToGlobal(box.size.center(Offset.zero));
  }

  String _rewardAsset(_RewardType type) {
    return switch (type) {
      _RewardType.star => 'assets/images/rewards/Star_gold.png',
      _RewardType.coin => 'assets/images/rewards/puzzle_coin.png',
      _RewardType.gem => 'assets/images/rewards/gem.png',
    };
  }

  double _rewardSize(_RewardType type) {
    return switch (type) {
      _RewardType.star => 68,
      _RewardType.coin => 62,
      _RewardType.gem => 58,
    };
  }

  double _rewardArc(_RewardType type) {
    return switch (type) {
      _RewardType.star => 130,
      _RewardType.coin => 100,
      _RewardType.gem => 116,
    };
  }

  Offset _getChestCenter() {
    final ctx = _chestKey.currentContext;
    if (ctx == null) {
      return Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2);
    }
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2);
    }
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  Future<void> _waitForToolbarTargets() async {
    for (int i = 0; i < 60; i++) {
      if (!mounted) return;
      if (_starKey.currentContext != null &&
          _coinKey.currentContext != null &&
          _gemKey.currentContext != null) {
        return;
      }
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  void _spawnConfetti() {
    if (!mounted) return;

    final size = MediaQuery.of(context).size;
    final origin = Offset(size.width / 2, size.height / 2 - 30);
    final random = math.Random();

    const colors = [
      Color(0xFFFFD54F),
      Color(0xFFFFFFFF),
      Color(0xFF64B5F6),
      Color(0xFFFF8A65),
      Color(0xFF81C784),
    ];

    _confetti.clear();

    for (var i = 0; i < 64; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final speed = 4 + random.nextDouble() * 8;

      _confetti.add(
        _ConfettiParticle(
          x: origin.dx,
          y: origin.dy,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed - 4,
          rotation: random.nextDouble() * math.pi,
          rotationSpeed: (random.nextDouble() - 0.5) * 0.36,
          opacity: 1,
          size: 5 + random.nextDouble() * 8,
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
      p.vy += 0.17;
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

  Future<void> _showDoubleRewardDialog() async {
    if (_doubleAsked || _adInProgress) return;
    _doubleAsked = true;

    final wantDouble = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff1D1730),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            "🎁 مضاعفة المكافأة",
            style: TextStyle(color: Colors.amber),
          ),
          content: const Text(
            "يمكنك مضاعفة المكافأة عبر مشاهدة إعلان.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("لاحقاً"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("شاهد إعلان"),
            ),
          ],
        );
      },
    );

    if (wantDouble != true) {
      _goHome();
      return;
    }

    if (!AdsManager().isInitialized) {
      await AdsManager().initAds();
    }

    if (!mounted) return;

    setState(() {
      _adInProgress = true;
    });

    AdsManager().showRewardedAd(
      onRewardEarned: () async {
        await RewardManager.addStars(1);
        await RewardManager.addCoins(100);
        await RewardManager.addGems(1);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🎉 تمت مضاعفة المكافأة!"),
          ),
        );

        await _playRewardFlights(
          grantRewards: false,
          replayOnly: true,
        );

        if (!mounted) return;

        setState(() {
          _adInProgress = false;
        });

        _goHome();
      },
      onAdFailed: () {
        if (!mounted) return;

        setState(() {
          _adInProgress = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("الإعلان غير متوفر حالياً"),
          ),
        );

        _goHome();
      },
    );
  }

  void _goHome() {
    if (!_running || !mounted) return;
    _running = false;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WorldMapScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff06101E),
                    Color(0xff020509),
                  ],
                ),
              ),
              child: AnimatedBuilder(
                animation: _bgController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _bgShift.value),
                    child: Transform.scale(
                      scale: _bgScale.value,
                      child: child,
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Positioned(
                      left: -60,
                      top: 70,
                      child: _softGlow(180, Colors.blueAccent.withOpacity(0.10)),
                    ),
                    Positioned(
                      right: -40,
                      top: 160,
                      child: _softGlow(220, Colors.amber.withOpacity(0.10)),
                    ),
                    Positioned(
                      left: 30,
                      bottom: 140,
                      child: _softGlow(260, Colors.purpleAccent.withOpacity(0.08)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GameToolbar(
              starKey: _starKey,
              gemKey: _gemKey,
              coinKey: _coinKey,
              onExit: _goHome,
              soundEnabled: true,
            ),
          ),

          if (_showChest)
            Center(
              child: AnimatedBuilder(
                animation: _chestController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _chestDrop.value),
                    child: Transform.scale(
                      scale: _chestScale.value,
                      child: Transform.rotate(
                        angle: _opened ? 0 : _chestShake.value,
                        child: Container(
                          key: _chestKey,
                          width: 240,
                          height: 240,
                          alignment: Alignment.center,
                          child: Image.asset(
                            _opened
                                ? 'assets/images/rewards/reward_chest_open.png'
                                : 'assets/images/rewards/reward_chest_closed.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          if (_opened)
            IgnorePointer(
              child: Center(
                child: AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    final glow = 0.18 + (_glowController.value * 0.26);
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

          if (_confettiActive || _confetti.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _ConfettiPainter(List.of(_confetti)),
                ),
              ),
            ),

          if (_showTitle)
            Positioned(
              left: 24,
              right: 24,
              top: size.height * 0.18,
              child: FadeTransition(
                opacity: _titleController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _titleController,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        "لقد أكملت المرحلة العاشرة",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.amber,
                              blurRadius: 16,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "تم فتح عالمك بالكامل",
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

          if (_showRewardFlights)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    final bob = math.sin(_floatController.value * 2 * math.pi) * 4;
                    return Transform.translate(offset: Offset(0, bob), child: child);
                  },
                  child: const SizedBox.shrink(),
                ),
              ),
            ),

          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _flashController,
                builder: (context, child) {
                  return Container(
                    color: Colors.white.withOpacity(_flashController.value * 0.9),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _softGlow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _running = false;
    _audioPlayer.dispose();
    _bgController.dispose();
    _chestController.dispose();
    _flashController.dispose();
    _glowController.dispose();
    _titleController.dispose();
    _flightController.dispose();
    _floatController.dispose();
    _badgePunchController.dispose();

    if (_confettiTicker.isActive) {
      _confettiTicker.stop();
    }
    _confettiTicker.dispose();

    super.dispose();
  }
}

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
        Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.5,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
