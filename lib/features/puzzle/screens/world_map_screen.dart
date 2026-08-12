import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'private_island_screen.dart';
import '../data/puzzle_data.dart';
import '../models/puzzle_model.dart';
import '../widgets/wallet_icon_widget.dart';
import '../widgets/daily_reward_popup.dart';
import 'island_screen.dart';
import '../managers/puzzle_progress_manager.dart';
import '../managers/reward_manager.dart';

class _RelativeRect {
  final String id;
  final double left;
  final double top;
  final double width;
  final double height;

  const _RelativeRect({
    required this.id,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

class _RelativeCloud {
  final String image;
  final double top;
  final double size;
  final double opacity;
  final Duration duration;

  const _RelativeCloud({
    required this.image,
    required this.top,
    required this.size,
    required this.opacity,
    required this.duration,
  });
}

class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({
    super.key,
  });

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // 📢 Scaffold Messenger
  // ============================================================

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // ============================================================
  // 🌍 الخريطة
  // ============================================================

  static const String mapImage =
      "assets/images/world/world_map.jpg";

  static const double worldWidth = 896;
  static const double worldHeight = 1350;

  // ============================================================
  // 🏝️ الجزيرة الخاصة
  // ============================================================

  static const int privateIslandGemCost = 100;

  // ============================================================
  // 📱 إصدار التطبيق
  // ============================================================

  static const String appVersion = "1.0.0";

  // ============================================================
  // 🗺️ بيانات الجزر
  // ============================================================

  late final List<PuzzleModel> islands;

  // ============================================================
  // 🎬 Animation
  // ============================================================

  late final AnimationController worldController;
  late final Animation<double> worldScale;
  late final Animation<double> worldTranslateY;

  late final List<AnimationController> cloudControllers;

  late final AnimationController iconGlowController;

  // ============================================================
  // 🔊 الصوت
  // ============================================================

  late final AudioPlayer audioPlayer;

  bool soundEnabled = true;

  // ============================================================
  // 🔓 حالة الجزر
  // ============================================================

  final Map<String, bool> islandUnlocked = {
    "animals": true,
    "nature": false,
    "cars": false,
    "landmarks": false,
    "space": false,
  };

  bool privateIslandUnlocked = false;

  // ============================================================
  // 🔄 حالات التحميل
  // ============================================================

  bool loadingIslandState = true;

  bool unlockingIsland = false;

  bool unlockingPrivateIsland = false;

  // ============================================================
  // 📢 الرسالة العامة
  // ============================================================

  String? _worldMessage;

  Timer? _worldMessageTimer;

  // ============================================================
  // 🎁 المكافأة اليومية
  // ============================================================

  bool showingDailyReward = false;

  bool dailyRewardMiniVisible = true;

  bool dailyRewardAvailable = false;

  Duration dailyRewardRemaining = Duration.zero;

  Timer? dailyRewardTimer;

  // ============================================================
  // 📍 مواقع الجزر
  // ============================================================

  static final List<_RelativeRect> _islandRects = [
    _RelativeRect(
      id: "space",
      left: 210 / worldWidth,
      top: 9 / worldHeight,
      width: 480 / worldWidth,
      height: 540 / worldHeight,
    ),
    _RelativeRect(
      id: "landmarks",
      left: 100 / worldWidth,
      top: 408 / worldHeight,
      width: 335 / worldWidth,
      height: 365 / worldHeight,
    ),
    _RelativeRect(
      id: "cars",
      left: 460 / worldWidth,
      top: 408 / worldHeight,
      width: 335 / worldWidth,
      height: 365 / worldHeight,
    ),
    _RelativeRect(
      id: "nature",
      left: 268 / worldWidth,
      top: 595 / worldHeight,
      width: 360 / worldWidth,
      height: 380 / worldHeight,
    ),
    _RelativeRect(
      id: "animals",
      left: 268 / worldWidth,
      top: 935 / worldHeight,
      width: 350 / worldWidth,
      height: 380 / worldHeight,
    ),
  ];

  // ============================================================
  // ☁️ السحب
  // ============================================================

  static final List<_RelativeCloud> _clouds = [
    _RelativeCloud(
      image: "assets/images/background/cloud_01.png",
      top: 80 / worldHeight,
      size: 280 / worldWidth,
      opacity: 0.22,
      duration: const Duration(seconds: 55),
    ),
    _RelativeCloud(
      image: "assets/images/background/cloud_02.png",
      top: 200 / worldHeight,
      size: 220 / worldWidth,
      opacity: 0.22,
      duration: const Duration(seconds: 70),
    ),
    _RelativeCloud(
      image: "assets/images/background/cloud_03.png",
      top: 40 / worldHeight,
      size: 170 / worldWidth,
      opacity: 0.22,
      duration: const Duration(seconds: 90),
    ),
    _RelativeCloud(
      image: "assets/images/background/cloud_04.png",
      top: 300 / worldHeight,
      size: 240 / worldWidth,
      opacity: 0.22,
      duration: const Duration(seconds: 65),
    ),
  ];

  // ============================================================
  // 🚀 INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    islands = PuzzleData.puzzles;

    audioPlayer = AudioPlayer();

    iconGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    worldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat(reverse: true);

    worldScale = Tween<double>(
      begin: 1.00,
      end: 1.035,
    ).animate(
      CurvedAnimation(
        parent: worldController,
        curve: Curves.easeInOut,
      ),
    );

    worldTranslateY = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(
      CurvedAnimation(
        parent: worldController,
        curve: Curves.easeInOut,
      ),
    );

    cloudControllers = _clouds
        .map(
          (cloud) => AnimationController(
            vsync: this,
            duration: cloud.duration,
          )..repeat(),
        )
        .toList();

    loadIslandState();
    loadPrivateIslandState();
    loadSoundState();
    _checkDailyReward();
  }

  // ============================================================
  // 🔊 تحميل حالة الصوت
  // ============================================================

  Future<void> loadSoundState() async {
    try {
      final enabled =
          await PuzzleProgressManager.isSoundEnabled();

      if (!mounted) return;

      setState(() {
        soundEnabled = enabled;
      });
    } catch (_) {}
  }

  // ============================================================
  // 🏝️ تحميل حالة الجزيرة الخاصة
  // ============================================================

  Future<void> loadPrivateIslandState() async {
    try {
      final unlocked =
          await PuzzleProgressManager.isPrivateIslandUnlocked();

      if (!mounted) return;

      setState(() {
        privateIslandUnlocked = unlocked;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        privateIslandUnlocked = false;
      });
    }
  }

  // ============================================================
  // 🎁 التحقق من المكافأة اليومية
  // ============================================================

  Future<void> _checkDailyReward() async {
    try {
      final canClaim =
          await RewardManager.canClaimDailyReward();

      final remaining =
          await RewardManager.getDailyRewardRemaining();

      if (!mounted) return;

      setState(() {
        dailyRewardMiniVisible = true;
        dailyRewardAvailable = canClaim;
        dailyRewardRemaining = remaining;
      });

      _startDailyRewardTimer();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        dailyRewardMiniVisible = true;
        dailyRewardAvailable = true;
        dailyRewardRemaining = Duration.zero;
      });
    }
  }

  // ============================================================
  // ⏱️ العد التنازلي للمكافأة اليومية
  // ============================================================

  void _startDailyRewardTimer() {
    dailyRewardTimer?.cancel();

    dailyRewardTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) async {
        if (!mounted) return;

        final canClaim =
            await RewardManager.canClaimDailyReward();

        if (!mounted) return;

        if (canClaim) {
          setState(() {
            dailyRewardAvailable = true;
            dailyRewardRemaining = Duration.zero;
          });

          dailyRewardTimer?.cancel();

          return;
        }

        final remaining =
            await RewardManager.getDailyRewardRemaining();

        if (!mounted) return;

        setState(() {
          dailyRewardAvailable = false;
          dailyRewardRemaining = remaining;
        });
      },
    );
  }

  // ============================================================
  // ⏱️ تنسيق العد التنازلي
  // ============================================================

  String formatDailyRewardTime(
    Duration duration,
  ) {
    final hours = duration.inHours;

    final minutes =
        duration.inMinutes.remainder(60);

    final seconds =
        duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // 🏝️ تحميل حالة الجزر
  // ============================================================

  Future<void> loadIslandState() async {
    try {
      for (final islandId in [
        "animals",
        "nature",
        "cars",
        "landmarks",
        "space",
      ]) {
        final unlocked =
            await PuzzleProgressManager.isIslandUnlocked(
          islandId,
        );

        islandUnlocked[islandId] =
            unlocked || islandId == "animals";
      }
    } catch (_) {
      islandUnlocked["animals"] = true;
    }

    if (!mounted) return;

    setState(() {
      loadingIslandState = false;
    });
  }

  // ============================================================
  // 📢 رسالة فوق جميع طبقات الخريطة
  // ============================================================

  void showMessage(String message) {
    if (!mounted) return;

    _worldMessageTimer?.cancel();

    setState(() {
      _worldMessage = message;
    });

    _worldMessageTimer = Timer(
      const Duration(seconds: 3),
      () {
        if (!mounted) return;

        setState(() {
          _worldMessage = null;
        });
      },
    );
  }

  // ============================================================
  // 🔊 صوت الضغط
  // ============================================================

  Future<void> playClickSound() async {
    if (!soundEnabled) return;

    try {
      await audioPlayer.play(
        AssetSource(
          'audio/puzzle_click.mp3',
        ),
      );
    } catch (_) {}
  }

  // ============================================================
  // 🧹 DISPOSE
  // ============================================================

  @override
  void dispose() {
    dailyRewardTimer?.cancel();

    _worldMessageTimer?.cancel();

    worldController.dispose();

    iconGlowController.dispose();

    audioPlayer.dispose();

    for (final controller in cloudControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // ============================================================
  // 🔎 البحث عن الجزيرة
  // ============================================================

  PuzzleModel? getIsland(
    String id,
  ) {
    for (final item in islands) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  // ============================================================
  // 🗺️ BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        MediaQuery.of(context).padding.bottom;

    final topPadding =
        MediaQuery.of(context).padding.top;

    return Scaffold(
      key: _scaffoldMessengerKey,
      backgroundColor: const Color(0xff08182b),
      body: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final screenWidth =
              constraints.maxWidth;

          final screenHeight =
              constraints.maxHeight;

          if (screenWidth <= 0 ||
              screenHeight <= 0) {
            return const SizedBox.shrink();
          }

          final scale = math.max(
            screenWidth / worldWidth,
            screenHeight / worldHeight,
          );

          final scaledWidth =
              worldWidth * scale;

          final scaledHeight =
              worldHeight * scale;

          final dx =
              (screenWidth - scaledWidth) / 2;

          final dy =
              (screenHeight - scaledHeight) / 2;

          return ClipRect(
            child: Stack(
              children: [
                // ==================================================
                // 🌍 الخريطة
                // ==================================================

                Positioned(
                  left: dx,
                  top: dy,
                  child: Transform.scale(
                    scale: scale,
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: worldWidth,
                      height: worldHeight,
                      child: AnimatedBuilder(
                        animation: worldController,
                        builder: (
                          context,
                          child,
                        ) {
                          return Transform.translate(
                            offset: Offset(
                              0,
                              worldTranslateY.value,
                            ),
                            child: Transform.scale(
                              scale: worldScale.value,
                              alignment: Alignment.center,
                              child: child,
                            ),
                          );
                        },
                        child: SizedBox(
                          width: worldWidth,
                          height: worldHeight,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // =================================
                              // 🗺️ صورة الخريطة
                              // =================================

                              Positioned.fill(
                                child: Image.asset(
                                  mapImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (
                                    context,
                                    error,
                                    stack,
                                  ) {
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),

                              // =================================
                              // ☁️ السحب
                              // =================================

                              for (int i = 0;
                                  i < _clouds.length;
                                  i++)
                                cloudWidget(
                                  cloud: _clouds[i],
                                  controller:
                                      cloudControllers[i],
                                ),

                              // =================================
                              // 🏝️ الجزر
                              // =================================

                              for (final rect
                                  in _islandRects)
                                islandImage(
                                  rect: rect,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // ⚙️ الإعدادات - أعلى يسار
                // ==================================================

                Positioned(
                  top: topPadding + 16,
                  left: 18,
                  child: GestureDetector(
                    behavior:
                        HitTestBehavior.opaque,
                    onTap: () async {
                      await playClickSound();

                      if (!mounted) return;

                      await showSettingsDialog();
                    },
                    child:
                        _AnimatedRoyalImageIcon(
                      controller:
                          iconGlowController,
                      image:
                          "assets/images/ui/seting_icon.png",
                    ),
                  ),
                ),

                // ==================================================
                // 👛 المحفظة - أعلى يمين
                // ==================================================

                Positioned(
                  top: topPadding + 16,
                  right: 18,
                  child: GestureDetector(
                    behavior:
                        HitTestBehavior.opaque,
                    onTap: () async {
                      await playClickSound();
                    },
                    child:
                        _AnimatedRoyalWallet(
                      controller:
                          iconGlowController,
                    ),
                  ),
                ),

                // ==================================================
                // 🎁 المكافأة اليومية - أسفل يمين
                // ==================================================

                Positioned(
                  bottom:
                      bottomPadding + 20,
                  right: 18,
                  child: GestureDetector(
                    behavior:
                        HitTestBehavior.opaque,
                    onTap: dailyRewardAvailable
                        ? () async {
                            await playClickSound();

                            if (!mounted) {
                              return;
                            }

                            final canClaim =
                                await RewardManager
                                    .canClaimDailyReward();

                            if (!mounted) {
                              return;
                            }

                            if (!canClaim) {
                              await _checkDailyReward();
                              return;
                            }

                            setState(() {
                              showingDailyReward =
                                  true;
                              dailyRewardMiniVisible =
                                  true;
                            });

                            await showDialog(
                              context: context,
                              barrierDismissible:
                                  false,
                              builder:
                                  (dialogContext) {
                                return DailyRewardPopup(
                                  onRewardClaimed:
                                      () {
                                    if (!mounted) {
                                      return;
                                    }

                                    setState(() {
                                      showingDailyReward =
                                          false;

                                      dailyRewardMiniVisible =
                                          true;

                                      dailyRewardAvailable =
                                          false;
                                    });
                                  },
                                );
                              },
                            );

                            if (!mounted) {
                              return;
                            }

                            setState(() {
                              showingDailyReward =
                                  false;

                              dailyRewardMiniVisible =
                                  true;
                            });

                            await _checkDailyReward();
                          }
                        : null,
                    child:
                        _DailyRewardMiniWidget(
                      available:
                          dailyRewardAvailable,
                      remaining:
                          dailyRewardRemaining,
                      timeText:
                          formatDailyRewardTime(
                        dailyRewardRemaining,
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // 🏝️ الجزيرة الخاصة - أسفل يسار
                // ==================================================

                Positioned(
                  bottom:
                      bottomPadding + 20,
                  left: 20,
                  child:
                      _PrivateIslandWidget(
                    unlocked:
                        privateIslandUnlocked,
                    unlocking:
                        unlockingPrivateIsland,
                    onTap: () async {
                      await playClickSound();

                      if (!mounted) return;

                      if (!privateIslandUnlocked) {
                        await showPrivateIslandPurchaseDialog();
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const PrivateIslandScreen(),
                        ),
                      );
                    },
                    onUnlockTap: () async {
                      await playClickSound();

                      if (!mounted) return;

                      await showPrivateIslandPurchaseDialog();
                    },
                  ),
                ),

                // ==================================================
                // 🔄 تحميل حالة الجزر
                // ==================================================

                if (loadingIslandState)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: Colors.black
                            .withOpacity(0.12),
                        child:
                            const Center(
                          child:
                              CircularProgressIndicator(
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ),
                  ),

                // ==================================================
                // 🔄 فتح جزيرة
                // ==================================================

                if (unlockingIsland ||
                    unlockingPrivateIsland)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: Colors.black
                            .withOpacity(0.15),
                        child:
                            const Center(
                          child:
                              CircularProgressIndicator(
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ),
                  ),

                // ==================================================
                // 📢 الرسالة
                // ==================================================

                if (_worldMessage != null)
                  Positioned(
                    top:
                        topPadding + 95,
                    left: 20,
                    right: 20,
                    child: IgnorePointer(
                      child: Center(
                        child: Material(
                          color:
                              Colors.transparent,
                          child:
                              AnimatedSwitcher(
                            duration:
                                const Duration(
                              milliseconds: 250,
                            ),
                            transitionBuilder:
                                (
                              child,
                              animation,
                            ) {
                              return FadeTransition(
                                opacity:
                                    animation,
                                child:
                                    ScaleTransition(
                                  scale:
                                      Tween<double>(
                                    begin:
                                        0.92,
                                    end:
                                        1.0,
                                  ).animate(
                                    CurvedAnimation(
                                      parent:
                                          animation,
                                      curve: Curves
                                          .easeOutBack,
                                    ),
                                  ),
                                  child:
                                      child,
                                ),
                              );
                            },
                            child:
                                Container(
                              key: ValueKey(
                                _worldMessage,
                              ),
                              constraints:
                                  const BoxConstraints(
                                maxWidth: 380,
                              ),
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 18,
                                vertical: 13,
                              ),
                              decoration:
                                  BoxDecoration(
                                color:
                                    const Color(
                                  0xFF2A1B3D,
                                ).withOpacity(0.97),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  18,
                                ),
                                border:
                                    Border.all(
                                  color: Colors
                                      .amber
                                      .withOpacity(
                                    0.85,
                                  ),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors
                                        .black
                                        .withOpacity(
                                      0.45,
                                    ),
                                    blurRadius:
                                        16,
                                    spreadRadius:
                                        2,
                                    offset:
                                        const Offset(
                                      0,
                                      5,
                                    ),
                                  ),
                                  BoxShadow(
                                    color: Colors
                                        .amber
                                        .withOpacity(
                                      0.15,
                                    ),
                                    blurRadius:
                                        20,
                                    spreadRadius:
                                        2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons
                                        .info_outline_rounded,
                                    color:
                                        Colors.amber,
                                    size: 23,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    child: Text(
                                      _worldMessage!,
                                      textAlign:
                                          TextAlign
                                              .right,
                                      style:
                                          const TextStyle(
                                        color:
                                            Colors.white,
                                        fontSize: 14,
                                        fontWeight:
                                            FontWeight
                                                .w600,
                                        height:
                                            1.35,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // ☁️ السحب
  // ============================================================

  Widget cloudWidget({
    required _RelativeCloud cloud,
    required AnimationController controller,
  }) {
    final top =
        cloud.top * worldHeight;

    final size =
        cloud.size * worldWidth;

    return AnimatedBuilder(
      animation: controller,
      builder: (
        context,
        child,
      ) {
        return Positioned(
          left:
              (worldWidth + 100) -
                  (controller.value *
                      (worldWidth + 400)),
          top: top,
          child: Opacity(
            opacity: cloud.opacity,
            child: Transform.rotate(
              angle:
                  controller.value * 0.15,
              child: child,
            ),
          ),
        );
      },
      child: Image.asset(
        cloud.image,
        width: size,
        errorBuilder: (
          context,
          error,
          stack,
        ) {
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ============================================================
  // 🏝️ رسم الجزيرة
  // ============================================================

  Widget islandImage({
    required _RelativeRect rect,
  }) {
    final island =
        getIsland(rect.id);

    if (island == null) {
      return const SizedBox.shrink();
    }

    final left =
        rect.left * worldWidth;

    final top =
        rect.top * worldHeight;

    final width =
        rect.width * worldWidth;

    final height =
        rect.height * worldHeight;

    final locked =
        !isIslandUnlockedLocal(
      rect.id,
    );

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        behavior:
            HitTestBehavior.opaque,
        onTap: locked
            ? null
            : () async {
                await playClickSound();

                if (!mounted) return;

                await openIsland(island);
              },
        child: Stack(
          alignment:
              Alignment.center,
          children: [
            AnimatedOpacity(
              duration:
                  const Duration(
                milliseconds: 450,
              ),
              curve:
                  Curves.easeInOut,
              opacity:
                  locked ? 0.48 : 1.0,
              child: Image.asset(
                island.image,
                fit: BoxFit.contain,
                errorBuilder: (
                  context,
                  error,
                  stack,
                ) {
                  return const SizedBox
                      .shrink();
                },
              ),
            ),

            if (locked)
              Center(
                child: Image.asset(
                  "assets/images/ui/lock.png",
                  width: 64,
                  height: 64,
                  fit: BoxFit.contain,
                  errorBuilder: (
                    context,
                    error,
                    stack,
                  ) {
                    return const Icon(
                      Icons.lock_rounded,
                      color:
                          Colors.amber,
                      size: 58,
                    );
                  },
                ),
              ),

            if (locked)
              Positioned(
                bottom:
                    height * 0.10,
                child: Material(
                  color:
                      Colors.transparent,
                  child: InkWell(
                    borderRadius:
                        BorderRadius
                            .circular(
                      18,
                    ),
                    onTap:
                        unlockingIsland
                            ? null
                            : () async {
                                await playClickSound();

                                if (!mounted) {
                                  return;
                                }

                                await showIslandPurchaseDialog(
                                  island,
                                );
                              },
                    child: Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 18,
                        vertical: 9,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFF5B3A7D,
                        ).withOpacity(0.96),
                        borderRadius:
                            BorderRadius
                                .circular(
                          18,
                        ),
                        border:
                            Border.all(
                          color: Colors
                              .amber
                              .withOpacity(
                            0.85,
                          ),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .black
                                .withOpacity(
                              0.30,
                            ),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: Colors
                                .amber
                                .withOpacity(
                              0.18,
                            ),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/rewards/Star_gold.png",
                            width: 22,
                            height: 22,
                            fit:
                                BoxFit.contain,
                            errorBuilder: (
                              context,
                              error,
                              stack,
                            ) {
                              return const SizedBox(
                                width: 22,
                                height: 22,
                              );
                            },
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          const Text(
                            "فتح",
                            style:
                                TextStyle(
                              color:
                                  Colors.white,
                              fontSize: 14,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🔎 حالة الجزيرة
  // ============================================================

  bool isIslandUnlockedLocal(
    String islandId,
  ) {
    if (islandId == "animals") {
      return true;
    }

    return islandUnlocked[
            islandId] ??
        false;
  }

  // ============================================================
  // ⭐ سعر الجزيرة
  // ============================================================

  int getIslandStarCost(
    String islandId,
  ) {
    return PuzzleProgressManager
        .getIslandStarCost(
      islandId,
    );
  }

  // ============================================================
  // 🏝️ فتح الجزيرة
  // ============================================================

  Future<void> openIsland(
    PuzzleModel island,
  ) async {
    if (island.id == "animals") {
      await PuzzleProgressManager
          .unlockIsland(
        island.id,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              IslandScreen(
            island: island,
          ),
        ),
      );

      return;
    }

    final unlocked =
        await PuzzleProgressManager
            .isIslandUnlocked(
      island.id,
    );

    if (!mounted) return;

    if (!unlocked) {
      return;
    }

    setState(() {
      islandUnlocked[
          island.id] = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            IslandScreen(
          island: island,
        ),
      ),
    );
  }

  // ============================================================
  // ⭐ نافذة شراء الجزيرة
  // ============================================================

  Future<void> showIslandPurchaseDialog(
    PuzzleModel island,
  ) async {
    final requiredStars =
        getIslandStarCost(
      island.id,
    );

    final currentStars =
        await PuzzleProgressManager
            .getStars();

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (
        dialogContext,
      ) {
        return StatefulBuilder(
          builder: (
            dialogContext,
            setDialogState,
          ) {
            return AlertDialog(
              backgroundColor:
                  const Color(
                0xFF2A1B3D,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              title: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  Image.asset(
                    "assets/images/ui/lock.png",
                    width: 38,
                    height: 38,
                    fit:
                        BoxFit.contain,
                    errorBuilder: (
                      context,
                      error,
                      stack,
                    ) {
                      return const Icon(
                        Icons
                            .lock_rounded,
                        color:
                            Colors.amber,
                        size: 36,
                      );
                    },
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Flexible(
                    child: Text(
                      "${getIslandName(island.id)} مغلقة",
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Colors.amber,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content:
                  FutureBuilder<int>(
                future:
                    PuzzleProgressManager
                        .getStars(),
                builder: (
                  context,
                  snapshot,
                ) {
                  final stars =
                      snapshot.data ??
                          currentStars;

                  final remaining =
                      math.max(
                    0,
                    requiredStars -
                        stars,
                  );

                  return Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Text(
                        "يمكنك شراء هذه الجزيرة باستخدام النجوم.",
                        textAlign:
                            TextAlign.center,
                        style:
                            TextStyle(
                          color:
                              Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Image.asset(
                            "assets/images/rewards/Star_gold.png",
                            width: 38,
                            height: 38,
                            fit:
                                BoxFit.contain,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "$requiredStars",
                            style:
                                const TextStyle(
                              color:
                                  Colors.amber,
                              fontSize: 28,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        "نجومك الحالية: $stars ⭐",
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      if (remaining >
                          0)
                        Text(
                          "تحتاج إلى $remaining ⭐ إضافية.",
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 15,
                          ),
                        )
                      else
                        const Text(
                          "يمكنك شراء الجزيرة الآن.",
                          textAlign:
                              TextAlign.center,
                          style:
                              TextStyle(
                            color:
                                Colors.greenAccent,
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize: 15,
                          ),
                        ),
                    ],
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                      const Text(
                    "إلغاء",
                    style:
                        TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: Image.asset(
                    "assets/images/rewards/Star_gold.png",
                    width: 22,
                    height: 22,
                    fit:
                        BoxFit.contain,
                  ),
                  label:
                      const Text(
                    "شراء وفتح",
                  ),
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.amber,
                    foregroundColor:
                        const Color(
                      0xFF1A0B2E,
                    ),
                  ),
                  onPressed:
                      unlockingIsland
                          ? null
                          : () async {
                              await buyIsland(
                                island,
                                dialogContext,
                                setDialogState,
                              );
                            },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // ⭐ شراء الجزيرة
  // ============================================================

  Future<void> buyIsland(
    PuzzleModel island,
    BuildContext dialogContext,
    StateSetter setDialogState,
  ) async {
    if (unlockingIsland) {
      return;
    }

    setState(() {
      unlockingIsland = true;
    });

    setDialogState(() {});

    try {
      final requiredStars =
          getIslandStarCost(
        island.id,
      );

      final currentStars =
          await PuzzleProgressManager
              .getStars();

      if (currentStars <
          requiredStars) {
        if (mounted) {
          setState(() {
            unlockingIsland = false;
          });
        }

        if (dialogContext.mounted) {
          Navigator.pop(
            dialogContext,
          );
        }

        await Future<void>.delayed(
          const Duration(
            milliseconds: 150,
          ),
        );

        if (!mounted) return;

        showMessage(
          "لا تملك نجومًا كافية. تحتاج $requiredStars ⭐ لفتح جزيرة ${getIslandName(island.id)}.",
        );

        return;
      }

      final paid =
          await PuzzleProgressManager
              .buyIslandWithStars(
        island.id,
      );

      if (!paid) {
        if (mounted) {
          setState(() {
            unlockingIsland = false;
          });
        }

        if (dialogContext.mounted) {
          Navigator.pop(
            dialogContext,
          );
        }

        await Future<void>.delayed(
          const Duration(
            milliseconds: 150,
          ),
        );

        if (!mounted) return;

        showMessage(
          "تعذر شراء الجزيرة. تأكد من رصيد النجوم.",
        );

        return;
      }

      if (!mounted) return;

      setState(() {
        islandUnlocked[
            island.id] = true;

        unlockingIsland = false;
      });

      if (dialogContext.mounted) {
        Navigator.pop(
          dialogContext,
        );
      }

      await Future<void>.delayed(
        const Duration(
          milliseconds: 150,
        ),
      );

      if (!mounted) return;

      showMessage(
        "تم شراء وفتح جزيرة ${getIslandName(island.id)} بنجاح! ⭐",
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          unlockingIsland = false;
        });
      }

      if (dialogContext.mounted) {
        Navigator.pop(
          dialogContext,
        );
      }

      await Future<void>.delayed(
        const Duration(
          milliseconds: 150,
        ),
      );

      if (!mounted) return;

      showMessage(
        "حدث خطأ أثناء فتح الجزيرة.",
      );
    }
  }

  // ============================================================
  // 💎 نافذة شراء الجزيرة الخاصة
  // ============================================================

  Future<void>
      showPrivateIslandPurchaseDialog() async {
    const requiredGems =
        privateIslandGemCost;

    final currentGems =
        await PuzzleProgressManager
            .getGems();

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (
        dialogContext,
      ) {
        return StatefulBuilder(
          builder: (
            dialogContext,
            setDialogState,
          ) {
            return AlertDialog(
              backgroundColor:
                  const Color(
                0xFF2A1B3D,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),
              title: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  Image.asset(
                    "assets/images/ui/lock.png",
                    width: 38,
                    height: 38,
                    fit:
                        BoxFit.contain,
                    errorBuilder: (
                      context,
                      error,
                      stack,
                    ) {
                      return const Icon(
                        Icons
                            .lock_rounded,
                        color:
                            Colors.amber,
                        size: 36,
                      );
                    },
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  const Flexible(
                    child: Text(
                      "الجزيرة الخاصة مغلقة",
                      textAlign:
                          TextAlign.center,
                      style:
                          TextStyle(
                        color:
                            Colors.amber,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content:
                  FutureBuilder<int>(
                future:
                    PuzzleProgressManager
                        .getGems(),
                builder: (
                  context,
                  snapshot,
                ) {
                  final gems =
                      snapshot.data ??
                          currentGems;

                  final remaining =
                      math.max(
                    0,
                    requiredGems -
                        gems,
                  );

                  return Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Text(
                        "يمكنك شراء الجزيرة الخاصة باستخدام الجواهر.",
                        textAlign:
                            TextAlign.center,
                        style:
                            TextStyle(
                          color:
                              Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,
                        children: [
                          Image.asset(
                            "assets/images/rewards/gem.png",
                            width: 38,
                            height: 38,
                            fit:
                                BoxFit.contain,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "$requiredGems",
                            style:
                                const TextStyle(
                              color:
                                  Colors.amber,
                              fontSize: 28,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        "جواهرك الحالية: $gems ",
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      if (remaining >
                          0)
                        Text(
                          "تحتاج إلى $remaining 💎 إضافية.",
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize: 15,
                          ),
                        )
                      else
                        const Text(
                          "يمكنك شراء الجزيرة الآن.",
                          textAlign:
                              TextAlign.center,
                          style:
                              TextStyle(
                            color:
                                Colors.greenAccent,
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize: 15,
                          ),
                        ),
                    ],
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                      const Text(
                    "إلغاء",
                    style:
                        TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  icon: Image.asset(
                    "assets/images/rewards/gem.png",
                    width: 22,
                    height: 22,
                    fit:
                        BoxFit.contain,
                  ),
                  label:
                      const Text(
                    "شراء وفتح",
                  ),
                  style:
                      ElevatedButton
                          .styleFrom(
                    backgroundColor:
                        Colors.amber,
                    foregroundColor:
                        const Color(
                      0xFF1A0B2E,
                    ),
                  ),
                  onPressed:
                      unlockingPrivateIsland
                          ? null
                          : () async {
                              await buyPrivateIsland(
                                dialogContext,
                                setDialogState,
                              );
                            },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // 💎 شراء وفتح الجزيرة الخاصة
  // ============================================================

  Future<void> buyPrivateIsland(
    BuildContext dialogContext,
    StateSetter setDialogState,
  ) async {
    if (unlockingPrivateIsland) {
      return;
    }

    setState(() {
      unlockingPrivateIsland = true;
    });

    setDialogState(() {});

    try {
      const requiredGems =
          privateIslandGemCost;

      final currentGems =
          await PuzzleProgressManager
              .getGems();

      if (currentGems <
          requiredGems) {
        if (mounted) {
          setState(() {
            unlockingPrivateIsland =
                false;
          });
        }

        if (dialogContext.mounted) {
          Navigator.pop(
            dialogContext,
          );
        }

        await Future<void>.delayed(
          const Duration(
            milliseconds: 150,
          ),
        );

        if (!mounted) return;

        showMessage(
          "لا تملك جواهر كافية. تحتاج $requiredGems  لفتح الجزيرة الخاصة.",
        );

        return;
      }

      final paid =
          await PuzzleProgressManager
              .buyPrivateIslandWithGems();

      if (!paid) {
        if (mounted) {
          setState(() {
            unlockingPrivateIsland =
                false;
          });
        }

        if (dialogContext.mounted) {
          Navigator.pop(
            dialogContext,
          );
        }

        await Future<void>.delayed(
          const Duration(
            milliseconds: 150,
          ),
        );

        if (!mounted) return;

        showMessage(
          "تعذر شراء الجزيرة الخاصة. تأكد من رصيد الجواهر.",
        );

        return;
      }

      if (!mounted) return;

      setState(() {
        privateIslandUnlocked =
            true;

        unlockingPrivateIsland =
            false;
      });

      if (dialogContext.mounted) {
        Navigator.pop(
          dialogContext,
        );
      }

      await Future<void>.delayed(
        const Duration(
          milliseconds: 150,
        ),
      );

      if (!mounted) return;

      showMessage(
        "تم شراء وفتح الجزيرة الخاصة بنجاح! ",
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          unlockingPrivateIsland =
              false;
        });
      }

      if (dialogContext.mounted) {
        Navigator.pop(
          dialogContext,
        );
      }

      await Future<void>.delayed(
        const Duration(
          milliseconds: 150,
        ),
      );

      if (!mounted) return;

      showMessage(
        "حدث خطأ أثناء فتح الجزيرة الخاصة.",
      );
    }
  }

  // ============================================================
  // 🏷️ اسم الجزيرة
  // ============================================================

  String getIslandName(
    String islandId,
  ) {
    switch (islandId) {
      case "animals":
        return "الحيوانات";

      case "nature":
        return "الطبيعة";

      case "cars":
        return "السيارات";

      case "landmarks":
        return "المعالم";

      case "space":
        return "الفضاء";

      default:
        return "الجديدة";
    }
  }

  // ============================================================
  // ⚙️ نافذة الإعدادات
  // ============================================================

  Future<void> showSettingsDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (
        dialogContext,
      ) {
        return StatefulBuilder(
          builder: (
            dialogContext,
            setDialogState,
          ) {
            return AlertDialog(
              backgroundColor:
                  const Color(0xFF241337),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
              ),
              title: Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(
                      8,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFF6A35C9,
                      ).withOpacity(
                        0.22,
                      ),
                      shape:
                          BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(
                            0xFF7E57C2,
                          ).withOpacity(
                            0.30,
                          ),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child:
                        const Icon(
                      Icons
                          .settings_rounded,
                      color:
                          Color(
                        0xFFD6B8FF,
                      ),
                      size: 28,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text(
                    "الإعدادات",
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
              content:
                  SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    _SettingsTile(
                      icon: soundEnabled
                          ? Icons
                              .volume_up_rounded
                          : Icons
                              .volume_off_rounded,
                      title: "الصوت",
                      trailing:
                          Switch(
                        value:
                            soundEnabled,
                        activeColor:
                            const Color(
                          0xFF9B6DFF,
                        ),
                        onChanged:
                            (value) async {
                          setDialogState(
                            () {
                              soundEnabled =
                                  value;
                            },
                          );

                          setState(
                            () {
                              soundEnabled =
                                  value;
                            },
                          );

                          await PuzzleProgressManager
                              .saveSoundEnabled(
                            value,
                          );
                        },
                      ),
                    ),

                    _SettingsTile(
                      icon: Icons
                          .info_outline_rounded,
                      title: "حول",
                      subtitle:
                          "معلومات Puzzle World",
                      onTap: () {
                        Navigator.pop(
                          dialogContext,
                        );

                        showAboutDialog();
                      },
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    _SettingsTile(
                      icon: Icons
                          .exit_to_app_rounded,
                      title:
                          "إغلاق التطبيق",
                      subtitle:
                          "إغلاق Puzzle World",
                      iconColor:
                          const Color(
                        0xFFFF8A9B,
                      ),
                      onTap: () {
                        Navigator.pop(
                          dialogContext,
                        );

                        Future.delayed(
                          const Duration(
                            milliseconds:
                                150,
                          ),
                          () {
                            SystemNavigator
                                .pop();
                          },
                        );
                      },
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    const Text(
                      "الإصدار 1.0.0",
                      style:
                          TextStyle(
                        color:
                            Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // ℹ️ حول التطبيق
  // ============================================================

  Future<void> showAboutDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (
        dialogContext,
      ) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF241337),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              22,
            ),
          ),
          title: const Text(
            "حول Puzzle World",
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content:
              SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Text(
                  "Puzzle World",
                  style:
                      TextStyle(
                    color:
                        Color(
                      0xFFD6B8FF,
                    ),
                    fontSize: 21,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                const Text(
                  "الإصدار 1.0.0",
                  style:
                      TextStyle(
                    color:
                        Colors.white54,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                // ==========================================
                // 🏝️ نظام فتح الجزر
                // ==========================================

                const _AboutSection(
                  title:
                      "نظام فتح الجزر",
                  icon: Icons
                      .public_rounded,
                  text:
                      "تفتح الجزيرة تلقائيًا بعد إكمال مراحل الجزيرة المفتوحة، "
                      "كما يمكنك استخدام النجوم لشراء أي جزيرة تريد.",
                ),

                const SizedBox(
                  height: 8,
                ),

                // ==========================================
                // 🧩 نظام فتح المراحل
                // ==========================================

                const _AboutSection(
                  title:
                      "نظام فتح المراحل",
                  icon: Icons
                      .extension_rounded,
                  text:
                      "يمكنك فتح المراحل تلقائيًا، أو شراء أي مرحلة تريد باستخدام العملات.",
                ),

                const SizedBox(
                  height: 8,
                ),

                // ==========================================
                // 👛 المحفظة
                // ==========================================

                const _AboutSection(
                  title: "المحفظة",
                  icon: Icons
                      .account_balance_wallet_rounded,
                  text:
                      "استخدم المحفظة لإدارة العملات والنجوم والجواهر والمكافآت الخاصة بك.",
                ),

                const SizedBox(
                  height: 8,
                ),

                // ==========================================
                // 🏝️ الجزيرة الغامضة
                // ==========================================

                const _AboutSection(
                  title:
                      "الجزيرة الغامضة",
                  icon: Icons
                      .auto_awesome_rounded,
                  text:
                      "استكشف الجزيرة الخاصة، واختر صورك الخاصة، وأنشئ ألغازك بطريقتك.",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text(
                "إغلاق",
                style:
                    TextStyle(
                  color:
                      Color(
                    0xFFD6B8FF,
                  ),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ================================================================
// 🏝️ الجزيرة الخاصة
// ================================================================

class _PrivateIslandWidget
    extends StatelessWidget {
  final bool unlocked;
  final bool unlocking;

  final VoidCallback onTap;
  final VoidCallback onUnlockTap;

  const _PrivateIslandWidget({
    required this.unlocked,
    required this.unlocking,
    required this.onTap,
    required this.onUnlockTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      behavior:
          HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 86,
        height: 110,
        child: Stack(
          alignment:
              Alignment.center,
          children: [
            AnimatedOpacity(
              duration:
                  const Duration(
                milliseconds: 450,
              ),
              curve:
                  Curves.easeInOut,
              opacity:
                  unlocked ? 1.0 : 0.48,
              child: Image.asset(
                "assets/images/islands/private_island.png",
                width: 76,
                height: 76,
                fit: BoxFit.contain,
                filterQuality:
                    FilterQuality.high,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const SizedBox
                      .shrink();
                },
              ),
            ),

            if (!unlocked)
              Positioned(
                top: 4,
                child: Image.asset(
                  "assets/images/ui/lock.png",
                  width: 44,
                  height: 44,
                  fit:
                      BoxFit.contain,
                  errorBuilder: (
                    context,
                    error,
                    stack,
                  ) {
                    return const Icon(
                      Icons
                          .lock_rounded,
                      color:
                          Colors.amber,
                      size: 40,
                    );
                  },
                ),
              ),

            if (!unlocked)
              Positioned(
                bottom: 0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: unlocking ? null : onUnlockTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B3A7D).withOpacity(0.96),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.85),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.30),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.18),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/rewards/gem.png",
                            width: 15,
                            height: 15,
                            fit: BoxFit.contain,
                            errorBuilder: (
                              context,
                              error,
                              stack,
                            ) {
                              return const SizedBox(
                                width: 15,
                                height: 15,
                              );
                            },
                          ),
                          const SizedBox(width: 3),
                          const Text(
                            "فتح",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// 🎁 المكافأة اليومية
// ================================================================

class _DailyRewardMiniWidget
    extends StatelessWidget {
  final bool available;
  final Duration remaining;
  final String timeText;

  const _DailyRewardMiniWidget({
    required this.available,
    required this.remaining,
    required this.timeText,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Image.asset(
              "assets/images/rewards/daly_box_close.png",
              width: 58,
              height: 58,
              fit:
                  BoxFit.contain,
              errorBuilder: (
                context,
                error,
                stack,
              ) {
                return Icon(
                  Icons
                      .card_giftcard_rounded,
                  color: available
                      ? Colors.amber
                      : Colors.white38,
                  size: 38,
                );
              },
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 6,
              vertical: 3,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFF1A0E2A,
              ).withOpacity(
                0.92,
              ),
              borderRadius:
                  BorderRadius.circular(
                8,
              ),
              border:
                  Border.all(
                color: available
                    ? Colors.amber
                        .withOpacity(
                        0.80,
                      )
                    : Colors.white24,
                width: 1,
              ),
            ),
            child: Text(
              available
                  ? "00:00:00"
                  : timeText,
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: available
                    ? Colors.amber
                    : Colors.white70,
                fontSize: 10,
                fontWeight:
                    FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),

          if (available)
            const Padding(
              padding:
                  EdgeInsets.only(
                top: 2,
              ),
              child: Text(
                "جاهز",
                style:
                    TextStyle(
                  color:
                      Colors.amber,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ================================================================
// 👛 المحفظة
// ================================================================

class _AnimatedRoyalWallet
    extends StatelessWidget {
  final Animation<double>
      controller;

  const _AnimatedRoyalWallet({
    required this.controller,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return AnimatedBuilder(
      animation: controller,
      builder: (
        context,
        child,
      ) {
        final pulse =
            controller.value;

        return Container(
          decoration:
              BoxDecoration(
            shape:
                BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:
                    const Color(
                  0xFF6A35C9,
                ).withOpacity(
                  0.25 +
                      pulse * 0.12,
                ),
                blurRadius:
                    16 + pulse * 5,
                spreadRadius:
                    2 + pulse * 2,
              ),
            ],
          ),
          child:
              Transform.scale(
            scale:
                1.15 +
                    pulse * 0.025,
            child:
                const WalletIconWidget(),
          ),
        );
      },
    );
  }
}

// ================================================================
// ⚙️ زر الإعدادات
// ================================================================

class _AnimatedRoyalImageIcon
    extends StatelessWidget {
  final Animation<double>
      controller;

  final String image;

  const _AnimatedRoyalImageIcon({
    required this.controller,
    required this.image,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return AnimatedBuilder(
      animation: controller,
      builder: (
        context,
        child,
      ) {
        final pulse =
            controller.value;

        return SizedBox(
          width: 56,
          height: 56,
          child:
              Transform.scale(
            scale:
                1.0 +
                    pulse * 0.035,
            child: Image.asset(
              image,
              width: 34,
              height: 34,
              fit:
                  BoxFit.contain,
              errorBuilder: (
                context,
                error,
                stack,
              ) {
                return const Icon(
                  Icons
                      .settings_rounded,
                  color:
                      Color(
                    0xFFD6B8FF,
                  ),
                  size: 29,
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ================================================================
// ⚙️ عنصر الإعدادات
// ================================================================

class _SettingsTile
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor =
        const Color(
      0xFFD6B8FF,
    ),
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListTile(
      contentPadding:
          const EdgeInsets
              .symmetric(
        horizontal: 4,
        vertical: 2,
      ),
      leading: Container(
        width: 42,
        height: 42,
        decoration:
            BoxDecoration(
          shape:
              BoxShape.circle,
          color:
              const Color(
            0xFF6A35C9,
          ).withOpacity(
            0.16,
          ),
        ),
        child: Icon(
          icon,
          color:
              iconColor,
        ),
      ),
      title: Text(
        title,
        textAlign:
            TextAlign.right,
        style:
            const TextStyle(
          color:
              Colors.white,
          fontWeight:
              FontWeight.w600,
        ),
      ),
      subtitle:
          subtitle == null
              ? null
              : Text(
                  subtitle!,
                  textAlign:
                      TextAlign.right,
                  style:
                      const TextStyle(
                    color:
                        Colors.white54,
                    fontSize: 12,
                  ),
                ),
      trailing:
          trailing ??
              const Icon(
                Icons
                    .chevron_left_rounded,
                color:
                    Colors.white38,
              ),
      onTap: onTap,
    );
  }
}

// ================================================================
// ℹ️ قسم معلومات
// ================================================================

class _AboutSection
    extends StatelessWidget {
  final String title;
  final IconData icon;
  final String text;

  const _AboutSection({
    required this.title,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        11,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFF6A35C9,
        ).withOpacity(
          0.10,
        ),
        borderRadius:
            BorderRadius.circular(
          15,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFD6B8FF,
          ).withOpacity(
            0.12,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                color:
                    const Color(
                  0xFFD6B8FF,
                ),
                size: 21,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign:
                      TextAlign.right,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            text,
            textAlign:
                TextAlign.right,
            style:
                const TextStyle(
              color:
                  Colors.white70,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
