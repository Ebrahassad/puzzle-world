import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../core/language/app_language_manager.dart';
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
  // 🌍 الخريطة
  // ============================================================

  static const String mapImage =
      "assets/images/world/world_map.jpg";

  static const double worldWidth = 896;
  static const double worldHeight = 1350;

  // ============================================================
  // 🏝️ الجزيرة الغامضة
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

    loadIslandState();
    loadPrivateIslandState();

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

    _checkDailyReward();
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

  String formatDailyRewardTime(Duration duration) {
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
  // 💎 الجزيرة الغامضة
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
  // 🌐 اللغة
  // ============================================================

  AppLanguageManager get language =>
      AppLanguageManager.instance;

  String t({
    required String ar,
    required String en,
  }) {
    return language.text(
      ar: ar,
      en: en,
    );
  }

  // ============================================================
  // 📢 رسالة موحدة
  // ============================================================

  void showMessage(String message) {
    if (!mounted) return;

    final messenger =
        ScaffoldMessenger.maybeOf(context);

    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor:
              const Color(0xFF4A247A),
          behavior:
              SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            24,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
          duration:
              const Duration(seconds: 3),
          content: Text(
            message,
            textAlign: language.isArabic
                ? TextAlign.right
                : TextAlign.left,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
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

    worldController.dispose();
    iconGlowController.dispose();
    audioPlayer.dispose();

    for (final controller
        in cloudControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  // ============================================================
  // 🔎 البحث عن الجزيرة
  // ============================================================

  PuzzleModel? getIsland(String id) {
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
      backgroundColor:
          const Color(0xff08182b),
      body: LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final double screenWidth =
              constraints.maxWidth;

          final double screenHeight =
              constraints.maxHeight;

          if (screenWidth <= 0 ||
              screenHeight <= 0) {
            return const SizedBox.shrink();
          }

          final double scale =
              math.max(
            screenWidth / worldWidth,
            screenHeight / worldHeight,
          );

          final double scaledWidth =
              worldWidth * scale;

          final double scaledHeight =
              worldHeight * scale;

          final double dx =
              (screenWidth - scaledWidth) / 2;

          final double dy =
              (screenHeight - scaledHeight) / 2;

          return ClipRect(
            child: Stack(
              children: [
                // ==================================================
                // 🌍 الخريطة — بدون تغيير
                // ==================================================

                Positioned(
                  left: dx,
                  top: dy,
                  child: Transform.scale(
                    scale: scale,
                    alignment:
                        Alignment.topLeft,
                    child: SizedBox(
                      width: worldWidth,
                      height: worldHeight,
                      child: AnimatedBuilder(
                        animation:
                            worldController,
                        builder: (
                          context,
                          child,
                        ) {
                          return Transform.translate(
                            offset: Offset(
                              0,
                              worldTranslateY
                                  .value,
                            ),
                            child:
                                Transform.scale(
                              scale:
                                  worldScale.value,
                              alignment:
                                  Alignment.center,
                              child: child,
                            ),
                          );
                        },
                        child: SizedBox(
                          width: worldWidth,
                          height: worldHeight,
                          child: Stack(
                            clipBehavior:
                                Clip.none,
                            children: [
                              // =================================
                              // 🗺️ صورة الخريطة
                              // =================================

                              Positioned.fill(
                                child:
                                    Image.asset(
                                  mapImage,
                                  fit:
                                      BoxFit.cover,
                                  errorBuilder:
                                      (
                                    context,
                                    error,
                                    stack,
                                  ) {
                                    return const SizedBox
                                        .shrink();
                                  },
                                ),
                              ),

                              // =================================
                              // ☁️ السحب
                              // =================================

                              for (
                                int i = 0;
                                i < _clouds.length;
                                i++
                              )
                                cloudWidget(
                                  cloud:
                                      _clouds[i],
                                  controller:
                                      cloudControllers[
                                          i],
                                ),

                              // =================================
                              // 🏝️ الجزر الكبيرة
                              // =================================

                              for (
                                final rect
                                    in _islandRects
                              )
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
                // 🎁 صندوق المكافأة اليومية
                // ==================================================
                //
                // تم إصلاح الضغط:
                // الصندوق يستقبل الضغط دائمًا حتى أثناء العد
                // وعند الضغط أثناء الانتظار يتم تحديث الرسالة.
                // ==================================================

                Positioned(
                  top: topPadding + 16,
                  left: 16,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await playClickSound();

                        if (!mounted) return;

                        final canClaim =
                            await RewardManager
                                .canClaimDailyReward();

                        if (!mounted) return;

                        if (!canClaim) {
                          final remaining =
                              await RewardManager
                                  .getDailyRewardRemaining();

                          if (!mounted) return;

                          setState(() {
                            dailyRewardAvailable =
                                false;
                            dailyRewardRemaining =
                                remaining;
                          });

                          showMessage(
                            t(
                              ar:
                                  "المكافأة اليومية غير جاهزة بعد. المتبقي: ${formatDailyRewardTime(remaining)}",
                              en:
                                  "The daily reward is not ready yet. Remaining: ${formatDailyRewardTime(remaining)}",
                            ),
                          );

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

                        if (!mounted) return;

                        setState(() {
                          showingDailyReward =
                              false;
                          dailyRewardMiniVisible =
                              true;
                        });

                        await _checkDailyReward();
                      },
                      borderRadius:
                          BorderRadius.circular(
                        40,
                      ),
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
                        onTap: null,
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // ⚙️ الإعدادات
                // ==================================================

                Positioned(
                  top: topPadding + 16,
                  right: 18,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () async {
                        await playClickSound();

                        if (!mounted) return;

                        await showSettingsDialog();
                      },
                      borderRadius:
                          BorderRadius.circular(
                        32,
                      ),
                      child:
                          _AnimatedRoyalImageIcon(
                        controller:
                            iconGlowController,
                        image:
                            "assets/images/ui/seting_icon.png",
                        onTap: null,
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // 👛 المحفظة
                // ==================================================

                Positioned(
                  bottom:
                      bottomPadding + 20,
                  left: 20,
                  child: GestureDetector(
                    behavior:
                        HitTestBehavior.opaque,
                    onTap: () async {
                      await playClickSound();

                      if (!context.mounted) {
                        return;
                      }
                    },
                    child:
                        _AnimatedRoyalWallet(
                      controller:
                          iconGlowController,
                    ),
                  ),
                ),

                // ==================================================
                // 🏝️ الجزيرة الغامضة
                // ==================================================

                Positioned(
                  bottom:
                      bottomPadding + 20,
                  right: 18,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap:
                          unlockingPrivateIsland
                              ? null
                              : () async {
                                  await openPrivateIsland();
                                },
                      borderRadius:
                          BorderRadius.circular(
                        40,
                      ),
                      child: SizedBox(
                        width: 78,
                        height: 78,
                        child: Center(
                          child: Image.asset(
                            "assets/images/islands/private_island.png",
                            width: 70,
                            height: 70,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (
                              context,
                              error,
                              stack,
                            ) {
                              return const Icon(
                                Icons
                                    .island_rounded,
                                color: Color(
                                  0xFFD6B8FF,
                                ),
                                size: 58,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ==================================================
                // 🔄 تحميل
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
                            color:
                                Colors.amber,
                          ),
                        ),
                      ),
                    ),
                  ),

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
                            color:
                                Colors.amber,
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
    final double top =
        cloud.top * worldHeight;

    final double size =
        cloud.size * worldWidth;

    return AnimatedBuilder(
      animation: controller,
      builder: (
        context,
        child,
      ) {
        return Positioned(
          left: (worldWidth + 100) -
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

    final double left =
        rect.left * worldWidth;

    final double top =
        rect.top * worldHeight;

    final double width =
        rect.width * worldWidth;

    final double height =
        rect.height * worldHeight;

    final bool locked =
        !isIslandUnlockedLocal(
      rect.id,
    );

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ==================================================
          // صورة الجزيرة
          // ==================================================

          GestureDetector(
            behavior:
                HitTestBehavior.opaque,
            onTap: locked
                ? null
                : () async {
                    await playClickSound();

                    if (!mounted) return;

                    await openIsland(
                      island,
                    );
                  },
            child: AnimatedOpacity(
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
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          // ==================================================
          // القفل
          // ==================================================

          if (locked)
            IgnorePointer(
              child: Center(
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
            ),

          // ==================================================
          // زر فتح الجزيرة
          //
          // تم جعله مستقلًا عن GestureDetector
          // الخاص بالجزيرة حتى لا يمنع الضغط.
          // ==================================================

          if (locked)
            Positioned(
              bottom: height * 0.10,
              child: Material(
                color:
                    Colors.transparent,
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(
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
                        0xFF2A1B3D,
                      ).withOpacity(0.95),
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
                          fit: BoxFit
                              .contain,
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
                        Text(
                          t(
                            ar: "فتح",
                            en: "Unlock",
                          ),
                          style:
                              const TextStyle(
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

    return islandUnlocked[islandId] ??
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
      showMessage(
        t(
          ar:
              "هذه الجزيرة مغلقة. اضغط على زر فتح لشرائها.",
          en:
              "This island is locked. Tap Unlock to purchase it.",
        ),
      );
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
      builder: (dialogContext) {
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
                        Icons.lock_rounded,
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
                      t(
                        ar:
                            "${getIslandName(island.id)} مغلقة",
                        en:
                            "${getIslandName(island.id)} is locked",
                      ),
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
                      Text(
                        t(
                          ar:
                              "يمكنك شراء هذه الجزيرة باستخدام النجوم.",
                          en:
                              "You can unlock this island using stars.",
                        ),
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
                            fit: BoxFit
                                .contain,
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
                        t(
                          ar:
                              "نجومك الحالية: $stars ⭐",
                          en:
                              "Your current stars: $stars ⭐",
                        ),
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
                      if (remaining > 0)
                        Text(
                          t(
                            ar:
                                "تحتاج إلى $remaining ⭐ إضافية.",
                            en:
                                "You need $remaining more ⭐.",
                          ),
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
                        Text(
                          t(
                            ar:
                                "يمكنك شراء الجزيرة الآن.",
                            en:
                                "You can unlock the island now.",
                          ),
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            color: Colors
                                .greenAccent,
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
                  child: Text(
                    t(
                      ar: "إلغاء",
                      en: "Cancel",
                    ),
                    style:
                        const TextStyle(
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
                    fit: BoxFit.contain,
                  ),
                  label: Text(
                    t(
                      ar: "شراء وفتح",
                      en: "Buy & Unlock",
                    ),
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

    if (mounted) {
      setState(() {
        unlockingIsland = true;
      });
    }

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
          setDialogState(() {});
        }

        showMessage(
          t(
            ar:
                "لا تملك نجومًا كافية. تحتاج $requiredStars ⭐ لفتح جزيرة ${getIslandName(island.id)}.",
            en:
                "You don't have enough stars. You need $requiredStars ⭐ to unlock ${getIslandName(island.id)}.",
          ),
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
          setDialogState(() {});
        }

        showMessage(
          t(
            ar:
                "تعذر شراء الجزيرة. تأكد من رصيد النجوم.",
            en:
                "The island could not be purchased. Please check your star balance.",
          ),
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

      // ======================================================
      // 💬 رسالة نجاح الشراء
      // ======================================================

      showMessage(
        t(
          ar:
              "تم شراء وفتح جزيرة ${getIslandName(island.id)} بنجاح! ⭐",
          en:
              "${getIslandName(island.id)} island has been purchased and unlocked! ⭐",
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        unlockingIsland = false;
      });

      if (dialogContext.mounted) {
        setDialogState(() {});
      }

      showMessage(
        t(
          ar:
              "حدث خطأ أثناء فتح الجزيرة.",
          en:
              "An error occurred while unlocking the island.",
        ),
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
        return t(
          ar: "الحيوانات",
          en: "Animals",
        );

      case "nature":
        return t(
          ar: "الطبيعة",
          en: "Nature",
        );

      case "cars":
        return t(
          ar: "السيارات",
          en: "Cars",
        );

      case "landmarks":
        return t(
          ar: "المعالم",
          en: "Landmarks",
        );

      case "space":
        return t(
          ar: "الفضاء",
          en: "Space",
        );

      default:
        return t(
          ar: "الجديدة",
          en: "New",
        );
    }
  }

  // ============================================================
  // 🏝️ الجزيرة الغامضة
  // ============================================================

  Future<void> openPrivateIsland() async {
    await playClickSound();

    if (!mounted) return;

    final unlocked =
        await PuzzleProgressManager
            .isPrivateIslandUnlocked();

    if (unlocked) {
      setState(() {
        privateIslandUnlocked =
            true;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const PrivateIslandScreen(),
        ),
      );

      return;
    }

    final gems =
        await PuzzleProgressManager
            .getGems();

    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF2A1B3D),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),
          title: Text(
            t(
              ar: "الجزيرة الغامضة",
              en: "Mystery Island",
            ),
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
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Text(
                t(
                  ar:
                      "افتح جزيرتك الغامضة وأنشئ ألغازك من صورك الخاصة.",
                  en:
                      "Unlock your Mystery Island and create puzzles from your own photos.",
                ),
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
                height: 20,
              ),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  Image.asset(
                    "assets/images/rewards/gem.png",
                    width: 48,
                    height: 48,
                    fit: BoxFit
                        .contain,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    "$privateIslandGemCost",
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
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  Text(
                    t(
                      ar:
                          "رصيدك الحالي: ",
                      en:
                          "Your balance: ",
                    ),
                    style:
                        const TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "$gems",
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 16,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Image.asset(
                    "assets/images/rewards/gem.png",
                    width: 24,
                    height: 24,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: Text(
                t(
                  ar: "إلغاء",
                  en: "Cancel",
                ),
                style:
                    const TextStyle(
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
              ),
              label: Text(
                t(
                  ar: "شراء وفتح",
                  en: "Buy & Unlock",
                ),
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
                          );
                        },
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // 💎 شراء الجزيرة الغامضة
  // ============================================================

  Future<void> buyPrivateIsland(
    BuildContext dialogContext,
  ) async {
    if (unlockingPrivateIsland) {
      return;
    }

    if (mounted) {
      setState(() {
        unlockingPrivateIsland =
            true;
      });
    }

    try {
      final paid =
          await PuzzleProgressManager
              .buyPrivateIslandWithGems();

      if (!paid) {
        if (!mounted) return;

        setState(() {
          unlockingPrivateIsland =
              false;
        });

        showMessage(
          t(
            ar:
                "لا تملك $privateIslandGemCost 💎 لفتح الجزيرة الغامضة.",
            en:
                "You don't have $privateIslandGemCost 💎 to unlock the Mystery Island.",
          ),
        );

        return;
      }

      if (!mounted) return;

      setState(() {
        privateIslandUnlocked = true;
        unlockingPrivateIsland =
            false;
      });

      if (dialogContext.mounted) {
        Navigator.pop(
          dialogContext,
        );
      }

      // ======================================================
      // 💬 رسالة نجاح الجزيرة الغامضة
      // ======================================================

      showMessage(
        t(
          ar:
              "تم فتح جزيرتك الغامضة بنجاح! 💎",
          en:
              "Your Mystery Island is unlocked! 💎",
        ),
      );

      await Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const PrivateIslandScreen(),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        unlockingPrivateIsland =
            false;
      });

      showMessage(
        t(
          ar:
              "حدث خطأ أثناء فتح الجزيرة الغامضة.",
          en:
              "An error occurred while unlocking the Mystery Island.",
        ),
      );
    }
  }

  // ============================================================
  // ⚙️ نافذة الإعدادات
  // ============================================================

  Future<void> showSettingsDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
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
                        const EdgeInsets
                            .all(8),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFF6A35C9,
                      ).withOpacity(0.22),
                      shape:
                          BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(
                            0xFF7E57C2,
                          ).withOpacity(
                              0.30),
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
                  Text(
                    t(
                      ar: "الإعدادات",
                      en: "Settings",
                    ),
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontWeight:
                          FontWeight
                              .bold,
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
                    // ==========================================
                    // 🔊 الصوت
                    // ==========================================

                    _SettingsTile(
                      icon: soundEnabled
                          ? Icons
                              .volume_up_rounded
                          : Icons
                              .volume_off_rounded,
                      title: t(
                        ar: "الصوت",
                        en: "Sound",
                      ),
                      trailing:
                          Switch(
                        value:
                            soundEnabled,
                        activeColor:
                            const Color(
                          0xFF9B6DFF,
                        ),
                        onChanged:
                            (value) {
                          setDialogState(
                            () {
                              soundEnabled =
                                  value;
                            },
                          );

                          if (mounted) {
                            setState(
                              () {
                                soundEnabled =
                                    value;
                              },
                            );
                          }
                        },
                      ),
                    ),

                    // ==========================================
                    // 🌐 اللغة
                    // ==========================================

                    _SettingsTile(
                      icon: Icons
                          .language_rounded,
                      title: t(
                        ar: "اللغة",
                        en: "Language",
                      ),
                      subtitle:
                          language.isArabic
                              ? "العربية"
                              : "English",
                      onTap: () {
                        Navigator.pop(
                          dialogContext,
                        );

                        showLanguageDialog();
                      },
                    ),

                    // ==========================================
                    // ℹ️ حول
                    // ==========================================

                    _SettingsTile(
                      icon: Icons
                          .info_outline_rounded,
                      title: t(
                        ar: "حول",
                        en: "About",
                      ),
                      subtitle: t(
                        ar:
                            "معلومات Puzzle World",
                        en:
                            "Puzzle World information",
                      ),
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

                    // ==========================================
                    // 🚪 إغلاق التطبيق
                    // ==========================================

                    _SettingsTile(
                      icon: Icons
                          .exit_to_app_rounded,
                      title: t(
                        ar:
                            "إغلاق التطبيق",
                        en: "Exit App",
                      ),
                      subtitle: t(
                        ar:
                            "إغلاق Puzzle World",
                        en:
                            "Close Puzzle World",
                      ),
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

                    Text(
                      t(
                        ar:
                            "الإصدار $appVersion",
                        en:
                            "Version $appVersion",
                      ),
                      style:
                          const TextStyle(
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
  // 🌐 اختيار اللغة
  // ============================================================

  Future<void> showLanguageDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF241337),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),
          title: Text(
            t(
              ar: "اللغة",
              en: "Language",
            ),
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              _LanguageOption(
                title: "العربية",
                selected:
                    language.isArabic,
                onTap: () async {
                  await language
                      .setArabic();

                  if (!mounted) return;

                  Navigator.pop(
                    dialogContext,
                  );

                  setState(() {});
                },
              ),
              _LanguageOption(
                title: "English",
                selected:
                    language.isEnglish,
                onTap: () async {
                  await language
                      .setEnglish();

                  if (!mounted) return;

                  Navigator.pop(
                    dialogContext,
                  );

                  setState(() {});
                },
              ),
            ],
          ),
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
      builder: (dialogContext) {
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
          title: Text(
            t(
              ar: "حول Puzzle World",
              en: "About Puzzle World",
            ),
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
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
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  t(
                    ar:
                        "الإصدار $appVersion",
                    en:
                        "Version $appVersion",
                  ),
                  style:
                      const TextStyle(
                    color:
                        Colors.white54,
                  ),
                ),
                const SizedBox(
                  height: 22,
                ),
                _AboutSection(
                  title: t(
                    ar:
                        "نظام فتح الجزر",
                    en:
                        "Island Unlock System",
                  ),
                  icon:
                      Icons.public_rounded,
                  text: t(
                    ar:
                        "تبدأ جزيرة الحيوانات مفتوحة. أما باقي الجزر فتُفتح باستخدام النجوم.",
                    en:
                        "The Animals Island starts unlocked. Other islands are unlocked using stars.",
                  ),
                ),
                const SizedBox(
                  height: 14,
                ),
                _AboutSection(
                  title: t(
                    ar:
                        "نظام الجزيرة الغامضة",
                    en:
                        "Mystery Island System",
                  ),
                  icon: Icons
                      .photo_library_rounded,
                  text: t(
                    ar:
                        "يمكنك فتح الجزيرة الغامضة باستخدام 100 جوهرة، ثم إنشاء ألغاز من صورك الخاصة.",
                    en:
                        "You can unlock the Mystery Island with 100 gems and create puzzles from your own photos.",
                  ),
                ),
                const SizedBox(
                  height: 14,
                ),
                _AboutSection(
                  title: t(
                    ar:
                        "نظام الشراء والمكافآت",
                    en:
                        "Rewards System",
                  ),
                  icon: Icons
                      .shopping_bag_rounded,
                  text: t(
                    ar:
                        "تستخدم اللعبة العملات والنجوم والجواهر لإدارة المكافآت وفتح الميزات المختلفة.",
                    en:
                        "The game uses coins, stars, and gems to manage rewards and unlock different features.",
                  ),
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
              child: Text(
                t(
                  ar: "إغلاق",
                  en: "Close",
                ),
                style:
                    const TextStyle(
                  color:
                      Color(0xFFD6B8FF),
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
// 🎁 صندوق المكافأة اليومية + العد التنازلي
// ================================================================

class _DailyRewardMiniWidget
    extends StatelessWidget {
  final VoidCallback? onTap;
  final bool available;
  final Duration remaining;
  final String timeText;

  const _DailyRewardMiniWidget({
    required this.onTap,
    required this.available,
    required this.remaining,
    required this.timeText,
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
        width: 72,
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            // ==============================================
            // 🎁 الصندوق
            // ==============================================

            AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 300,
              ),
              width: 58,
              height: 58,
              padding:
                  const EdgeInsets.all(
                5,
              ),
              decoration:
                  BoxDecoration(
                shape: BoxShape.circle,
                color:
                    const Color(
                  0xFF2A1B3D,
                ).withOpacity(0.94),
                border:
                    Border.all(
                  color: available
                      ? Colors.amber
                          .withOpacity(
                          0.95,
                        )
                      : Colors.white24,
                  width: 1.6,
                ),
                boxShadow: [
                  BoxShadow(
                    color: available
                        ? Colors.amber
                            .withOpacity(
                            0.32,
                          )
                        : Colors.black
                            .withOpacity(
                            0.25,
                          ),
                    blurRadius:
                        available
                            ? 16
                            : 10,
                    spreadRadius:
                        available
                            ? 3
                            : 1,
                  ),
                ],
              ),
              child: Image.asset(
                "assets/images/rewards/daly_box_close.png",
                fit: BoxFit.contain,
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
                    size: 34,
                  );
                },
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            // ==============================================
            // ⏱️ العد التنازلي
            // ==============================================

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
                ).withOpacity(0.92),
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

            // ==============================================
            // 🎁 حالة الصندوق
            // ==============================================

            if (available)
              const Padding(
                padding:
                    EdgeInsets.only(
                  top: 2,
                ),
                child: Text(
                  "جاهز",
                  style: TextStyle(
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
      ),
    );
  }
}

// ================================================================
// 👛 المحفظة
// ================================================================

class _AnimatedRoyalWallet
    extends StatelessWidget {
  final Animation<double> controller;

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
            shape: BoxShape.circle,
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
          child: Transform.scale(
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
// ⚙️ زر الإعدادات بالصورة الجديدة
// ================================================================

class _AnimatedRoyalImageIcon
    extends StatelessWidget {
  final Animation<double> controller;
  final String image;
  final VoidCallback? onTap;

  const _AnimatedRoyalImageIcon({
    required this.controller,
    required this.image,
    required this.onTap,
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

        return GestureDetector(
          behavior:
              HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: 56,
            height: 56,
            child: Transform.scale(
              scale:
                  1.0 +
                      pulse * 0.035,
              child: Image.asset(
                image,
                width: 34,
                height: 34,
                fit: BoxFit.contain,
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
        const Color(0xFFD6B8FF),
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final bool isArabic =
        AppLanguageManager
            .instance
            .isArabic;

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
          shape: BoxShape.circle,
          color:
              const Color(
            0xFF6A35C9,
          ).withOpacity(0.16),
        ),
        child: Icon(
          icon,
          color: iconColor,
        ),
      ),
      title: Text(
        title,
        textAlign: isArabic
            ? TextAlign.right
            : TextAlign.left,
        style:
            const TextStyle(
          color: Colors.white,
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
                      isArabic
                          ? TextAlign.right
                          : TextAlign.left,
                  style:
                      const TextStyle(
                    color:
                        Colors.white54,
                    fontSize: 12,
                  ),
                ),
      trailing:
          trailing ??
              Icon(
                isArabic
                    ? Icons
                        .chevron_left_rounded
                    : Icons
                        .chevron_right_rounded,
                color:
                    Colors.white38,
              ),
      onTap: onTap,
    );
  }
}

// ================================================================
// 🌐 اختيار اللغة
// ================================================================

class _LanguageOption
    extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        textAlign:
            TextAlign.center,
        style:
            const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
      trailing: Icon(
        selected
            ? Icons
                .radio_button_checked
            : Icons
                .radio_button_off,
        color: selected
            ? const Color(
                0xFFD6B8FF,
              )
            : Colors.white38,
      ),
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
    final bool isArabic =
        AppLanguageManager
            .instance
            .isArabic;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        14,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFF6A35C9,
        ).withOpacity(0.10),
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border:
            Border.all(
          color:
              const Color(
            0xFFD6B8FF,
          ).withOpacity(0.12),
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
                size: 22,
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign:
                      isArabic
                          ? TextAlign
                              .right
                          : TextAlign
                              .left,
                  style:
                      const TextStyle(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            text,
            textAlign:
                isArabic
                    ? TextAlign.right
                    : TextAlign.left,
            style:
                const TextStyle(
              color:
                  Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}