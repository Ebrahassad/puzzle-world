import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

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
  State<WorldMapScreen> createState() => _WorldMapScreenState();
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

  // ============================================================
  // 🔊 الصوت
  // ============================================================

  late final AudioPlayer audioPlayer;

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

  // الجزيرة التي يتم التعامل معها حالياً
  String? processingIslandId;

  // ============================================================
  // 🗺️ مواقع الجزر
  // ============================================================

  static final List<_RelativeRect> _islandRects = [
    // 🚀 جزيرة الفضاء
    _RelativeRect(
      id: "space",
      left: 210 / worldWidth,
      top: 9 / worldHeight,
      width: 480 / worldWidth,
      height: 540 / worldHeight,
    ),

    // 🏛️ المعالم
    _RelativeRect(
      id: "landmarks",
      left: 100 / worldWidth,
      top: 408 / worldHeight,
      width: 335 / worldWidth,
      height: 365 / worldHeight,
    ),

    // 🚗 السيارات
    _RelativeRect(
      id: "cars",
      left: 460 / worldWidth,
      top: 408 / worldHeight,
      width: 335 / worldWidth,
      height: 365 / worldHeight,
    ),

    // 🌳 الطبيعة
    _RelativeRect(
      id: "nature",
      left: 268 / worldWidth,
      top: 595 / worldHeight,
      width: 360 / worldWidth,
      height: 380 / worldHeight,
    ),

    // 🐯 الحيوانات
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

    // ------------------------------------------------------------
    // تحميل حالة الجزر
    // ------------------------------------------------------------

    loadIslandState();

    // ------------------------------------------------------------
    // تحميل الجزيرة الخاصة
    // ------------------------------------------------------------

    loadPrivateIslandState();

    // ------------------------------------------------------------
    // 🎁 المكافأة اليومية
    //
    // لا نستدعي initAds هنا.
    // AdsManager مسؤول عن تهيئة الإعلانات من مكانه المركزي.
    // ------------------------------------------------------------

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        final canClaim =
            await RewardManager.canClaimDailyReward();

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

    // ------------------------------------------------------------
    // 🌍 Animation الخريطة
    // ------------------------------------------------------------

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

    // ------------------------------------------------------------
    // ☁️ Animation السحب
    // ------------------------------------------------------------

    cloudControllers = _clouds
        .map(
          (cloud) => AnimationController(
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
            await PuzzleProgressManager.isIslandUnlocked(
          islandId,
        );

        islandUnlocked[islandId] =
            unlocked || islandId == "animals";
      }
    } catch (_) {
      // الحيوانات تبقى مفتوحة دائماً
      islandUnlocked["animals"] = true;
    }

    if (!mounted) return;

    setState(() {
      loadingIslandState = false;
    });
  }

  // ============================================================
  // 💎 تحميل حالة الجزيرة الخاصة
  // ============================================================

  Future<void> loadPrivateIslandState() async {
    try {
      final unlocked =
          await PuzzleProgressManager
              .isPrivateIslandUnlocked();

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
  // 🔊 صوت الضغط
  // ============================================================

  Future<void> playClickSound() async {
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

    audioPlayer.dispose();

    for (final controller in cloudControllers) {
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

          // --------------------------------------------------------
          // 📐 تكبير الخريطة لتغطية الشاشة
          // --------------------------------------------------------

          final double scale = math.max(
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
                              // ------------------------------------------------
                              // 🗺️ صورة الخريطة
                              // ------------------------------------------------

                              Positioned.fill(
                                child: Image.asset(
                                  mapImage,
                                  fit: BoxFit.cover,
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

                              // ------------------------------------------------
                              // ☁️ السحب
                              // ------------------------------------------------

                              for (int i = 0;
                                  i < _clouds.length;
                                  i++)
                                cloudWidget(
                                  cloud:
                                      _clouds[i],
                                  controller:
                                      cloudControllers[
                                          i],
                                ),

                              // ------------------------------------------------
                              // 🏝️ الجزر
                              // ------------------------------------------------

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

                      // لا نغير وظيفة WalletIconWidget.
                      // الـ Widget نفسه مسؤول عن الانتقال للمحفظة.
                    },
                    child: Container(
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .amber
                                .withOpacity(
                              0.85,
                            ),
                            blurRadius: 16,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child:
                          Transform.scale(
                        scale: 1.15,
                        child:
                            const WalletIconWidget(),
                      ),
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
                    child: Container(
                      decoration:
                          BoxDecoration(
                        shape:
                            BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .amber
                                .withOpacity(
                              0.85,
                            ),
                            blurRadius: 16,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child:
                          Transform.scale(
                        scale: 1.15,
                        child: SizedBox(
                          width: 55,
                          height: 55,
                          child:
                              Image.asset(
                            "assets/images/ui/private_island.png",
                            fit:
                                BoxFit.contain,
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
                    ),
                  ),
                ),

                // ==================================================
                // 🔄 التحميل
                // ==================================================

                if (loadingIslandState)
                  Positioned.fill(
                    child: IgnorePointer(
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

                // ==================================================
                // 🔄 فتح الجزيرة
                // ==================================================

                if (unlockingIsland ||
                    unlockingPrivateIsland)
                  Positioned.fill(
                    child: IgnorePointer(
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
    final island = getIsland(rect.id);

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

          await openIsland(
            island,
          );
        },
        behavior:
            HitTestBehavior.opaque,
        child: Stack(
          alignment:
              Alignment.center,
          children: [
            // ------------------------------------------------------
            // 🏝️ صورة الجزيرة
            // ------------------------------------------------------

            Image.asset(
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

            // ------------------------------------------------------
            // 🔒 القفل
            // ------------------------------------------------------

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
                    return const Icon(
                      Icons.lock,
                      color:
                          Colors.amber,
                      size: 55,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🔎 حالة الجزيرة محلياً
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
  // 📺 عدد الإعلانات المطلوبة
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
    // ------------------------------------------------------------
    // الحيوانات مفتوحة دائماً
    // ------------------------------------------------------------

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

    // ------------------------------------------------------------
    // إذا كانت الجزيرة مفتوحة
    // ------------------------------------------------------------

    final unlocked =
        await PuzzleProgressManager
            .isIslandUnlocked(
      island.id,
    );

    if (unlocked) {
      if (!mounted) return;

      setState(() {
        islandUnlocked[island.id] =
            true;
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

    // ------------------------------------------------------------
    // الجزيرة مغلقة
    // ------------------------------------------------------------

    await showIslandAdsDialog(
      island,
    );
  }

  // ============================================================
  // 📺 نافذة فتح الجزيرة بالإعلانات
  // ============================================================

  Future<void> showIslandAdsDialog(
    PuzzleModel island,
  ) async {
    final requiredAds =
        PuzzleProgressManager
            .getIslandRequiredAds(
      island.id,
    );

    final currentAds =
        await PuzzleProgressManager
            .getAdsBalance();

    if (!mounted) return;

    // ------------------------------------------------------------
    // إذا وصل الرصيد للحد المطلوب بالفعل
    // ------------------------------------------------------------

    if (currentAds >= requiredAds) {
      final unlocked =
          await PuzzleProgressManager
              .unlockIslandWithAds(
        island.id,
      );

      if (unlocked) {
        setState(() {
          islandUnlocked[island.id] =
              true;
        });

        await openUnlockedIsland(
          island,
        );

        return;
      }
    }

    // ------------------------------------------------------------
    // Dialog
    // ------------------------------------------------------------

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
              title: const Text(
                "🔒 الجزيرة مغلقة",
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color:
                      Colors.amber,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              content: FutureBuilder<int>(
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
                      const Text(
                        "شاهد إعلانات للحصول على رصيد فتح الجزر.",
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

                      // ------------------------------------------------
                      // 📺 المطلوب
                      // ------------------------------------------------

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
                        "رصيد الإعلانات: $balance 📺",
                        style:
                            const TextStyle(
                          color:
                              Colors.white70,
                          fontSize:
                              16,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      if (remaining > 0)
                        Text(
                          "متبقي $remaining مشاهدة",
                          style:
                              const TextStyle(
                            color:
                                Colors.white,
                            fontSize:
                                15,
                          ),
                        )
                      else
                        const Text(
                          "يمكن فتح الجزيرة الآن 🎉",
                          style:
                              TextStyle(
                            color:
                                Colors.greenAccent,
                            fontWeight:
                                FontWeight.bold,
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
                  child: const Text(
                    "إلغاء",
                    style:
                        TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),
                ),

                // --------------------------------------------------------
                // 📺 مشاهدة إعلان
                // --------------------------------------------------------

                ElevatedButton.icon(
                  icon: const Icon(
                    Icons
                        .ondemand_video,
                  ),
                  label: const Text(
                    "شاهد إعلان",
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
  // 📺 مشاهدة إعلان للجزيرة
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

    await AdsManager().showRewardedAd(
      onRewardEarned: () async {
        // ----------------------------------------------------------
        // مهم:
        //
        // AdsManager الجديد يضيف +1 إلى adsBalance
        // بعد نجاح الإعلان.
        //
        // لذلك لا نضيف الرصيد هنا مرة ثانية.
        // ----------------------------------------------------------

        final balance =
            await PuzzleProgressManager
                .getAdsBalance();

        final required =
            PuzzleProgressManager
                .getIslandRequiredAds(
          island.id,
        );

        // ----------------------------------------------------------
        // هل أصبح الرصيد كافياً؟
        // ----------------------------------------------------------

        if (balance >= required) {
          final unlocked =
              await PuzzleProgressManager
                  .unlockIslandWithAds(
            island.id,
          );

          if (unlocked) {
            islandUnlocked[
                    island.id] =
                true;

            if (mounted) {
              setState(() {
                unlockingIsland =
                    false;
                processingIslandId =
                    null;
              });
            }

            if (dialogContext.mounted) {
              Navigator.pop(
                dialogContext,
              );
            }

            if (!mounted) return;

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(
              SnackBar(
                content: Text(
                  "🎉 تم فتح جزيرة ${getIslandName(island.id)}!",
                ),
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

        // ----------------------------------------------------------
        // لم يصل للحد المطلوب بعد
        // ----------------------------------------------------------

        if (mounted) {
          setState(() {
            unlockingIsland =
                false;
            processingIslandId =
                null;
          });
        }

        if (dialogContext.mounted) {
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

        if (dialogContext.mounted) {
          setDialogState(() {});
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          const SnackBar(
            content: Text(
              "تعذر تشغيل الإعلان. حاول مرة أخرى.",
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // 🏝️ فتح الجزيرة بعد نجاح الشراء
  // ============================================================

  Future<void> openUnlockedIsland(
    PuzzleModel island,
  ) async {
    if (!mounted) return;

    setState(() {
      islandUnlocked[island.id] =
          true;
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
  // 🏝️ الجزيرة الخاصة
  // ============================================================

  Future<void> openPrivateIsland() async {
    await playClickSound();

    if (!mounted) return;

    // ------------------------------------------------------------
    // الجزيرة مفتوحة بالفعل
    // ------------------------------------------------------------

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

    // ------------------------------------------------------------
    // قراءة رصيد الجواهر
    // ------------------------------------------------------------

    final gems =
        await PuzzleProgressManager
            .getGems();

    if (!mounted) return;

    // ------------------------------------------------------------
    // نافذة الجزيرة الخاصة
    // ------------------------------------------------------------

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
          title: const Text(
            "🏝️ الجزيرة الخاصة",
            textAlign:
                TextAlign.center,
            style: TextStyle(
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
                "افتح جزيرتك الخاصة وأنشئ ألغازك من صورك الخاصة.",
                textAlign:
                    TextAlign.center,
                style: TextStyle(
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
                    fit:
                        BoxFit.contain,
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

              Text(
                "رصيدك الحالي: $gems 💎",
                style:
                    const TextStyle(
                  color:
                      Colors.white70,
                  fontSize: 16,
                ),
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
              child: const Text(
                "إلغاء",
                style:
                    TextStyle(
                  color:
                      Colors.white70,
                ),
              ),
            ),

            ElevatedButton.icon(
              icon: const Icon(
                Icons.diamond,
              ),
              label: const Text(
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
                          );
                        },
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // 💎 شراء الجزيرة الخاصة بالجواهر
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

    // ------------------------------------------------------------
    // النظام المركزي هو المسؤول عن الخصم والفتح
    // ------------------------------------------------------------

    final paid =
        await PuzzleProgressManager
            .buyPrivateIslandWithGems();

    if (!paid) {
      if (!mounted) return;

      setState(() {
        unlockingPrivateIsland =
            false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            "لا تملك $privateIslandGemCost 💎 لفتح الجزيرة الخاصة.",
          ),
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          "🏝️ تم فتح جزيرتك الخاصة!",
        ),
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
}