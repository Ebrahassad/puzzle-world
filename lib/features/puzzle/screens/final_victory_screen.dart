import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../engine/puzzle_generator.dart';
import '../engine/puzzle_piece.dart';
import '../managers/ads_manager.dart';
import '../managers/reward_manager.dart';
import '../models/puzzle_model.dart';
import 'world_map_screen.dart';

enum _RewardKind { coins, stars, gems }

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

class _FlyingReward {
  final _RewardKind kind;
  final int amount;
  final String assetPath;
  final Offset start;
  final Offset end;
  final double arcHeight;
  final double delay;
  final double rotationTurns;
  final double scale;

  const _FlyingReward({
    required this.kind,
    required this.amount,
    required this.assetPath,
    required this.start,
    required this.end,
    required this.arcHeight,
    required this.delay,
    required this.rotationTurns,
    required this.scale,
  });
}

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

  _PieceExplosionData(this.piece) : position = piece.correctPosition;
}

class FinalVictoryScreen extends StatefulWidget {
  final PuzzleModel? island;

  const FinalVictoryScreen({
    super.key,
    required this.island,
  });

  @override
  State<FinalVictoryScreen> createState() => _FinalVictoryScreenState();
}

class _FinalVictoryScreenState extends State<FinalVictoryScreen>
    with TickerProviderStateMixin {
  static const int _kChestPhaseMs = 2500;
  static const int _kConfettiPhaseMs = 2200;
  static const int _kHeroTextDelayMs = 500;

  static const int _baseCoins = 100;
  static const int _baseStars = 1;
  static const int _baseGems = 1;

  late final AudioPlayer _audioPlayer;

  late final AnimationController _chestController;
  late final Animation<double> _chestDrop;
  late final Animation<double> _chestScale;
  late final Animation<double> _shake;

  late final AnimationController _flashController;
  late final AnimationController _glowController;
  late final AnimationController _titleController;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final AnimationController _badgePunchController;
  late final Animation<double> _badgePunchScale;

  late final AnimationController _flightController;

  late final Ticker _confettiTicker;
  final List<_ConfettiParticle> _confetti = [];
  bool _confettiActive = false;

  late final Ticker _physicsTicker;
  double _lastElapsedMs = 0;

  List<PuzzlePiece> _pieces = [];
  List<_PieceExplosionData> _explosionPieces = [];

  bool _opened = false;
  bool _showChest = false;
  bool _showHeroText = false;
  bool _showFlight = false;
  bool _isBusy = false;
  bool _hasFinished = false;
  bool _doubleRewardAsked = false;

  Offset _chestCenter = Offset.zero;

  final GlobalKey _chestKey = GlobalKey();
  final GlobalKey _coinBadgeKey = GlobalKey();
  final GlobalKey _starBadgeKey = GlobalKey();
  final GlobalKey _gemBadgeKey = GlobalKey();

  int _coins = 0;
  int _stars = 0;
  int _gems = 0;

  final List<_FlyingReward> _flightRewards = [];

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();

    _physicsTicker = createTicker(_updateExplosion);
    _confettiTicker = createTicker((_) => _updateConfetti());

    _chestController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _badgePunchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _chestDrop = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: -680.0, end: 0.0).chain(
          CurveTween(curve: Curves.easeInCubic),
        ),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: -60.0).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween(begin: -60.0, end: 0.0).chain(
          CurveTween(curve: Curves.bounceOut),
        ),
        weight: 28,
      ),
    ]).animate(_chestController);

    _chestScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.68, end: 1.22).chain(
          CurveTween(curve: Curves.easeOutBack),
        ),
        weight: 58,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.22, end: 1.0),
        weight: 42,
      ),
    ]).animate(_chestController);

    _shake = Tween<double>(
      begin: -0.08,
      end: 0.08,
    ).animate(
      CurvedAnimation(
        parent: _chestController,
        curve: const Interval(0.56, 0.82, curve: Curves.easeInOut),
      ),
    );

    _titleOpacity = CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeOut,
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.24),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: Curves.easeOutCubic,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _loadWallet();
      _preparePieces();
      await _startSequence();
    });
  }

  Future<void> _loadWallet() async {
    try {
      final reward = await RewardManager.getReward();
      if (!mounted) return;
      setState(() {
        _coins = reward.coins;
        _stars = reward.stars;
        _gems = reward.gems;
      });
    } catch (_) {}
  }

  void _preparePieces() {
    _pieces = PuzzleGenerator.generate(
      image: ui.Image(1, 1), // not used in this screen; kept for API safety
      rows: 1,
      cols: 1,
      boardRect: const Rect.fromLTWH(0, 0, 1, 1),
      scatterArea: const Rect.fromLTWH(0, 0, 1, 1),
      seed: 1,
    );

    _explosionPieces = [];
    setState(() {});
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;

    await _chestController.forward();
    if (!mounted) return;

    setState(() {
      _opened = true;
      _showChest = true;
    });

    try {
      await _audioPlayer.play(AssetSource('audio/puzzle_reward.mp3'));
    } catch (_) {}

    _spawnConfetti();
    await _flashController.forward();
    await Future.delayed(const Duration(milliseconds: 140));
    if (!mounted) return;
    _flashController.reset();

    await Future.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    _captureChestCenter();

    await _playRewardFlightOnce();

    if (!mounted) return;

    await _offerDoubleReward();

    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 850));
    if (!mounted) return;

    await _showHeroTextSequence();

    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    await _returnToWorldMap();
  }

  void _captureChestCenter() {
    final size = MediaQuery.of(context).size;
    if (_chestKey.currentContext != null) {
      final box = _chestKey.currentContext!.findRenderObject() as RenderBox;
      _chestCenter = box.localToGlobal(box.size.center(Offset.zero));
    } else {
      _chestCenter = Offset(size.width / 2, size.height / 2);
    }
  }

  Offset _centerOf(GlobalKey key, Offset fallback) {
    if (key.currentContext == null) return fallback;
    final renderObject = key.currentContext!.findRenderObject();
    if (renderObject is! RenderBox) return fallback;
    return renderObject.localToGlobal(renderObject.size.center(Offset.zero));
  }

  Future<void> _playRewardFlightOnce() async {
    if (_isBusy) return;
    _isBusy = true;

    final coinEnd = _centerOf(
      _coinBadgeKey,
      Offset(MediaQuery.of(context).size.width - 170, 34),
    );
    final starEnd = _centerOf(
      _starBadgeKey,
      Offset(MediaQuery.of(context).size.width - 112, 34),
    );
    final gemEnd = _centerOf(
      _gemBadgeKey,
      Offset(MediaQuery.of(context).size.width - 54, 34),
    );

    final coinStart = _chestCenter + const Offset(-36, 10);
    final starStart = _chestCenter + const Offset(0, -8);
    final gemStart = _chestCenter + const Offset(36, 10);

    _flightRewards
      ..clear()
      ..addAll([
        _FlyingReward(
          kind: _RewardKind.coins,
          amount: _baseCoins,
          assetPath: 'assets/images/rewards/puzzle_coin.png',
          start: coinStart,
          end: coinEnd,
          arcHeight: 140,
          delay: 0.00,
          rotationTurns: 1.2,
          scale: 1.0,
        ),
        _FlyingReward(
          kind: _RewardKind.stars,
          amount: _baseStars,
          assetPath: 'assets/images/rewards/Star_gold.png',
          start: starStart,
          end: starEnd,
          arcHeight: 125,
          delay: 0.06,
          rotationTurns: 1.0,
          scale: 1.0,
        ),
        _FlyingReward(
          kind: _RewardKind.gems,
          amount: _baseGems,
          assetPath: 'assets/images/rewards/gem.png',
          start: gemStart,
          end: gemEnd,
          arcHeight: 150,
          delay: 0.12,
          rotationTurns: 1.4,
          scale: 1.0,
        ),
      ]);

    if (mounted) {
      setState(() {
        _showFlight = true;
      });
    }

    _flightController.reset();
    await _flightController.forward();

    if (!mounted) return;

    await Future.wait([
      RewardManager.addCoins(_baseCoins),
      RewardManager.addStars(_baseStars),
      RewardManager.addGems(_baseGems),
    ]);

    await _loadWallet();

    if (!mounted) return;

    _badgePunchController.forward(from: 0);

    setState(() {
      _showFlight = false;
    });

    _isBusy = false;
  }

  Future<void> _offerDoubleReward() async {
    if (_doubleRewardAsked) return;
    _doubleRewardAsked = true;

    final wantsDouble = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1B1430),
          title: const Text(
            "🎁 مضاعفة المكافأة",
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "شاهد إعلاناً واحصل على نفس الحركة مرة أخرى.",
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("لاحقاً"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("📺 مضاعفة"),
            ),
          ],
        );
      },
    );

    if (wantsDouble != true) return;

    if (!AdsManager().isInitialized) {
      await AdsManager().initAds();
    }

    final completer = Completer<void>();

    AdsManager().showRewardedAd(
      onRewardEarned: () async {
        if (!mounted) {
          if (!completer.isCompleted) completer.complete();
          return;
        }

        await _playRewardFlightOnce();

        if (!mounted) {
          if (!completer.isCompleted) completer.complete();
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🎉 تمت مضاعفة المكافأة!"),
          ),
        );

        if (!completer.isCompleted) completer.complete();
      },
      onAdFailed: () {
        if (!mounted) {
          if (!completer.isCompleted) completer.complete();
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("الإعلان غير متوفر حالياً"),
          ),
        );

        if (!completer.isCompleted) completer.complete();
      },
    );

    await completer.future;
  }

  Future<void> _showHeroTextSequence() async {
    if (!mounted) return;

    setState(() {
      _showHeroText = true;
    });

    await _titleController.forward(from: 0);
  }

  Future<void> _returnToWorldMap() async {
    if (_hasFinished) return;
    _hasFinished = true;

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const WorldMapScreen(),
      ),
      (route) => false,
    );
  }

  void _spawnConfetti() {
    if (!mounted) return;

    final size = MediaQuery.of(context).size;
    final origin = Offset(size.width / 2, size.height / 2 - 40);
    final random = math.Random();

    const colors = [
      Color(0xFFFFD54F),
      Color(0xFFFFFFFF),
      Color(0xFFFFE082),
      Color(0xFF64B5F6),
      Color(0xFF81C784),
      Color(0xFFFF8A65),
    ];

    _confetti.clear();

    for (var i = 0; i < 72; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final speed = 3.5 + random.nextDouble() * 8.5;

      _confetti.add(
        _ConfettiParticle(
          x: origin.dx,
          y: origin.dy,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed - 4,
          rotation: random.nextDouble() * math.pi,
          rotationSpeed: (random.nextDouble() - 0.5) * 0.35,
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
      p.vy += 0.18;
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

  void _updateExplosion(Duration elapsed) {
    final elapsedMs = elapsed.inMilliseconds.toDouble();
    final dt = ((elapsedMs - _lastElapsedMs) / (1000 / 60)).clamp(0.2, 3.0);
    _lastElapsedMs = elapsedMs;

    final fadeT = (elapsedMs / _kConfettiPhaseMs).clamp(0.0, 1.0);
    final targetOpacity = 1.0 - Curves.easeOut.transform(fadeT);

    for (final data in _explosionPieces) {
      data.position += Offset(
        data.vx * dt,
        data.vy * dt,
      );

      data.vy += data.gravity * dt;

      data.rotation += data.rotationSpeed * dt;
      data.opacity = targetOpacity;
      data.scale = math.max(0.82, data.scale - 0.0006 * dt);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: _buildBackground(size)),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: 16,
                  right: 16,
                  top: 10,
                  child: AnimatedBuilder(
                    animation: _badgePunchController,
                    builder: (context, child) {
                      final scale = _badgePunchController.isAnimating
                          ? _badgePunchScale.value
                          : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: _RewardBadge(
                            key: _coinBadgeKey,
                            title: "العملات",
                            value: _coins,
                            assetPath: 'assets/images/rewards/puzzle_coin.png',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _RewardBadge(
                            key: _starBadgeKey,
                            title: "النجوم",
                            value: _stars,
                            assetPath: 'assets/images/rewards/Star_gold.png',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _RewardBadge(
                            key: _gemBadgeKey,
                            title: "الجواهر",
                            value: _gems,
                            assetPath: 'assets/images/rewards/gem.png',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_showChest)
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
                                          ? 'assets/images/rewards/reward_chest_open.png'
                                          : 'assets/images/rewards/reward_chest_closed.png',
                                      key: _chestKey,
                                      width: 240,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                        AnimatedBuilder(
                          animation: _glowController,
                          builder: (context, child) {
                            final glow = 0.14 + (_glowController.value * 0.24);
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

                        if (_confettiActive || _confetti.isNotEmpty)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _ConfettiPainter(List.of(_confetti)),
                            ),
                          ),

                        if (_showFlight)
                          AnimatedBuilder(
                            animation: _flightController,
                            builder: (context, child) {
                              final overallT = Curves.easeInOutCubic.transform(
                                _flightController.value,
                              );

                              return Stack(
                                children: [
                                  for (final reward in _flightRewards)
                                    _buildFlyingReward(reward, overallT),
                                ],
                              );
                            },
                          ),

                        if (_showHeroText)
                          FadeTransition(
                            opacity: _titleOpacity,
                            child: SlideTransition(
                              position: _titleSlide,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 270),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.island?.id == null
                                          ? "لقد أكملت اللعبة!"
                                          : "لقد أكملت ${widget.island!.id}!",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Colors.amber,
                                            blurRadius: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "استمر لفتح مزايا جديدة!",
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(Size size) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF091A36),
            Color(0xFF040814),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            left: -40,
            child: _blurOrb(const Color(0xFFFFD54F).withOpacity(0.18), 230),
          ),
          Positioned(
            top: 120,
            right: -70,
            child: _blurOrb(const Color(0xFF64B5F6).withOpacity(0.14), 260),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: _blurOrb(const Color(0xFF81C784).withOpacity(0.10), 240),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _StarDustPainter(),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blurOrb(Color color, double size) {
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

  Widget _buildFlyingReward(_FlyingReward reward, double overallT) {
    final startT = ((overallT - reward.delay) / (1.0 - reward.delay))
        .clamp(0.0, 1.0);
    final t = Curves.easeInOutCubic.transform(startT);

    if (startT <= 0) {
      return const SizedBox.shrink();
    }

    final x = ui.lerpDouble(reward.start.dx, reward.end.dx, t) ?? reward.end.dx;
    final baseY =
        ui.lerpDouble(reward.start.dy, reward.end.dy, t) ?? reward.end.dy;
    final arc = -reward.arcHeight * math.sin(math.pi * t);
    final y = baseY + arc;

    final scale = (reward.scale - (t * 0.45)).clamp(0.45, 1.0);
    final rotation = reward.rotationTurns * math.pi * 2 * t;

    return Positioned(
      left: x - 34,
      top: y - 34,
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: 0.95,
            child: Image.asset(
              reward.assetPath,
              width: 68,
              height: 68,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();

    if (_physicsTicker.isActive) {
      _physicsTicker.stop();
    }
    if (_confettiTicker.isActive) {
      _confettiTicker.stop();
    }

    _physicsTicker.dispose();
    _confettiTicker.dispose();

    _chestController.dispose();
    _flashController.dispose();
    _glowController.dispose();
    _titleController.dispose();
    _badgePunchController.dispose();
    _flightController.dispose();

    super.dispose();
  }
}

class _RewardBadge extends StatelessWidget {
  final String title;
  final int value;
  final String assetPath;

  const _RewardBadge({
    super.key,
    required this.title,
    required this.value,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.amber.withOpacity(0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            assetPath,
            width: 28,
            height: 28,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value.toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StarDustPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint();

    for (var i = 0; i < 120; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final r = 0.8 + random.nextDouble() * 1.6;
      final opacity = 0.10 + random.nextDouble() * 0.18;

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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