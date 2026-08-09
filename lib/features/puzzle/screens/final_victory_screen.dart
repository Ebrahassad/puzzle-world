import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../managers/ads_manager.dart';
import '../managers/reward_manager.dart';
import 'world_map_screen.dart';

enum _RewardType {
  star,
  coin,
  gem,
}

/// ============================================================
/// ✈️ جسيم حركة المكافأة
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
/// 🎉 جسيمات القصاصات الورقية
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
/// 🏆 شاشة الفوز النهائية
///
/// المرحلة العاشرة فقط.
///
/// المكافآت:
/// ⭐ نجمة
/// 🪙 100 عملة
/// 💎 جوهرة
///
/// لا يوجد أي نظام لغة خارجي هنا.
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
  // 🎯 أهداف المكافآت في الشريط العلوي
  // ==========================================================

  final GlobalKey _starKey = GlobalKey();
  final GlobalKey _coinKey = GlobalKey();
  final GlobalKey _gemKey = GlobalKey();

  // ==========================================================
  // 🎁 الصندوق
  // ==========================================================

  final GlobalKey _chestKey = GlobalKey();

  // ==========================================================
  // 🔊 الصوت
  // ==========================================================

  late final AudioPlayer _audioPlayer;

  // ==========================================================
  // 🌌 الخلفية
  // ==========================================================

  late final AnimationController _bgController;
  late final Animation<double> _bgScale;
  late final Animation<double> _bgShift;

  // ==========================================================
  // 🎁 حركة الصندوق
  // ==========================================================

  late final AnimationController _chestController;
  late final Animation<double> _chestDrop;
  late final Animation<double> _chestScale;
  late final Animation<double> _chestShake;

  // ==========================================================
  // ✨ المؤثرات
  // ==========================================================

  late final AnimationController _flashController;
  late final AnimationController _glowController;
  late final AnimationController _titleController;

  // ==========================================================
  // ✈️ حركة المكافآت
  // ==========================================================

  late final AnimationController _flightController;
  late final AnimationController _floatController;
  late final AnimationController _badgePunchController;

  // ==========================================================
  // 🎉 القصاصات
  // ==========================================================

  late Ticker _confettiTicker;

  final List<_ConfettiParticle> _confetti = [];

  // ==========================================================
  // 🎬 الحالة
  // ==========================================================

  bool _opened = false;
  bool _showChest = false;
  bool _showTitle = false;
  bool _showRewardFlights = false;

  bool _running = true;

  bool _doubleAsked = false;
  bool _adInProgress = false;

  // ==========================================================
  // 🎁 ترتيب المكافآت
  // ==========================================================

  final List<_RewardType> _rewardOrder = const [
    _RewardType.star,
    _RewardType.coin,
    _RewardType.gem,
  ];

  // ==========================================================
  // 🚀 البداية
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _audioPlayer = AudioPlayer();

    // ----------------------------------------------------------
    // حركة الخلفية
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
    // حركة الصندوق
    // ----------------------------------------------------------

    _chestController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _chestDrop = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -700,
          end: 0,
        ).chain(
          CurveTween(
            curve: Curves.easeInCubic,
          ),
        ),
        weight: 55,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0,
          end: -75,
        ).chain(
          CurveTween(
            curve: Curves.easeOut,
          ),
        ),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -75,
          end: 0,
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
        tween: Tween<double>(
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
        tween: Tween<double>(
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
    // المؤثرات
    // ----------------------------------------------------------

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

    // ----------------------------------------------------------
    // القصاصات
    // ----------------------------------------------------------

    _confettiTicker = createTicker(
      (_) => _updateConfetti(),
    );

    // ----------------------------------------------------------
    // تشغيل المشهد
    // ----------------------------------------------------------

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (!mounted) return;
        await _runSequence();
      },
    );
  }

  // ==========================================================
  // 🎬 التسلسل الرئيسي
  // ==========================================================

  Future<void> _runSequence() async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) return;

    setState(() {
      _showChest = true;
    });

    try {
      await _audioPlayer.play(
        AssetSource('audio/puzzle_win.mp3'),
      );
    } catch (_) {}

    await _chestController.forward();

    if (!mounted) return;

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

    await Future.delayed(
      const Duration(milliseconds: 250),
    );

    if (!mounted) return;

    setState(() {
      _showTitle = true;
    });

    _titleController.forward(
      from: 0,
    );

    await Future.delayed(
      const Duration(milliseconds: 450),
    );

    if (!mounted) return;

    await _playRewardFlights(
      grantRewards: true,
      replayOnly: false,
    );

    if (!mounted) return;

    await Future.delayed(
      const Duration(milliseconds: 250),
    );

    if (!mounted) return;

    await _showDoubleRewardDialog();

    if (!mounted) return;

    if (!_adInProgress) {
      _goHome();
    }
  }

  // ==========================================================
  // ✈️ تشغيل حركات المكافآت
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
        const Duration(milliseconds: 120),
      );
    }

    if (grantRewards && !replayOnly) {
      await RewardManager.addStars(1);
      await RewardManager.addCoins(100);
      await RewardManager.addGems(1);
    }

    _badgePunchController.forward(
      from: 0,
    );

    await Future.delayed(
      const Duration(milliseconds: 120),
    );

    if (mounted) {
      setState(() {
        _showRewardFlights = false;
      });
    }
  }

  // ==========================================================
  // ✈️ تحليق مكافأة واحدة
  // ==========================================================

  Future<void> _flyOneReward(
    _RewardType type,
  ) async {
    final target = _rewardTarget(type);

    if (target == null) return;

    final particle = _FlightParticle(
      key: GlobalKey(),
      asset: _rewardAsset(type),
      size: _rewardSize(type),
      start: _getChestCenter(),
      end: target,
      arcHeight: _rewardArc(type),
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
                    t -
                particle.arcHeight *
                    math.sin(math.pi * t);

            final scale =
                (1.0 - (t * 0.4)).clamp(
              0.55,
              1.0,
            );

            return Positioned(
              left:
                  x - particle.size / 2,
              top:
                  y - particle.size / 2,
              child: Transform.scale(
                scale: scale,
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

    if (overlayEntry.mounted) {
      overlayEntry.remove();
    }
  }

  // ==========================================================
  // 🎯 هدف المكافأة
  // ==========================================================

  Offset? _rewardTarget(
    _RewardType type,
  ) {
    final key = switch (type) {
      _RewardType.star => _starKey,
      _RewardType.coin => _coinKey,
      _RewardType.gem => _gemKey,
    };

    final targetContext = key.currentContext;

    if (targetContext == null) return null;

    final box =
        targetContext.findRenderObject() as RenderBox?;

    if (box == null || !box.hasSize) {
      return null;
    }

    return box.localToGlobal(
      box.size.center(Offset.zero),
    );
  }

  // ==========================================================
  // 🖼️ أصول المكافآت
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
  // 📏 أحجام المكافآت
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
  // 🌈 أقواس الحركة
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
  // 🎁 مركز الصندوق
  // ==========================================================

  Offset _getChestCenter() {
    final targetContext =
        _chestKey.currentContext;

    final screen =
        MediaQuery.of(context).size;

    if (targetContext == null) {
      return Offset(
        screen.width / 2,
        screen.height / 2,
      );
    }

    final box =
        targetContext.findRenderObject()
            as RenderBox?;

    if (box == null || !box.hasSize) {
      return Offset(
        screen.width / 2,
        screen.height / 2,
      );
    }

    return box.localToGlobal(
      box.size.center(Offset.zero),
    );
  }

  // ==========================================================
  // ⏳ انتظار أهداف المكافآت
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
        const Duration(milliseconds: 50),
      );
    }
  }

  // ==========================================================
  // 🎉 إنشاء القصاصات
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
          vx:
              math.cos(angle) * speed,
          vy:
              math.sin(angle) * speed -
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

    _confettiTicker.start();
  }

  // ==========================================================
  // 🎉 تحديث القصاصات
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
    }
  }

  // ==========================================================
  // 🎁 نافذة مضاعفة المكافأة
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
        return const Directionality(
          textDirection: TextDirection.rtl,
          child:
              _DoubleRewardDialogContent(),
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

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'تمت مضاعفة المكافأة!',
            ),
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

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'الإعلان غير متوفر حالياً',
            ),
          ),
        );

        _goHome();
      },
    );
  }

  // ==========================================================
  // 🏠 العودة للخريطة
  // ==========================================================

  void _goHome() {
    if (!_running || !mounted) {
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
  // 🧱 بناء الشاشة
  //
  // تم وضع المحتوى هنا مباشرة بدلاً من _FinalVictoryContent
  // الذي كان مفقوداً ويسبب خطأ البناء.
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: _buildFinalVictoryContent(),
    );
  }

  // ==========================================================
  // 🏆 محتوى شاشة الفوز
  // ==========================================================

  Widget _buildFinalVictoryContent() {
    return Scaffold(
      backgroundColor:
          const Color(0xff100B1C),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _bgController,
          _glowController,
          _titleController,
          _badgePunchController,
        ]),
        builder: (context, child) {
          final glow =
              0.35 +
              (_glowController.value *
                  0.25);

          final titleValue =
              Curves.easeOutBack.transform(
            _titleController.value,
          );

          final badgeScale =
              1.0 +
              (_badgePunchController.value >
                      0.5
                  ? (1 -
                          _badgePunchController
                              .value) *
                      0.15
                  : _badgePunchController
                          .value *
                      0.15);

          return Stack(
            fit: StackFit.expand,
            children: [
              // ------------------------------------------------
              // الخلفية
              // ------------------------------------------------

              Transform.translate(
                offset: Offset(
                  _bgShift.value,
                  0,
                ),
                child: Transform.scale(
                  scale: _bgScale.value,
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
                              0xff17102A),
                          Color(
                              0xff24153C),
                          Color(
                              0xff0F0A19),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ------------------------------------------------
              // توهج مركزي
              // ------------------------------------------------

              Center(
                child: _softGlow(
                  430,
                  Colors.amber.withOpacity(
                    glow,
                  ),
                ),
              ),

              // ------------------------------------------------
              // شريط المكافآت العلوي
              // ------------------------------------------------

              SafeArea(
                child: Align(
                  alignment:
                      Alignment.topCenter,
                  child:
                      _buildRewardToolbar(),
                ),
              ),

              // ------------------------------------------------
              // عنوان الفوز
              // ------------------------------------------------

              if (_showTitle)
                Positioned(
                  top: 145,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity:
                        _titleController
                            .value
                            .clamp(0, 1),
                    child: Transform.scale(
                      scale:
                          0.7 +
                          titleValue *
                              0.3,
                      child:
                          Column(
                        children: const [
                          Text(
                            'مبروك!',
                            textAlign:
                                TextAlign.center,
                            style:
                                TextStyle(
                              color:
                                  Colors.amber,
                              fontSize:
                                  42,
                              fontWeight:
                                  FontWeight.w900,
                              shadows: [
                                Shadow(
                                  blurRadius:
                                      20,
                                  color:
                                      Colors.black54,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                            'لقد أكملت الجزيرة',
                            textAlign:
                                TextAlign.center,
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontSize:
                                  20,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // ------------------------------------------------
              // الصندوق
              // ------------------------------------------------

              if (_showChest)
                Center(
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      _chestDrop.value,
                    ),
                    child: Transform.rotate(
                      angle:
                          _chestShake.value,
                      child: Transform.scale(
                        scale:
                            _chestScale.value,
                        child: Container(
                          key:
                              _chestKey,
                          width: 190,
                          height: 190,
                          decoration:
                              BoxDecoration(
                            shape:
                                BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors
                                    .amber
                                    .withOpacity(
                                  0.30 +
                                      _glowController
                                          .value *
                                      0.20,
                                ),
                                blurRadius:
                                    45,
                                spreadRadius:
                                    8,
                              ),
                            ],
                          ),
                          child:
                              Image.asset(
                            _opened
                                ? 'assets/images/rewards/reward_chest_open.png'
                                : 'assets/images/rewards/reward_chest_closed.png',
                            fit:
                                BoxFit.contain,
                            errorBuilder:
                                (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return Icon(
                                _opened
                                    ? Icons
                                        .card_giftcard
                                    : Icons
                                        .inventory_2,
                                size: 130,
                                color:
                                    Colors.amber,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // ------------------------------------------------
              // نص المكافآت
              // ------------------------------------------------

              if (_showTitle)
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 115,
                  child: Transform.scale(
                    scale:
                        badgeScale,
                    child:
                        _buildRewardSummary(),
                  ),
                ),

              // ------------------------------------------------
              // القصاصات
              // ------------------------------------------------

              IgnorePointer(
                child: CustomPaint(
                  painter:
                      _ConfettiPainter(
                    _confetti,
                  ),
                ),
              ),

              // ------------------------------------------------
              // وميض فتح الصندوق
              // ------------------------------------------------

              IgnorePointer(
                child: AnimatedBuilder(
                  animation:
                      _flashController,
                  builder:
                      (
                    context,
                    child,
                  ) {
                    final opacity =
                        (1 -
                                _flashController
                                    .value) *
                            0.35;

                    return Container(
                      color: Colors.white
                          .withOpacity(
                        opacity,
                      ),
                    );
                  },
                ),
              ),

              // ------------------------------------------------
              // مؤشر حركة المكافآت
              // ------------------------------------------------

              if (_showRewardFlights)
                const Positioned(
                  bottom: 55,
                  left: 0,
                  right: 0,
                  child: Text(
                    '✨',
                    textAlign:
                        TextAlign.center,
                    style:
                        TextStyle(
                      fontSize: 28,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================
  // 🪙 شريط المكافآت
  // ==========================================================

  Widget _buildRewardToolbar() {
    return Container(
      margin:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration:
          BoxDecoration(
        color: const Color(
          0xff1D1730,
        ).withOpacity(0.94),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color:
              Colors.amber.withOpacity(
            0.28,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.30,
            ),
            blurRadius: 18,
            offset:
                const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          _buildRewardBadge(
            key: _gemKey,
            asset:
                'assets/images/rewards/gem.png',
            value: '💎',
          ),
          const SizedBox(width: 14),
          _buildRewardBadge(
            key: _coinKey,
            asset:
                'assets/images/rewards/puzzle_coin.png',
            value: '🪙',
          ),
          const SizedBox(width: 14),
          _buildRewardBadge(
            key: _starKey,
            asset:
                'assets/images/rewards/Star_gold.png',
            value: '⭐',
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // 🏅 عنصر المكافأة
  // ==========================================================

  Widget _buildRewardBadge({
    required GlobalKey key,
    required String asset,
    required String value,
  }) {
    return Container(
      key: key,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration:
          BoxDecoration(
        color: Colors.black
            .withOpacity(0.20),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Image.asset(
            asset,
            width: 30,
            height: 30,
            fit: BoxFit.contain,
            errorBuilder:
                (
              context,
              error,
              stackTrace,
            ) {
              return Text(
                value,
                style:
                    const TextStyle(
                  fontSize: 25,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // 🎁 ملخص المكافآت
  // ==========================================================

  Widget _buildRewardSummary() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 13,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xff1D1730)
                .withOpacity(0.92),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              Colors.amber.withOpacity(
            0.35,
          ),
        ),
      ),
      child: const Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Text(
            'المكافأة النهائية',
            style:
                TextStyle(
              color:
                  Colors.amber,
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '⭐ نجمة   •   🪙 100 عملة   •   💎 جوهرة',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  Colors.white,
              fontSize: 15,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // 🌟 توهج
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
  // 🧹 التخلص من الموارد
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
// 🎁 نافذة مضاعفة المكافأة
// ============================================================

class _DoubleRewardDialogContent
    extends StatelessWidget {
  const _DoubleRewardDialogContent();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor:
          const Color(0xff1D1730),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(22),
      ),
      title: const Text(
        'مضاعفة المكافأة',
        textAlign:
            TextAlign.center,
        style:
            TextStyle(
          color: Colors.amber,
          fontWeight:
              FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          const Text(
            'شاهد إعلاناً للحصول على مكافأة إضافية.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  Colors.white70,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: const [
              _RewardPreviewImageStatic(
                asset:
                    'assets/images/rewards/Star_gold.png',
                size: 48,
              ),
              SizedBox(width: 14),
              _RewardPreviewImageStatic(
                asset:
                    'assets/images/rewards/puzzle_coin.png',
                size: 48,
              ),
              SizedBox(width: 14),
              _RewardPreviewImageStatic(
                asset:
                    'assets/images/rewards/gem.png',
                size: 46,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'نجمة + 100 عملة + جوهرة',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  Colors.white,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
      actionsAlignment:
          MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(
              context,
              false,
            );
          },
          child: const Text(
            'لاحقاً',
            style:
                TextStyle(
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
          child: const Text(
            'شاهد الإعلان',
          ),
        ),
      ],
    );
  }
}

// ============================================================
// 🖼️ صورة المكافأة
// ============================================================

class _RewardPreviewImageStatic
    extends StatelessWidget {
  final String asset;
  final double size;

  const _RewardPreviewImageStatic({
    required this.asset,
    required this.size,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder:
            (
          context,
          error,
          stackTrace,
        ) {
          return const Icon(
            Icons.card_giftcard,
            color: Colors.amber,
            size: 40,
          );
        },
      ),
    );
  }
}

// ============================================================
// 🎉 رسم القصاصات
// ============================================================

class _ConfettiPainter
    extends CustomPainter {
  final List<_ConfettiParticle>
      particles;

  _ConfettiPainter(this.particles);

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
        p.opacity.clamp(0, 1),
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
          center: Offset.zero,
          width: p.size,
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