import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/language/app_language_manager.dart';

import '../data/island_background_data.dart';
import '../data/puzzle_level_data.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';
import '../widgets/wallet_icon_widget.dart';

import '../managers/puzzle_progress_manager.dart';
import '../managers/ads_manager.dart';

import 'puzzle_game_screen.dart';

class IslandScreen extends StatefulWidget {
  final PuzzleModel island;

  const IslandScreen({
    super.key,
    required this.island,
  });

  @override
  State<IslandScreen> createState() => _IslandScreenState();
}

class _IslandScreenState extends State<IslandScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // 🌐 نظام اللغة
  // ============================================================

  final AppLanguageManager languageManager =
      AppLanguageManager.instance;

  String _text({
    required String ar,
    required String en,
  }) {
    return languageManager.text(
      ar: ar,
      en: en,
    );
  }

  // ============================================================
  // 🌍 أبعاد العالم
  // ============================================================

  static const double worldWidth = 1080;
  static const double worldHeight = 1920;

  static const double islandAreaTop = worldHeight * 0.00;
  static const double islandAreaHeight = worldHeight * 0.66;

  static const double islandBackgroundOpacity = 0.55;
  static const double islandImageOpacity = 0.65;

  // ============================================================
  // 📺 نظام إعلانات فتح المراحل
  // ============================================================

  // المرحلة 1 مفتوحة تلقائياً.
  //
  // المراحل 2 - 5  = 5 إعلانات
  // المراحل 6 - 10 = 10 إعلانات
  // المراحل 11 - 15 = 15 إعلان
  // المراحل 16 وما فوق = 20 إعلان

  static const int adsForLevels2To5 = 5;
  static const int adsForLevels6To10 = 10;
  static const int adsForLevels11To15 = 15;
  static const int adsForAdvancedLevels = 20;

  late final List<PuzzleLevelModel> levels;

  bool openingAd = false;

  late final AnimationController worldController;
  late final Animation<double> worldScale;
  late final Animation<double> worldTranslateY;

  // ============================================================
  // ✨ حركة وهج الأزرار
  // ============================================================

  late final AnimationController _uiGlowController;

  // ============================================================
  // 📍 مواقع المراحل
  // ============================================================

  final List<Offset> levelPositions = const [
    Offset(0.50, 0.91), // 1
    Offset(0.31, 0.83), // 2
    Offset(0.64, 0.73), // 3
    Offset(0.36, 0.64), // 4
    Offset(0.67, 0.55), // 5
    Offset(0.33, 0.46), // 6
    Offset(0.60, 0.37), // 7
    Offset(0.35, 0.28), // 8
    Offset(0.56, 0.22), // 9
    Offset(0.50, 0.10), // 10
  ];

  // ============================================================
  // 🚀 INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    languageManager.localeNotifier.addListener(
      _onLanguageChanged,
    );

    levels = PuzzleLevelData.getLevels(
      widget.island.id,
    );

    // ------------------------------------------------------------
    // 🌍 حركة العالم
    // ------------------------------------------------------------

    worldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    worldScale = Tween<double>(
      begin: 1.00,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: worldController,
        curve: Curves.easeInOut,
      ),
    );

    worldTranslateY = Tween<double>(
      begin: -15,
      end: 15,
    ).animate(
      CurvedAnimation(
        parent: worldController,
        curve: Curves.easeInOut,
      ),
    );

    // ------------------------------------------------------------
    // ✨ حركة الأيقونات
    // ------------------------------------------------------------

    _uiGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  // ============================================================
  // 🌐 عند تغيير اللغة
  // ============================================================

  void _onLanguageChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
  }

  // ============================================================
  // 🧹 DISPOSE
  // ============================================================

  @override
  void dispose() {
    languageManager.localeNotifier.removeListener(
      _onLanguageChanged,
    );

    worldController.dispose();
    _uiGlowController.dispose();

    super.dispose();
  }

  // ============================================================
  // 📺 عدد الإعلانات المطلوبة لفتح المرحلة
  // ============================================================

  int getRequiredAds(int levelNumber) {
    if (levelNumber <= 1) {
      return 0;
    }

    if (levelNumber <= 5) {
      return adsForLevels2To5;
    }

    if (levelNumber <= 10) {
      return adsForLevels6To10;
    }

    if (levelNumber <= 15) {
      return adsForLevels11To15;
    }

    return adsForAdvancedLevels;
  }

  // ============================================================
  // 🔑 مفتاح المرحلة
  // ============================================================

  String getLevelKey(int levelNumber) {
    return "${widget.island.id}_level_$levelNumber";
  }

  // ============================================================
  // 🎮 فتح المرحلة
  // ============================================================

  Future<void> openLevel(
    PuzzleLevelModel level,
  ) async {
    final levelKey = getLevelKey(
      level.levelNumber,
    );

    // ==========================================================
    // 🔓 فحص الفتح
    // ==========================================================

    final unlocked =
        await PuzzleProgressManager.isLevelUnlocked(
      levelKey,
    );

    if (unlocked) {
      await openPuzzle(level);
      return;
    }

    // ==========================================================
    // 🏆 فحص المرحلة السابقة
    // ==========================================================

    if (level.levelNumber > 1) {
      final previousLevelKey =
          getLevelKey(
        level.levelNumber - 1,
      );

      final previousCompleted =
          await PuzzleProgressManager.isCompleted(
        previousLevelKey,
      );

      if (previousCompleted) {
        await PuzzleProgressManager.unlockLevel(
          levelKey,
        );

        if (!mounted) {
          return;
        }

        setState(() {});

        await openPuzzle(level);
        return;
      }
    }

    // ==========================================================
    // 📺 المرحلة لا تزال مغلقة
    // ==========================================================

    await showUnlockDialog(level);
  }

  // ============================================================
  // 🎮 الانتقال إلى لعبة البازل
  // ============================================================

  Future<void> openPuzzle(
    PuzzleLevelModel level,
  ) async {
    if (!mounted) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PuzzleGameScreen(
          level: level,
          island: widget.island,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  // ============================================================
  // 🔒 نافذة فتح المرحلة
  // ============================================================

  Future<void> showUnlockDialog(
    PuzzleLevelModel level,
  ) async {
    final requiredAds =
        getRequiredAds(
      level.levelNumber,
    );

    final balance =
        await PuzzleProgressManager.getAdsBalance();

    if (!mounted) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF2A1B3D),

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),

          // =====================================================
          // العنوان
          // =====================================================

          title: Row(
            children: [
              Image.asset(
                "assets/images/ui/lock_close.png",
                width: 42,
                height: 42,
                fit: BoxFit.contain,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Icon(
                    Icons.lock,
                    color: Colors.amber,
                    size: 38,
                  );
                },
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  _text(
                    ar: "المرحلة مغلقة",
                    en: "Level Locked",
                  ),
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),

          // =====================================================
          // المحتوى
          // =====================================================

          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Text(
                _text(
                  ar: "المرحلة ${level.levelNumber}",
                  en: "Level ${level.levelNumber}",
                ),
                textAlign:
                    TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                _text(
                  ar: "شاهد إعلانات للحصول على رصيد مشاهدة وفتح هذه المرحلة.",
                  en: "Watch ads to earn viewing credits and unlock this level.",
                ),
                textAlign:
                    TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 20),

              // =================================================
              // 📺 المطلوب
              // =================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.ondemand_video,
                    color: Colors.amber,
                    size: 34,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    "$requiredAds",
                    style:
                        const TextStyle(
                      color: Colors.amber,
                      fontSize: 30,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(width: 6),

                  Text(
                    _text(
                      ar: "مشاهدة",
                      en: "views",
                    ),
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // =================================================
              // 📊 الرصيد
              // =================================================

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      Colors.black.withOpacity(
                    0.20,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                  border:
                      Border.all(
                    color: Colors.amber
                        .withOpacity(0.35),
                  ),
                ),

                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.video_library,
                      color: Colors.amber,
                      size: 25,
                    ),

                    const SizedBox(width: 8),

                    Text(
                      "$balance / $requiredAds",
                      style:
                          const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Text(
                balance >= requiredAds
                    ? _text(
                        ar: "يمكنك فتح المرحلة الآن.",
                        en: "You can unlock this level now.",
                      )
                    : _text(
                        ar: "المتبقي: ${requiredAds - balance} مشاهدة",
                        en: "Remaining: ${requiredAds - balance} views",
                      ),
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color:
                      balance >= requiredAds
                          ? Colors.greenAccent
                          : Colors.white70,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          // =====================================================
          // الأزرار
          // =====================================================

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: Text(
                _text(
                  ar: "إلغاء",
                  en: "Cancel",
                ),
                style:
                    const TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),

            // ===================================================
            // 📺 مشاهدة إعلان
            // ===================================================

            ElevatedButton.icon(
              icon: const Icon(
                Icons.ondemand_video,
              ),

              label: Text(
                balance >= requiredAds
                    ? _text(
                        ar: "فتح المرحلة",
                        en: "Unlock Level",
                      )
                    : _text(
                        ar: "مشاهدة إعلان",
                        en: "Watch Ad",
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

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),

              onPressed: openingAd
                  ? null
                  : () async {
                      await handleUnlockAd(
                        level,
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
  // 📺 مشاهدة الإعلان / فتح المرحلة
  // ============================================================

  Future<void> handleUnlockAd(
    PuzzleLevelModel level,
    BuildContext dialogContext,
  ) async {
    if (openingAd) {
      return;
    }

    final requiredAds =
        getRequiredAds(
      level.levelNumber,
    );

    final currentBalance =
        await PuzzleProgressManager
            .getAdsBalance();

    // ==========================================================
    // 🔓 إذا كان الرصيد كافياً
    // ==========================================================

    if (currentBalance >= requiredAds) {
      await PuzzleProgressManager
          .unlockLevel(
        getLevelKey(
          level.levelNumber,
        ),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(
        dialogContext,
      );

      setState(() {});

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            _text(
              ar: "🎉 تم فتح المرحلة!",
              en: "🎉 Level unlocked!",
            ),
          ),
        ),
      );

      await Future.delayed(
        const Duration(
          milliseconds: 400,
        ),
      );

      if (!mounted) {
        return;
      }

      await openPuzzle(level);

      return;
    }

    // ==========================================================
    // 📺 بدء الإعلان
    // ==========================================================

    setState(() {
      openingAd = true;
    });

    if (dialogContext.mounted) {
      Navigator.pop(
        dialogContext,
      );
    }

    AdsManager().showRewardedAd(
      onRewardEarned: () async {
        // ======================================================
        // ➕ إضافة مشاهدة واحدة إلى الرصيد
        // ======================================================

        await PuzzleProgressManager
            .addAdsBalance(1);

        final balance =
            await PuzzleProgressManager
                .getAdsBalance();

        final required =
            getRequiredAds(
          level.levelNumber,
        );

        // ======================================================
        // 🔓 تحقق من فتح المرحلة
        // ======================================================

        if (balance >= required) {
          await PuzzleProgressManager
              .unlockLevel(
            getLevelKey(
              level.levelNumber,
            ),
          );

          if (mounted) {
            setState(() {
              openingAd = false;
            });

            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content: Text(
                  _text(
                    ar: "🎉 تم فتح المرحلة!",
                    en: "🎉 Level unlocked!",
                  ),
                ),
              ),
            );

            await Future.delayed(
              const Duration(
                milliseconds: 500,
              ),
            );

            if (!mounted) {
              return;
            }

            await openPuzzle(level);
          }

          return;
        }

        // ======================================================
        // 📊 لم يكتمل العدد بعد
        // ======================================================

        if (mounted) {
          setState(() {
            openingAd = false;
          });

          final remaining =
              required - balance;

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                _text(
                  ar:
                      "📺 تمت إضافة مشاهدة!\n"
                      "الرصيد: $balance / $required\n"
                      "المتبقي: $remaining مشاهدة",
                  en:
                      "📺 View added!\n"
                      "Balance: $balance / $required\n"
                      "Remaining: $remaining views",
                ),
              ),
            ),
          );
        }
      },

      onAdFailed: () {
        if (!mounted) {
          return;
        }

        setState(() {
          openingAd = false;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              _text(
                ar: "⚠️ تعذر عرض الإعلان. حاول مرة أخرى.",
                en: "⚠️ Unable to show the ad. Please try again.",
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // 🔢 زر المرحلة
  // ============================================================

  Widget levelButton(
    PuzzleLevelModel level, {
    required double size,
  }) {
    final levelKey =
        getLevelKey(
      level.levelNumber,
    );

    return GestureDetector(
      behavior:
          HitTestBehavior.opaque,

      onTap: () async {
        await openLevel(level);
      },

      child: SizedBox(
        width: size,
        height: size,

        child: DecoratedBox(
          decoration:
              BoxDecoration(
            shape:
                BoxShape.circle,

            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(
                  0.35,
                ),

                blurRadius:
                    size * 0.10,

                offset: Offset(
                  0,
                  size * 0.05,
                ),
              ),
            ],
          ),

          child: Stack(
            alignment:
                Alignment.center,

            children: [
              // =================================================
              // 🔒 قفل المرحلة
              // =================================================

              FutureBuilder<bool>(
                future:
                    PuzzleProgressManager
                        .isLevelUnlocked(
                  levelKey,
                ),

                builder: (
                  context,
                  snapshot,
                ) {
                  final unlocked =
                      snapshot.data ??
                          false;

                  return Image.asset(
                    unlocked
                        ? "assets/images/ui/lock_open.png"
                        : "assets/images/ui/lock_close.png",

                    fit:
                        BoxFit.contain,

                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Icon(
                        unlocked
                            ? Icons.lock_open
                            : Icons.lock,

                        color: unlocked
                            ? Colors
                                .greenAccent
                            : Colors.amber,

                        size:
                            size * 0.55,
                      );
                    },
                  );
                },
              ),

              // =================================================
              // 🔢 رقم المرحلة
              // =================================================

              Positioned.fill(
                child: Center(
                  child: Text(
                    "${level.levelNumber}",

                    style:
                        TextStyle(
                      color:
                          Colors.white,

                      fontSize:
                          size * 0.28,

                      fontWeight:
                          FontWeight.w900,

                      shadows:
                          const [
                        Shadow(
                          color:
                              Colors.black,
                          blurRadius:
                              5,
                          offset:
                              Offset(
                            1,
                            2,
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
    );
  }

  // ============================================================
  // ✨ مقياس حركة الأيقونات
  // ============================================================

  double get _uiPulseScale {
    return 1.10 +
        (_uiGlowController.value * 0.08);
  }

  // ============================================================
  // ✨ وهج المحفظة وزر الرجوع
  // ============================================================

  BoxDecoration _uiGlowDecoration() {
    final glowStrength =
        0.55 +
        (_uiGlowController.value * 0.30);

    return BoxDecoration(
      shape: BoxShape.circle,

      boxShadow: [
        BoxShadow(
          color: Colors.amber
              .withOpacity(
            glowStrength,
          ),

          blurRadius: 16,
          spreadRadius: 4,
        ),
      ],
    );
  }

  // ============================================================
  // 🗺️ BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xff020b24),

      body: SafeArea(
        child: LayoutBuilder(
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

            // ==================================================
            // 📐 حساب مقياس الخريطة
            // ==================================================

            final double scale = math.max(
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

            final double levelButtonSize =
                (80 / scale).clamp(
              150.0,
              260.0,
            );

            return Stack(
              children: [
                // =================================================
                // 🌍 الخريطة
                // =================================================

                ClipRect(
                  child: Stack(
                    children: [
                      Positioned(
                        left: dx,
                        top: dy,

                        child:
                            Transform.scale(
                          scale: scale,

                          alignment:
                              Alignment.topLeft,

                          child: SizedBox(
                            width:
                                worldWidth,

                            height:
                                worldHeight,

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
                                  offset:
                                      Offset(
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

                                    child:
                                        child,
                                  ),
                                );
                              },

                              child:
                                  SizedBox(
                                width:
                                    worldWidth,

                                height:
                                    worldHeight,

                                child: Stack(
                                  clipBehavior:
                                      Clip.none,

                                  children: [
                                    // =================================
                                    // 🌄 خلفية الجزيرة
                                    // =================================

                                    Positioned.fill(
                                      child:
                                          Opacity(
                                        opacity:
                                            islandBackgroundOpacity,

                                        child:
                                            Image.asset(
                                          IslandBackgroundData
                                              .getBackground(
                                            widget
                                                .island
                                                .id,
                                          ),

                                          fit:
                                              BoxFit.cover,

                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return const SizedBox
                                                .expand();
                                          },
                                        ),
                                      ),
                                    ),

                                    // =================================
                                    // 🏝️ صورة الجزيرة
                                    // =================================

                                    Positioned(
                                      left: 0,
                                      top:
                                          islandAreaTop,

                                      width:
                                          worldWidth,

                                      height:
                                          islandAreaHeight,

                                      child:
                                          Opacity(
                                        opacity:
                                            islandImageOpacity,

                                        child:
                                            Image.asset(
                                          widget
                                              .island
                                              .image,

                                          fit:
                                              BoxFit.contain,

                                          alignment:
                                              Alignment
                                                  .center,

                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return const SizedBox
                                                .expand();
                                          },
                                        ),
                                      ),
                                    ),

                                    // =================================
                                    // 🔢 المراحل
                                    // =================================

                                    ...List.generate(
                                      levels.length,
                                      (index) {
                                        if (index >=
                                            levelPositions
                                                .length) {
                                          return const SizedBox
                                              .shrink();
                                        }

                                        final pos =
                                            levelPositions[
                                                index];

                                        return Positioned(
                                          left:
                                              (worldWidth *
                                                      pos.dx) -
                                                  (levelButtonSize /
                                                      2),

                                          top:
                                              (worldHeight *
                                                      pos.dy) -
                                                  (levelButtonSize /
                                                      2),

                                          child:
                                              levelButton(
                                            levels[index],
                                            size:
                                                levelButtonSize,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // =================================================
                // 🔙 زر الرجوع
                // =================================================

                Positioned(
                  top: 20,
                  left: 20,

                  child:
                      AnimatedBuilder(
                    animation:
                        _uiGlowController,

                    builder: (
                      context,
                      child,
                    ) {
                      return Container(
                        decoration:
                            _uiGlowDecoration(),

                        child:
                            Transform.scale(
                          scale:
                              _uiPulseScale,

                          child: child,
                        ),
                      );
                    },

                    child:
                        GestureDetector(
                      onTap: () {
                        Navigator.pop(
                          context,
                        );
                      },

                      child: SizedBox(
                        width: 56,
                        height: 56,

                        child:
                            Image.asset(
                          "assets/images/ui/back_screen.png",

                          fit:
                              BoxFit.contain,

                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons.arrow_back,
                              color:
                                  Colors.white,
                              size: 42,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // =================================================
                // 👛 المحفظة
                // =================================================

                Positioned(
                  bottom: 20,
                  left: 20,

                  child:
                      AnimatedBuilder(
                    animation:
                        _uiGlowController,

                    builder: (
                      context,
                      child,
                    ) {
                      return Container(
                        decoration:
                            _uiGlowDecoration(),

                        child:
                            Transform.scale(
                          scale:
                              _uiPulseScale,

                          child: child,
                        ),
                      );
                    },

                    child:
                        const WalletIconWidget(),
                  ),
                ),

                // =================================================
                // 📺 مؤشر تحميل الإعلان
                // =================================================

                if (openingAd)
                  Positioned.fill(
                    child:
                        IgnorePointer(
                      child:
                          Container(
                        color: Colors.black
                            .withOpacity(
                          0.30,
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
            );
          },
        ),
      ),
    );
  }
}