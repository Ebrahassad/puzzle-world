import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/language/app_language_manager.dart';

import '../data/island_background_data.dart';
import '../data/puzzle_level_data.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';
import '../widgets/wallet_icon_widget.dart';

import '../managers/puzzle_progress_manager.dart';

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
  // 🪙 صورة العملة
  // ============================================================

  static const String coinAsset =
      "assets/images/rewards/puzzle_coin.png";

  // ============================================================
  // 📦 البيانات
  // ============================================================

  late final List<PuzzleLevelModel> levels;

  bool purchasingLevel = false;

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

    _uiGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  // ============================================================
  // 🌐 تغيير اللغة
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
  // 🪙 سعر المرحلة
  // ============================================================
  //
  // الأسعار مصدرها PuzzleProgressManager
  // حتى لا يكون لدينا نظامان مختلفان للأسعار.
  //
  // 1  = مجاني
  // 2  = 75
  // 3  = 150
  // 4  = 250
  // 5  = 350
  // 6  = 450
  // 7  = 600
  // 8  = 750
  // 9  = 875
  // 10 = 1000
  // ============================================================

  int getLevelCoinCost(int levelNumber) {
    return PuzzleProgressManager.getLevelCoinCost(
      levelNumber,
    );
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
  //
  // النظام:
  //
  // 1️⃣ إذا كانت المرحلة مفتوحة بالفعل → دخول مباشر.
  //
  // 2️⃣ إذا لم تكن مفتوحة:
  //    نتحقق هل المرحلة السابقة مكتملة.
  //
  //    نعم → فتح مجاني + دخول.
  //
  //    لا → عرض نافذة الشراء.
  //
  // 🪙 الشراء لا يعتمد على ترتيب المراحل.
  // يستطيع اللاعب شراء المرحلة 10 مثلاً مباشرة.
  // ============================================================

  Future<void> openLevel(
    PuzzleLevelModel level,
  ) async {
    final levelNumber = level.levelNumber;

    final levelKey = getLevelKey(
      levelNumber,
    );

    // ==========================================================
    // 🔓 مفتوحة بالفعل
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
    // 🆓 محاولة الفتح المجاني بإكمال المرحلة السابقة
    // ==========================================================

    if (levelNumber > 1) {
      final previousLevelKey = getLevelKey(
        levelNumber - 1,
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
    // 🪙 المرحلة مغلقة ويمكن شراؤها مباشرة
    // ==========================================================

    await showPurchaseDialog(level);
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
  // 🪙 نافذة شراء المرحلة
  // ============================================================

  Future<void> showPurchaseDialog(
    PuzzleLevelModel level,
  ) async {
    final levelNumber = level.levelNumber;

    final cost = getLevelCoinCost(
      levelNumber,
    );

    final balance =
        await PuzzleProgressManager.getCoins();

    if (!mounted) {
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A1B3D),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),

          // =====================================================
          // 🔒 العنوان
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
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),

          // =====================================================
          // 📋 المحتوى
          // =====================================================

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // -------------------------------------------------
              // رقم المرحلة
              // -------------------------------------------------

              Text(
                _text(
                  ar: "المرحلة $levelNumber",
                  en: "Level $levelNumber",
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 14),

              // -------------------------------------------------
              // رسالة الشراء
              // -------------------------------------------------

              Text(
                _text(
                  ar:
                      "يمكنك فتح هذه المرحلة مجاناً عند إكمال المرحلة السابقة، أو شراؤها الآن بالعملات.",
                  en:
                      "You can unlock this level for free by completing the previous level, or purchase it now with coins.",
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 22),

              // =================================================
              // 🪙 سعر المرحلة
              // =================================================

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.40),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      coinAsset,
                      width: 42,
                      height: 42,
                      fit: BoxFit.contain,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 42,
                        );
                      },
                    ),

                    const SizedBox(width: 10),

                    Text(
                      "$cost",
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 31,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 17),

              // =================================================
              // 💰 رصيد اللاعب
              // =================================================

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    coinAsset,
                    width: 27,
                    height: 27,
                    fit: BoxFit.contain,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return const Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 27,
                      );
                    },
                  ),

                  const SizedBox(width: 7),

                  Text(
                    _text(
                      ar: "رصيدك: $balance",
                      en: "Your balance: $balance",
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // =================================================
              // ⚠️ حالة الرصيد
              // =================================================

              Text(
                balance >= cost
                    ? _text(
                        ar: "لديك عملات كافية للشراء.",
                        en:
                            "You have enough coins to purchase this level.",
                      )
                    : _text(
                        ar:
                            "تحتاج إلى ${cost - balance} عملة إضافية.",
                        en:
                            "You need ${cost - balance} more coins.",
                      ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: balance >= cost
                      ? Colors.greenAccent
                      : Colors.redAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // =====================================================
          // 🔘 الأزرار
          // =====================================================

          actions: [
            // ---------------------------------------------------
            // إلغاء
            // ---------------------------------------------------

            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                _text(
                  ar: "إلغاء",
                  en: "Cancel",
                ),
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),
            ),

            // ---------------------------------------------------
            // 🪙 شراء
            // ---------------------------------------------------

            ElevatedButton.icon(
              icon: Image.asset(
                coinAsset,
                width: 25,
                height: 25,
                fit: BoxFit.contain,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Icon(
                    Icons.monetization_on,
                  );
                },
              ),

              label: Text(
                _text(
                  ar: "شراء $cost",
                  en: "Buy $cost",
                ),
              ),

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: const Color(0xFF1A0B2E),
                disabledBackgroundColor:
                    Colors.grey.shade700,
                disabledForegroundColor:
                    Colors.white54,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onPressed:
                  purchasingLevel || balance < cost
                      ? null
                      : () async {
                          await handlePurchaseLevel(
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
  // 🪙 تنفيذ شراء المرحلة
  // ============================================================

  Future<void> handlePurchaseLevel(
    PuzzleLevelModel level,
    BuildContext dialogContext,
  ) async {
    if (purchasingLevel) {
      return;
    }

    final levelNumber = level.levelNumber;

    final levelKey = getLevelKey(
      levelNumber,
    );

    // ==========================================================
    // 🔓 المرحلة الأولى مجانية
    // ==========================================================

    if (levelNumber <= 1) {
      await PuzzleProgressManager.unlockLevel(
        levelKey,
      );

      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }

      await openPuzzle(level);
      return;
    }

    final cost = getLevelCoinCost(
      levelNumber,
    );

    final balance =
        await PuzzleProgressManager.getCoins();

    // ==========================================================
    // 💰 التحقق من الرصيد
    // ==========================================================

    if (balance < cost) {
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF3A183F),
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              Image.asset(
                coinAsset,
                width: 30,
                height: 30,
                fit: BoxFit.contain,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                  );
                },
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  _text(
                    ar:
                        "لا تملك عملات كافية.\n"
                        "السعر: $cost | رصيدك: $balance",
                    en:
                        "Not enough coins.\n"
                        "Price: $cost | Balance: $balance",
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // 🔄 بدء الشراء
    // ==========================================================

    setState(() {
      purchasingLevel = true;
    });

    // ==========================================================
    // 🪙 الشراء من خلال مدير التقدم
    // ==========================================================

    final purchased =
        await PuzzleProgressManager.buyLevelWithCoins(
      levelKey,
      levelNumber,
    );

    if (!purchased) {
      if (mounted) {
        setState(() {
          purchasingLevel = false;
        });
      }

      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF3A183F),
          content: Text(
            _text(
              ar: "تعذر شراء المرحلة. تأكد من رصيدك وحاول مرة أخرى.",
              en:
                  "Unable to purchase the level. Check your balance and try again.",
            ),
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // 🔄 تحديث الحالة
    // ==========================================================

    if (mounted) {
      setState(() {
        purchasingLevel = false;
      });
    }

    // ==========================================================
    // إغلاق النافذة
    // ==========================================================

    if (dialogContext.mounted) {
      Navigator.pop(dialogContext);
    }

    if (!mounted) {
      return;
    }

    // ==========================================================
    // 🎉 رسالة نجاح الشراء
    // ==========================================================

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF21452A),
        duration: const Duration(seconds: 2),

        content: Row(
          children: [
            Image.asset(
              coinAsset,
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.check_circle,
                  color: Colors.greenAccent,
                  size: 30,
                );
              },
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                _text(
                  ar:
                      "تم شراء المرحلة $levelNumber بنجاح!\n"
                      "تم خصم $cost عملة.",
                  en:
                      "Level $levelNumber purchased successfully!\n"
                      "$cost coins deducted.",
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // ==========================================================
    // 🔄 إعادة بناء الخريطة لتغيير القفل
    // ==========================================================

    setState(() {});

    // ==========================================================
    // 🎮 الدخول إلى المرحلة مباشرة
    // ==========================================================

    await Future.delayed(
      const Duration(milliseconds: 500),
    );

    if (!mounted) {
      return;
    }

    await openPuzzle(level);
  }

  // ============================================================
  // 🔢 زر المرحلة
  // ============================================================

  Widget levelButton(
    PuzzleLevelModel level, {
    required double size,
  }) {
    final levelKey = getLevelKey(
      level.levelNumber,
    );

    return SizedBox(
      width: size,
      height: size,

      child: GestureDetector(
        behavior: HitTestBehavior.translucent,

        onTap: () {
          openLevel(level);
        },

        child: Container(
          width: size,
          height: size,

          decoration: BoxDecoration(
            shape: BoxShape.circle,

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: size * 0.10,
                offset: Offset(
                  0,
                  size * 0.05,
                ),
              ),
            ],
          ),

          child: Stack(
            alignment: Alignment.center,

            children: [
              // =================================================
              // 🔒 / 🔓 القفل
              // =================================================

              FutureBuilder<bool>(
                future:
                    PuzzleProgressManager.isLevelUnlocked(
                  levelKey,
                ),

                builder: (
                  context,
                  snapshot,
                ) {
                  final unlocked =
                      snapshot.data ?? false;

                  return IgnorePointer(
                    child: Image.asset(
                      unlocked
                          ? "assets/images/ui/lock_open.png"
                          : "assets/images/ui/lock_close.png",

                      width: size,
                      height: size,

                      fit: BoxFit.contain,

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
                              ? Colors.greenAccent
                              : Colors.amber,

                          size: size * 0.55,
                        );
                      },
                    ),
                  );
                },
              ),

              // =================================================
              // 🔢 رقم المرحلة
              // =================================================

              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Text(
                      "${level.levelNumber}",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size * 0.28,
                        fontWeight: FontWeight.w900,

                        shadows: const [
                          Shadow(
                            color: Colors.black,
                            blurRadius: 5,
                            offset: Offset(
                              1,
                              2,
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
          color: Colors.amber.withOpacity(
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
      backgroundColor: const Color(0xff020b24),

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
            // 📐 مقياس الخريطة
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
                (screenWidth - scaledWidth) / 2;

            final double dy =
                (screenHeight - scaledHeight) / 2;

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
                                    // 🌄 خلفية الجزيرة
                                    // =================================

                                    Positioned.fill(
                                      child: Opacity(
                                        opacity:
                                            islandBackgroundOpacity,

                                        child: Image.asset(
                                          IslandBackgroundData
                                              .getBackground(
                                            widget.island.id,
                                          ),

                                          fit: BoxFit.cover,

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
                                      top: islandAreaTop,
                                      width: worldWidth,
                                      height: islandAreaHeight,

                                      child: Opacity(
                                        opacity:
                                            islandImageOpacity,

                                        child: Image.asset(
                                          widget.island.image,

                                          fit: BoxFit.contain,

                                          alignment:
                                              Alignment.center,

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
                                            levelPositions.length) {
                                          return const SizedBox
                                              .shrink();
                                        }

                                        final pos =
                                            levelPositions[index];

                                        return Positioned(
                                          left:
                                              (worldWidth * pos.dx) -
                                                  (levelButtonSize /
                                                      2),

                                          top:
                                              (worldHeight * pos.dy) -
                                                  (levelButtonSize /
                                                      2),

                                          child: levelButton(
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

                  child: AnimatedBuilder(
                    animation: _uiGlowController,

                    builder: (
                      context,
                      child,
                    ) {
                      return Container(
                        decoration:
                            _uiGlowDecoration(),

                        child: Transform.scale(
                          scale: _uiPulseScale,
                          child: child,
                        ),
                      );
                    },

                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },

                      child: SizedBox(
                        width: 56,
                        height: 56,

                        child: Image.asset(
                          "assets/images/ui/back_screen.png",

                          fit: BoxFit.contain,

                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
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

                  child: AnimatedBuilder(
                    animation: _uiGlowController,

                    builder: (
                      context,
                      child,
                    ) {
                      return Container(
                        decoration:
                            _uiGlowDecoration(),

                        child: Transform.scale(
                          scale: _uiPulseScale,
                          child: child,
                        ),
                      );
                    },

                    child:
                        const WalletIconWidget(),
                  ),
                ),

                // =================================================
                // ⏳ مؤشر الشراء
                // =================================================

                if (purchasingLevel)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: Colors.black.withOpacity(
                          0.30,
                        ),

                        child: const Center(
                          child:
                              CircularProgressIndicator(
                            color: Colors.amber,
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
