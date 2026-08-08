import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../managers/ads_manager.dart';
import '../managers/reward_manager.dart';
import '../managers/app_language_manager.dart';
import '../widgets/game_toolbar.dart';
import 'world_map_screen.dart';

enum _RewardType {
  star,
  coin,
  gem,
}

/// ============================================================
/// ✈️ Reward flight particle
/// ============================================================

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

/// ============================================================
/// 🎉 Confetti particle
/// ============================================================

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

/// ============================================================
/// 🏆 FINAL VICTORY SCREEN
///
/// هذه الشاشة مخصصة للمرحلة العاشرة فقط.
///
/// المكافآت هنا:
/// ⭐ نجمة
/// 🪙 100 عملة
/// 💎 جوهرة
///
/// أما المراحل 1 - 9 فتتم مكافأتها من VictoryScreen.
/// ============================================================

class FinalVictoryScreen extends StatefulWidget {
  final dynamic island;

  const FinalVictoryScreen({
    super.key,
    required this.island,
  });

  @override
  State<FinalVictoryScreen> createState() =>
      _FinalVictoryScreenState();
}

class _FinalVictoryScreenState extends State<FinalVictoryScreen>
    with TickerProviderStateMixin {
  // ==========================================================
  // 🌐 Language
  // ==========================================================

  AppLanguageManager get _language =>
      AppLanguageManager.instance;

  // ==========================================================
  // 🎯 Toolbar targets
  // ==========================================================

  final GlobalKey _starKey = GlobalKey();
  final GlobalKey _coinKey = GlobalKey();
  final GlobalKey _gemKey = GlobalKey();

  final GlobalKey _chestKey = GlobalKey();

  // ==========================================================
  // 🔊 Audio
  // ==========================================================

  late final AudioPlayer _audioPlayer;

  // ==========================================================
  // 🌌 Background
  // ==========================================================

  late final AnimationController _bgController;
  late final Animation<double> _bgScale;
  late final Animation<double> _bgShift;

  // ==========================================================
  // 🎁 Chest
  // ==========================================================

  late final AnimationController _chestController;
  late final Animation<double> _chestDrop;
  late final Animation<double> _chestScale;
  late final Animation<double> _chestShake;

  // ==========================================================
  // ✨ Effects
  // ==========================================================

  late final AnimationController _flashController;
  late final AnimationController _glowController;
  late final AnimationController _titleController;

  // ==========================================================
  // ✈️ Reward flight
  // ==========================================================

  late final AnimationController _flightController;
  late final AnimationController _floatController;
  late final AnimationController _badgePunchController;

  // ==========================================================
  // 🎉 Confetti
  // ==========================================================

  late Ticker _confettiTicker;

  final List<_ConfettiParticle> _confetti = [];

  bool _confettiActive = false;

  // ==========================================================
  // 🎬 State
  // ==========================================================

  bool _opened = false;
  bool _showChest = false;
  bool _showTitle = false;
  bool _showRewardFlights = false;

  bool _running = true;

  bool _doubleAsked = false;
  bool _adInProgress = false;

  // ==========================================================
  // 🎁 Reward order
  // ==========================================================

  final List<_RewardType> _rewardOrder = const [
    _RewardType.star,
    _RewardType.coin,
    _RewardType.gem,
  ];

  // ==========================================================
  // 🚀 INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();

    // ----------------------------------------------------------
    // Background animation
    // ----------------------------------------------------------

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);

    _bgScale = Tween<double>(
      begin: 1.0,
      end: 1.04,
    ).animate(
      CurvedAnimation(
        parent: _bgController,
        curve: Curves.easeInOut,
      ),
    );

    _bgShift = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(
      CurvedAnimation(
        parent: _bgController,
        curve: Curves.easeInOut,
      ),
    );

    // ----------------------------------------------------------
    // Chest animation
    // ----------------------------------------------------------

    _chestController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _chestDrop = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: -700.0,
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
          end: -75.0,
        ).chain(
          CurveTween(
            curve: Curves.easeOut,
          ),
        ),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -75.0,
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
          begin: 0.72,
          end: 1.22,
        ).chain(
          CurveTween(
            curve: Curves.easeOutBack,
          ),
        ),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.22,
          end: 1.0,
        ),
        weight: 45,
      ),
    ]).animate(_chestController);

    _chestShake = Tween<double>(
      begin: -0.08,
      end: 0.08,
    ).animate(
      CurvedAnimation(
        parent: _chestController,
        curve: const Interval(
          0.62,
          0.84,
          curve: Curves.easeInOut,
        ),
      ),
    );

    // ----------------------------------------------------------
    // Other controllers
    // ----------------------------------------------------------

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 650,
      ),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1400,
      ),
    );

    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 900,
      ),
    );

    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 950,
      ),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1800,
      ),
    )..repeat();

    _badgePunchController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 420,
      ),
    );

    // ----------------------------------------------------------
    // Confetti ticker
    // ----------------------------------------------------------

    _confettiTicker = createTicker(
      (_) => _updateConfetti(),
    );

    // ----------------------------------------------------------
    // Start cinematic
    // ----------------------------------------------------------

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (!mounted) return;

        await _runSequence();
      },
    );
  }

  // ==========================================================
  // 🎬 Main sequence
  // ==========================================================

  Future<void> _runSequence() async {
    await Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
    );

    if (!mounted) return;

    setState(() {
      _showChest = true;
    });

    // ----------------------------------------------------------
    // Victory sound
    // ----------------------------------------------------------

    try {
      await _audioPlayer.play(
        AssetSource(
          'audio/puzzle_win.mp3',
        ),
      );
    } catch (_) {}

    // ----------------------------------------------------------
    // Chest falls
    // ----------------------------------------------------------

    await _chestController.forward();

    if (!mounted) return;

    // ----------------------------------------------------------
    // Open chest
    // ----------------------------------------------------------

    setState(() {
      _opened = true;
    });

    _spawnConfetti();

    _glowController.repeat(
      reverse: true,
    );

    _flashController.forward(
      from: 0,
    );

    // ----------------------------------------------------------
    // Title
    // ----------------------------------------------------------

    await Future.delayed(
      const Duration(
        milliseconds: 250,
      ),
    );

    if (!mounted) return;

    setState(() {
      _showTitle = true;
    });

    _titleController.forward(
      from: 0,
    );

    // ----------------------------------------------------------
    // Rewards
    // ----------------------------------------------------------

    await Future.delayed(
      const Duration(
        milliseconds: 450,
      ),
    );

    if (!mounted) return;

    await _playRewardFlights(
      grantRewards: true,
      replayOnly: false,
    );

    if (!mounted) return;

    // ----------------------------------------------------------
    // Double reward
    // ----------------------------------------------------------

    await Future.delayed(
      const Duration(
        milliseconds: 250,
      ),
    );

    if (!mounted) return;

    await _showDoubleRewardDialog();

    if (!mounted) return;

    if (!_adInProgress) {
      _goHome();
    }
  }

  // ==========================================================
  // ✈️ Play reward flights
  // ==========================================================

  Future<void> _playRewardFlights({
    required bool grantRewards,
    required bool replayOnly,
  }) async {
    if (!mounted) return;

    setState(() {
      _showRewardFlights = true;
    });

    await _waitForToolbarTargets();

    if (!mounted) return;

    for (final reward in _rewardOrder) {
      await _flyOneReward(reward);

      if (!mounted) return;

      await Future.delayed(
        const Duration(
          milliseconds: 120,
        ),
      );
    }

    // ========================================================
    // المرحلة العاشرة:
    // النجمة + العملات + الجوهرة
    // ========================================================

    if (grantRewards && !replayOnly) {
      await RewardManager.addStars(1);
      await RewardManager.addCoins(100);
      await RewardManager.addGems(1);
    }

    _badgePunchController.forward(
      from: 0,
    );

    await Future.delayed(
      const Duration(
        milliseconds: 120,
      ),
    );

    if (mounted) {
      setState(() {
        _showRewardFlights = false;
      });
    }
  }

  // ==========================================================
  // ✈️ Fly one reward
  // ==========================================================

  Future<void> _flyOneReward(
    _RewardType type,
  ) async {
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
            final t = Curves.easeInOutCubic.transform(
              _flightController.value,
            );

            final x =
                particle.start.dx +
                (particle.end.dx -
                        particle.start.dx) *
                    t;

            final y =
                particle.start.dy +
                (particle.end.dy -
                        particle.start.dy) *
                    t +
                (-particle.arcHeight *
                    math.sin(math.pi * t));

            final scale =
                1.0 - (t * 0.4);

            return Positioned(
              left: x -
                  particle.size / 2,
              top: y -
                  particle.size / 2,
              child: Transform.scale(
                scale: scale.clamp(
                  0.55,
                  1.0,
                ),
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

    overlay.insert(
      overlayEntry,
    );

    _flightController.reset();

    await _flightController.forward();

    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  }

  // ==========================================================
  // 🎯 Reward target
  // ==========================================================

  Offset? _rewardTarget(
    _RewardType type,
  ) {
    final key = switch (type) {
      _RewardType.star => _starKey,
      _RewardType.coin => _coinKey,
      _RewardType.gem => _gemKey,
    };

    final context = key.currentContext;

    if (context == null) return null;

    final box =
        context.findRenderObject()
            as RenderBox?;

    if (box == null || !box.hasSize) {
      return null;
    }

    return box.localToGlobal(
      box.size.center(
        Offset.zero,
      ),
    );
  }

  // ==========================================================
  // 🖼️ Reward assets
  // ==========================================================

  String _rewardAsset(
    _RewardType type,
  ) {
    return switch (type) {
      _RewardType.star =>
        'assets/images/rewards/Star_gold.png',

      _RewardType.coin =>
        'assets/images/rewards/puzzle_coin.png',

      _RewardType.gem =>
        'assets/images/rewards/gem.png',
    };
  }

  // ==========================================================
  // 📏 Reward sizes
  // ==========================================================

  double _rewardSize(
    _RewardType type,
  ) {
    return switch (type) {
      _RewardType.star => 68,
      _RewardType.coin => 62,
      _RewardType.gem => 58,
    };
  }

  // ==========================================================
  // 🌈 Reward arcs
  // ==========================================================

  double _rewardArc(
    _RewardType type,
  ) {
    return switch (type) {
      _RewardType.star => 130,
      _RewardType.coin => 100,
      _RewardType.gem => 116,
    };
  }

  // ==========================================================
  // 🎁 Chest center
  // ==========================================================

  Offset _getChestCenter() {
    final ctx =
        _chestKey.currentContext;

    final screen =
        MediaQuery.of(context).size;

    if (ctx == null) {
      return Offset(
        screen.width / 2,
        screen.height / 2,
      );
    }

    final box =
        ctx.findRenderObject()
            as RenderBox?;

    if (box == null || !box.hasSize) {
      return Offset(
        screen.width / 2,
        screen.height / 2,
      );
    }

    return box.localToGlobal(
      box.size.center(
        Offset.zero,
      ),
    );
  }

  // ==========================================================
  // ⏳ Wait toolbar
  // ==========================================================

  Future<void> _waitForToolbarTargets() async {
    for (int i = 0; i < 60; i++) {
      if (!mounted) return;

      if (_starKey.currentContext != null &&
          _coinKey.currentContext != null &&
          _gemKey.currentContext != null) {
        return;
      }

      await Future.delayed(
        const Duration(
          milliseconds: 50,
        ),
      );
    }
  }

  // ==========================================================
  // 🎉 Confetti
  // ==========================================================

  void _spawnConfetti() {
    if (!mounted) return;

    final size =
        MediaQuery.of(context).size;

    final origin = Offset(
      size.width / 2,
      size.height / 2 - 30,
    );

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
      final angle =
          random.nextDouble() *
              math.pi *
              2;

      final speed =
          4 +
          random.nextDouble() * 8;

      _confetti.add(
        _ConfettiParticle(
          x: origin.dx,
          y: origin.dy,
          vx: math.cos(angle) *
              speed,
          vy: math.sin(angle) *
                  speed -
              4,
          rotation:
              random.nextDouble() *
                  math.pi,
          rotationSpeed:
              (random.nextDouble() -
                      0.5) *
                  0.36,
          opacity: 1,
          size:
              5 +
              random.nextDouble() * 8,
          color:
              colors[
                  random.nextInt(
                    colors.length,
                  )],
        ),
      );
    }

    _confettiActive = true;

    _confettiTicker.start();
  }

  // ==========================================================
  // 🎉 Update confetti
  // ==========================================================

  void _updateConfetti() {
    bool active = false;

    for (final p in _confetti) {
      if (p.opacity <= 0) continue;

      active = true;

      p.x += p.vx;
      p.y += p.vy;

      p.vy += 0.17;

      p.vx *= 0.985;

      p.rotation +=
          p.rotationSpeed;

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

  // ==========================================================
  // 🎁 Double reward dialog
  // ==========================================================

  Future<void> _showDoubleRewardDialog() async {
    if (_doubleAsked ||
        _adInProgress) {
      return;
    }

    _doubleAsked = true;

    final wantDouble =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Directionality(
          textDirection:
              _language.textDirection,
          child: AlertDialog(
            backgroundColor:
                const Color(
              0xff1D1730,
            ),
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                22,
              ),
            ),
            title: Text(
              _language.text(
                ar: 'مضاعفة المكافأة',
                en: 'Double Reward',
              ),
              style:
                  const TextStyle(
                color: Colors.amber,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Text(
                  _language.text(
                    ar: 'شاهد إعلاناً للحصول على مكافأة إضافية.',
                    en: 'Watch an ad to receive an additional reward.',
                  ),
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                // ----------------------------------------------
                // Reward images instead of emojis
                // ----------------------------------------------

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    _RewardPreviewImage(
                      asset:
                          'assets/images/rewards/Star_gold.png',
                      size: 48,
                    ),

                    const SizedBox(
                      width: 14,
                    ),

                    _RewardPreviewImage(
                      asset:
                          'assets/images/rewards/puzzle_coin.png',
                      size: 48,
                    ),

                    const SizedBox(
                      width: 14,
                    ),

                    _RewardPreviewImage(
                      asset:
                          'assets/images/rewards/gem.png',
                      size: 46,
                    ),
                  ],
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  _language.text(
                    ar: 'نجمة + 100 عملة + جوهرة',
                    en: 'Star + 100 Coins + Gem',
                  ),
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
            actionsAlignment:
                MainAxisAlignment
                    .center,
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    false,
                  );
                },
                child: Text(
                  _language.text(
                    ar: 'لاحقاً',
                    en: 'Later',
                  ),
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                  ),
                ),
              ),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    true,
                  );
                },
                child: Text(
                  _language.text(
                    ar: 'شاهد الإعلان',
                    en: 'Watch Ad',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // ----------------------------------------------------------
    // User declined
    // ----------------------------------------------------------

    if (wantDouble != true) {
      _goHome();
      return;
    }

    // ----------------------------------------------------------
    // Initialize Ads
    // ----------------------------------------------------------

    if (!AdsManager()
        .isInitialized) {
      await AdsManager()
          .initAds();
    }

    if (!mounted) return;

    setState(() {
      _adInProgress = true;
    });

    // ----------------------------------------------------------
    // Rewarded Ad
    // ----------------------------------------------------------

    AdsManager().showRewardedAd(
      onRewardEarned: () async {
        // ======================================================
        // Double the FINAL rewards:
        //
        // ⭐ +1
        // 🪙 +100
        // 💎 +1
        // ======================================================

        await RewardManager.addStars(1);
        await RewardManager.addCoins(100);
        await RewardManager.addGems(1);

        if (!mounted) return;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              _language.text(
                ar: 'تمت مضاعفة المكافأة!',
                en: 'Reward doubled!',
              ),
            ),
          ),
        );

        // ------------------------------------------------------
        // Replay reward flight
        // ------------------------------------------------------

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

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content: Text(
              _language.text(
                ar: 'الإعلان غير متوفر حالياً',
                en: 'The ad is currently unavailable.',
              ),
            ),
          ),
        );

        _goHome();
      },
    );
  }

  // ==========================================================
  // 🏠 Go home
  // ==========================================================

  void _goHome() {
    if (!_running ||
        !mounted) {
      return;
    }

    _running = false;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const WorldMapScreen(),
      ),
      (route) => false,
    );
  }

  // ==========================================================
  // 🧱 BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final size =
        MediaQuery.of(context).size;

    return Directionality(
      textDirection:
          _language.textDirection,
      child: Scaffold(
        backgroundColor:
            Colors.transparent,
        body: Stack(
          children: [
            // ==================================================
            // 🌌 Background
            // ==================================================

            Positioned.fill(
              child: Container(
                decoration:
                    const BoxDecoration(
                  gradient:
                      LinearGradient(
                    begin:
                        Alignment.topCenter,
                    end:
                        Alignment.bottomCenter,
                    colors: [
                      Color(
                        0xff06101E,
                      ),
                      Color(
                        0xff020509,
                      ),
                    ],
                  ),
                ),
                child:
                    AnimatedBuilder(
                  animation:
                      _bgController,
                  builder:
                      (context, child) {
                    return Transform
                        .translate(
                      offset: Offset(
                        0,
                        _bgShift.value,
                      ),
                      child:
                          Transform.scale(
                        scale:
                            _bgScale.value,
                        child:
                            child,
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      Positioned(
                        left: -60,
                        top: 70,
                        child:
                            _softGlow(
                          180,
                          Colors
                              .blueAccent
                              .withOpacity(
                            0.10,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -40,
                        top: 160,
                        child:
                            _softGlow(
                          220,
                          Colors.amber
                              .withOpacity(
                            0.10,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 30,
                        bottom: 140,
                        child:
                            _softGlow(
                          260,
                          Colors
                              .purpleAccent
                              .withOpacity(
                            0.08,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ==================================================
            // 🧭 Toolbar
            // ==================================================

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: GameToolbar(
                starKey:
                    _starKey,
                gemKey:
                    _gemKey,
                coinKey:
                    _coinKey,
                onExit:
                    _goHome,
                soundEnabled:
                    true,
              ),
            ),

            // ==================================================
            // 🎁 Chest
            // ==================================================

            if (_showChest)
              Center(
                child:
                    AnimatedBuilder(
                  animation:
                      _chestController,
                  builder:
                      (context, child) {
                    return Transform
                        .translate(
                      offset: Offset(
                        0,
                        _chestDrop.value,
                      ),
                      child:
                          Transform.scale(
                        scale:
                            _chestScale.value,
                        child:
                            Transform.rotate(
                          angle: _opened
                              ? 0
                              : _chestShake
                                  .value,
                          child:
                              Container(
                            key:
                                _chestKey,
                            width: 240,
                            height: 240,
                            alignment:
                                Alignment
                                    .center,
                            child:
                                Image.asset(
                              _opened
                                  ? 'assets/images/rewards/reward_chest_open.png'
                                  : 'assets/images/rewards/reward_chest_closed.png',
                              fit: BoxFit
                                  .contain,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // ==================================================
            // ✨ Glow
            // ==================================================

            if (_opened)
              IgnorePointer(
                child: Center(
                  child:
                      AnimatedBuilder(
                    animation:
                        _glowController,
                    builder:
                        (context, child) {
                      final glow =
                          0.18 +
                          (_glowController
                                  .value *
                              0.26);

                      return Container(
                        width: 460,
                        height: 460,
                        decoration:
                            BoxDecoration(
                          shape:
                              BoxShape
                                  .circle,
                          gradient:
                              RadialGradient(
                            colors: [
                              Colors
                                  .amber
                                  .withOpacity(
                                glow,
                              ),
                              Colors
                                  .transparent,
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // ==================================================
            // 🎉 Confetti
            // ==================================================

            if (_confettiActive ||
                _confetti.isNotEmpty)
              Positioned.fill(
                child:
                    IgnorePointer(
                  child:
                      CustomPaint(
                    painter:
                        _ConfettiPainter(
                      List.of(
                        _confetti,
                      ),
                    ),
                  ),
                ),
              ),

            // ==================================================
            // 🏆 Title
            // ==================================================

            if (_showTitle)
              Positioned(
                left: 24,
                right: 24,
                top:
                    size.height *
                        0.18,
                child:
                    FadeTransition(
                  opacity:
                      _titleController,
                  child:
                      SlideTransition(
                    position:
                        Tween<Offset>(
                      begin:
                          const Offset(
                        0,
                        0.2,
                      ),
                      end:
                          Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent:
                            _titleController,
                        curve:
                            Curves
                                .easeOutCubic,
                      ),
                    ),
                    child:
                        Column(
                      mainAxisSize:
                          MainAxisSize
                              .min,
                      children: [
                        Text(
                          _language.text(
                            ar: 'لقد أكملت المرحلة العاشرة',
                            en: 'You completed Level 10',
                          ),
                          textAlign:
                              TextAlign
                                  .center,
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 28,
                            fontWeight:
                                FontWeight
                                    .bold,
                            shadows: [
                              Shadow(
                                color:
                                    Colors
                                        .amber,
                                blurRadius:
                                    16,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          _language.text(
                            ar: 'تم فتح عالمك بالكامل',
                            en: 'Your world is now fully unlocked',
                          ),
                          textAlign:
                              TextAlign
                                  .center,
                          style:
                              const TextStyle(
                            color:
                                Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ==================================================
            // ✈️ Reward floating layer
            // ==================================================

            if (_showRewardFlights)
              Positioned.fill(
                child:
                    IgnorePointer(
                  child:
                      AnimatedBuilder(
                    animation:
                        _floatController,
                    builder:
                        (context, child) {
                      final bob =
                          math.sin(
                                _floatController
                                    .value *
                                    2 *
                                    math.pi,
                              ) *
                              4;

                      return Transform
                          .translate(
                        offset:
                            Offset(
                          0,
                          bob,
                        ),
                        child:
                            child,
                      );
                    },
                    child:
                        const SizedBox
                            .shrink(),
                  ),
                ),
              ),

            // ==================================================
            // ⚡ Flash
            // ==================================================

            Positioned.fill(
              child:
                  IgnorePointer(
                child:
                    AnimatedBuilder(
                  animation:
                      _flashController,
                  builder:
                      (context, child) {
                    return Container(
                      color: Colors
                          .white
                          .withOpacity(
                        _flashController
                                .value *
                            0.9,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // 🌟 Soft glow
  // ==========================================================

  Widget _softGlow(
    double size,
    Color color,
  ) {
    return Container(
      width: size,
      height: size,
      decoration:
          BoxDecoration(
        shape:
            BoxShape.circle,
        gradient:
            RadialGradient(
          colors: [
            color,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // 🖼️ Reward preview image
  // ==========================================================

  Widget _RewardPreviewImage({
    required String asset,
    required double size,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
      ),
    );
  }

  // ==========================================================
  // 🧹 Dispose
  // ==========================================================

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

// ============================================================
// 🎉 Confetti painter
// ============================================================

class _ConfettiPainter
    extends CustomPainter {
  final List<_ConfettiParticle>
      particles;

  _ConfettiPainter(
    this.particles,
  );

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint();

    for (final p in particles) {
      if (p.opacity <= 0) {
        continue;
      }

      paint.color =
          p.color.withOpacity(
        p.opacity.clamp(
          0,
          1,
        ),
      );

      canvas.save();

      canvas.translate(
        p.x,
        p.y,
      );

      canvas.rotate(
        p.rotation,
      );

      canvas.drawRect(
        Rect.fromCenter(
          center:
              Offset.zero,
          width:
              p.size,
          height:
              p.size * 0.5,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(
    covariant _ConfettiPainter
        oldDelegate,
  ) {
    return true;
  }
}