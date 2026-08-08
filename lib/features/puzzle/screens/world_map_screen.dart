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
import '../managers/ads_manager.dart';
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
  State<WorldMapScreen> createState() =>
      _WorldMapScreenState();
}

class _WorldMapScreenState
    extends State<WorldMapScreen>
    with TickerProviderStateMixin {
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

  String? processingIslandId;

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
      image:
          "assets/images/background/cloud_01.png",
      top: 80 / worldHeight,
      size: 280 / worldWidth,
      opacity: 0.22,
      duration:
          const Duration(seconds: 55),
    ),

    _RelativeCloud(
      image:
          "assets/images/background/cloud_02.png",
      top: 200 / worldHeight,
      size: 220 / worldWidth,
      opacity: 0.22,
      duration:
          const Duration(seconds: 70),
    ),

    _RelativeCloud(
      image:
          "assets/images/background/cloud_03.png",
      top: 40 / worldHeight,
      size: 170 / worldWidth,
      opacity: 0.22,
      duration:
          const Duration(seconds: 90),
    ),

    _RelativeCloud(
      image:
          "assets/images/background/cloud_04.png",
      top: 300 / worldHeight,
      size: 240 / worldWidth,
      opacity: 0.22,
      duration:
          const Duration(seconds: 65),
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

    iconGlowController =
        AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    loadIslandState();

    loadPrivateIslandState();

    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) async {
        final canClaim =
            await RewardManager
                .canClaimDailyReward();

        if (!mounted) return;

        if (canClaim) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return DailyRewardPopup(
                onRewardClaimed: () {},
              );
            },
          );
        }
      },
    );

    worldController =
        AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 22),
    )..repeat(reverse: true);

    worldScale =
        Tween<double>(
      begin: 1.00,
      end: 1.035,
    ).animate(
      CurvedAnimation(
        parent: worldController,
        curve: Curves.easeInOut,
      ),
    );

    worldTranslateY =
        Tween<double>(
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
          (cloud) =>
              AnimationController(
            vsync: this,
            duration: cloud.duration,
          )..repeat(),
        )
        .toList();
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
            await PuzzleProgressManager
                .isIslandUnlocked(
          islandId,
        );

        islandUnlocked[islandId] =
            unlocked ||
                islandId == "animals";
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
  // 💎 الجزيرة الخاصة
  // ============================================================

  Future<void> loadPrivateIslandState() async {
    try {
      final unlocked =
          await PuzzleProgressManager
              .isPrivateIslandUnlocked();

      if (!mounted) return;

      setState(() {
        privateIslandUnlocked =
            unlocked;
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

  void showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor:
              const Color(0xFF4A247A),
          behavior:
              SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
          content: Text(
            message,
            textAlign: language.isArabic
                ? TextAlign.right
                : TextAlign.left,
            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight:
                  FontWeight.w600,
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
        MediaQuery.of(context)
            .padding
            .bottom;

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
              (screenWidth -
                      scaledWidth) /
                  2;

          final double dy =
              (screenHeight -
                      scaledHeight) /
                  2;

          return ClipRect(
            child: Stack(
              children: [
                // ==================================================
                // 🌍 الخريطة
                // ==================================================

                Positioned(
                  left: dx,
                  top: dy,
                  child:
                      Transform.scale(
                    scale: scale,
                    alignment:
                        Alignment.topLeft,
                    child: SizedBox(
                      width: worldWidth,
                      height: worldHeight,
                      child:
                          AnimatedBuilder(
                        animation:
                            worldController,
                        builder: (
                          context,
                          child,
                        ) {
                          return Transform
                              .translate(
                            offset: Offset(
                              0,
                              worldTranslateY
                                  .value,
                            ),
                            child:
                                Transform.scale(
                              scale:
                                  worldScale
                                      .value,
                              alignment:
                                  Alignment
                                      .center,
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
                // ⚙️ الإعدادات
                // ==================================================

                Positioned(
                  top:
                      MediaQuery.of(context)
                              .padding
                              .top +
                          16,
                  right: 18,
                  child:
                      _AnimatedRoyalIcon(
                    controller:
                        iconGlowController,
                    icon:
                        Icons.settings_rounded,
                    onTap: () async {
                      await playClickSound();

                      if (!mounted) return;

                      await showSettingsDialog();
                    },
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
                // 🏝️ الجزيرة الخاصة
                // ==================================================

                Positioned(
                  bottom:
                      bottomPadding + 20,
                  right: 20,
                  child: GestureDetector(
                    onTap:
                        unlockingPrivateIsland
                            ? null
                            : openPrivateIsland,
                    child:
                        AnimatedBuilder(
                      animation:
                          iconGlowController,
                      builder: (
                        context,
                        child,
                      ) {
                        final pulse =
                            iconGlowController
                                .value;

                        return Container(
                          decoration:
                              BoxDecoration(
                            shape: BoxShape
                                .circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(
                                  0xFF6A35C9,
                                ).withOpacity(
                                  0.20 +
                                      pulse *
                                          0.10,
                                ),
                                blurRadius:
                                    16 +
                                        pulse *
                                            5,
                                spreadRadius:
                                    2 +
                                        pulse *
                                            2,
                              ),
                            ],
                          ),
                          child:
                              Transform.scale(
                            scale:
                                1.10 +
                                    pulse *
                                        0.025,
                            child:
                                SizedBox(
                              width: 55,
                              height: 55,
                              child:
                                  Image.asset(
                                "assets/images/ui/private_island.png",
                                fit: BoxFit
                                    .contain,
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
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // ==================================================
                // 🔄 تحميل
                // ==================================================

                if (loadingIslandState)
                  Positioned.fill(
                    child:
                        IgnorePointer(
                      child: Container(
                        color: Colors.black
                            .withOpacity(
                          0.12,
                        ),
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
                    child:
                        IgnorePointer(
                      child: Container(
                        color: Colors.black
                            .withOpacity(
                          0.15,
                        ),
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
          left:
              (worldWidth + 100) -
                  (controller.value *
                      (worldWidth + 400)),
          top: top,
          child: Opacity(
            opacity: cloud.opacity,
            child:
                Transform.rotate(
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
      child: GestureDetector(
        onTap: () async {
          await playClickSound();

          await openIsland(island);
        },
        behavior:
            HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              duration:
                  const Duration(
                milliseconds: 450,
              ),
              curve: Curves.easeInOut,
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
              Positioned(
                right: 20,
                top: 20,
                child: Image.asset(
                  "assets/images/ui/lock.png",
                  width: 70,
                  height: 70,
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
  // 📺 عدد الإعلانات
  // ============================================================

  int getIslandRequiredAds(
    String islandId,
  ) {
    switch (islandId) {
      case "animals":
        return 0;

      case "nature":
        return 50;

      case "cars":
        return 75;

      case "landmarks":
        return 100;

      case "space":
        return 150;

      default:
        return 999999;
    }
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

    if (unlocked) {
      if (!mounted) return;

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

      return;
    }

    await showIslandAdsDialog(
      island,
    );
  }

  // ============================================================
  // 📺 نافذة فتح الجزيرة
  // ============================================================

  Future<void> showIslandAdsDialog(
    PuzzleModel island,
  ) async {
    final requiredAds =
        getIslandRequiredAds(
      island.id,
    );

    final currentAds =
        await PuzzleProgressManager
            .getAdsBalance();

    if (!mounted) return;

    if (currentAds >= requiredAds) {
      final paid =
          await PuzzleProgressManager
              .spendAdsBalance(
        requiredAds,
      );

      if (paid) {
        await PuzzleProgressManager
            .unlockIsland(
          island.id,
        );

        if (!mounted) return;

        setState(() {
          islandUnlocked[
              island.id] = true;
        });

        await openUnlockedIsland(
          island,
        );

        return;
      }
    }

    showDialog(
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
                  const Color(0xFF2A1B3D),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              title: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/ui/lock.png",
                    width: 34,
                    height: 34,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    t(
                      ar: "الجزيرة مغلقة",
                      en: "Island Locked",
                    ),
                    style:
                        const TextStyle(
                      color:
                          Colors.amber,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),

              content:
                  FutureBuilder<int>(
                future:
                    PuzzleProgressManager
                        .getAdsBalance(),
                builder: (
                  context,
                  snapshot,
                ) {
                  final balance =
                      snapshot.data ??
                          currentAds;

                  final remaining =
                      math.max(
                    0,
                    requiredAds -
                        balance,
                  );

                  return Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Text(
                        t(
                          ar:
                              "شاهد إعلانات للحصول على رصيد فتح الجزر.",
                          en:
                              "Watch ads to earn island unlock credits.",
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
                          const Icon(
                            Icons
                                .ondemand_video,
                            color:
                                Colors.amber,
                            size: 38,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "$requiredAds",
                            style:
                                const TextStyle(
                              color:
                                  Colors.amber,
                              fontSize:
                                  28,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Text(
                        t(
                          ar:
                              "رصيد الإعلانات: $balance",
                          en:
                              "Ad credits: $balance",
                        ),
                        style:
                            const TextStyle(
                          color:
                              Colors.white70,
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
                                "متبقي $remaining مشاهدة",
                            en:
                                "$remaining views remaining",
                          ),
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
                                "يمكن فتح الجزيرة الآن",
                            en:
                                "The island can be unlocked now",
                          ),
                          style:
                              const TextStyle(
                            color:
                                Colors.greenAccent,
                            fontWeight:
                                FontWeight
                                    .bold,
                            fontSize:
                                15,
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
                  icon: const Icon(
                    Icons
                        .ondemand_video,
                  ),
                  label: Text(
                    t(
                      ar: "شاهد إعلان",
                      en: "Watch Ad",
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
                              await watchIslandAd(
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
  // 📺 مشاهدة إعلان
  // ============================================================

  Future<void> watchIslandAd(
    PuzzleModel island,
    BuildContext dialogContext,
    StateSetter setDialogState,
  ) async {
    if (unlockingIsland) {
      return;
    }

    setState(() {
      unlockingIsland = true;
      processingIslandId =
          island.id;
    });

    setDialogState(() {});

    AdsManager()
        .showRewardedAd(
      onRewardEarned: () async {
        final balance =
            await PuzzleProgressManager
                .getAdsBalance();

        final required =
            getIslandRequiredAds(
          island.id,
        );

        if (balance >= required) {
          final paid =
              await PuzzleProgressManager
                  .spendAdsBalance(
            required,
          );

          if (paid) {
            await PuzzleProgressManager
                .unlockIsland(
              island.id,
            );

            islandUnlocked[
                island.id] = true;

            if (mounted) {
              setState(() {
                unlockingIsland =
                    false;
                processingIslandId =
                    null;
              });
            }

            if (dialogContext
                .mounted) {
              Navigator.pop(
                dialogContext,
              );
            }

            if (!mounted) return;

            showMessage(
              t(
                ar:
                    "تم فتح جزيرة ${getIslandName(island.id)}!",
                en:
                    "${getIslandName(island.id)} island unlocked!",
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
                    IslandScreen(
                  island: island,
                ),
              ),
            );

            return;
          }
        }

        if (mounted) {
          setState(() {
            unlockingIsland =
                false;
            processingIslandId =
                null;
          });
        }

        if (dialogContext
            .mounted) {
          setDialogState(() {});
        }
      },

      onAdFailed: () {
        if (!mounted) return;

        setState(() {
          unlockingIsland =
              false;
          processingIslandId =
              null;
        });

        if (dialogContext
            .mounted) {
          setDialogState(() {});
        }

        showMessage(
          t(
            ar:
                "تعذر تشغيل الإعلان. حاول مرة أخرى.",
            en:
                "The ad could not be played. Please try again.",
          ),
        );
      },
    );
  }

  // ============================================================
  // 🏝️ فتح الجزيرة بعد النجاح
  // ============================================================

  Future<void> openUnlockedIsland(
    PuzzleModel island,
  ) async {
    if (!mounted) return;

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
  // 🏝️ الجزيرة الخاصة
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

    showDialog(
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
              ar: "الجزيرة الخاصة",
              en: "Private Island",
            ),
            textAlign:
                TextAlign.center,
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
                t(
                  ar:
                      "افتح جزيرتك الخاصة وأنشئ ألغازك من صورك الخاصة.",
                  en:
                      "Unlock your private island and create puzzles from your own photos.",
                ),
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color: Colors.white,
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
                    fit: BoxFit.contain,
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
                          FontWeight.bold,
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
                      ar: "رصيدك الحالي: ",
                      en: "Your balance: ",
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
                          FontWeight.bold,
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
                  ElevatedButton.styleFrom(
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
  // 💎 شراء الجزيرة الخاصة
  // ============================================================

  Future<void> buyPrivateIsland(
    BuildContext dialogContext,
  ) async {
    if (unlockingPrivateIsland) {
      return;
    }

    setState(() {
      unlockingPrivateIsland =
          true;
    });

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
              "لا تملك $privateIslandGemCost 💎 لفتح الجزيرة الخاصة.",
          en:
              "You don't have $privateIslandGemCost 💎 to unlock the private island.",
        ),
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

    showMessage(
      t(
        ar: "تم فتح جزيرتك الخاصة!",
        en: "Your private island is unlocked!",
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

                          setState(() {
                            soundEnabled =
                                value;
                          });
                        },
                      ),
                    ),

                    // ==========================================
                    // 🌐 اللغة
                    // ==========================================

                    _SettingsTile(
                      icon:
                          Icons
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
                      icon:
                          Icons
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
                      icon:
                          Icons
                              .exit_to_app_rounded,
                      title: t(
                        ar:
                            "إغلاق التطبيق",
                        en:
                            "Exit App",
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
                        Color(0xFFD6B8FF),
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
                        "تبدأ جزيرة الحيوانات مفتوحة. أما باقي الجزر فتُفتح من خلال رصيد مشاهدة الإعلانات.",
                    en:
                        "The Animals Island starts unlocked. Other islands are unlocked using ad-view credits.",
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                _AboutSection(
                  title: t(
                    ar:
                        "نظام الجزيرة الخاصة",
                    en:
                        "Private Island System",
                  ),
                  icon:
                      Icons
                          .photo_library_rounded,
                  text: t(
                    ar:
                        "يمكنك فتح الجزيرة الخاصة باستخدام الجواهر، ثم إنشاء ألغاز من صورك الخاصة.",
                    en:
                        "You can unlock the Private Island with gems and create puzzles from your own photos.",
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
                  icon:
                      Icons
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

class _AnimatedRoyalIcon
    extends StatelessWidget {
  final Animation<double> controller;

  final IconData icon;

  final VoidCallback onTap;

  const _AnimatedRoyalIcon({
    required this.controller,
    required this.icon,
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
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration:
                BoxDecoration(
              shape:
                  BoxShape.circle,
              color:
                  const Color(
                0xFF4A247A,
              ).withOpacity(0.76),
              border:
                  Border.all(
                color:
                    const Color(
                  0xFFD0A8FF,
                ).withOpacity(0.28),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      const Color(
                    0xFF6A35C9,
                  ).withOpacity(
                    0.22 +
                        pulse * 0.12,
                  ),
                  blurRadius:
                      14 + pulse * 5,
                  spreadRadius:
                      2 + pulse * 2,
                ),
              ],
            ),
            child:
                Transform.scale(
              scale:
                  1.0 +
                      pulse * 0.035,
              child: Icon(
                icon,
                color:
                    const Color(
                  0xFFD6B8FF,
                ),
                size: 29,
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
          const EdgeInsets.symmetric(
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
      width:
          double.infinity,
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
                          ? TextAlign.right
                          : TextAlign.left,
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