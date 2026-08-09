import 'dart:async';
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

  static const double islandAreaTop = 0.0;
  static const double islandAreaHeight = worldHeight * 0.66;

  static const double islandBackgroundOpacity = 0.55;
  static const double islandImageOpacity = 0.65;

  // ============================================================
  // 🪙 صورة العملة
  // ============================================================

  static const String coinAsset =
      "assets/images/rewards/puzzle_coin.png";

  // ============================================================
  // 📦 بيانات المراحل
  // ============================================================

  late final List<PuzzleLevelModel> levels;

  // ============================================================
  // 🔐 حالة فتح المراحل
  // ============================================================

  /// المفتاح:
  /// islandId_level_number
  ///
  /// القيمة:
  /// true  = مفتوحة
  /// false = مقفلة
  final Map<String, bool> _unlockedLevels = {};

  // ============================================================
  // 🪙 حالة الشراء
  // ============================================================

  bool purchasingLevel = false;

  // ============================================================
  // 🎉 رسالة نجاح الفتح
  // ============================================================

  String? _successMessage;

  Timer? _successMessageTimer;

  // ============================================================
  // 🌍 حركة العالم
  // ============================================================

  late final AnimationController worldController;

  late final Animation<double> worldScale;

  late final Animation<double> worldTranslateY;

  // ============================================================
  // ✨ حركة واجهة المستخدم
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

    // ----------------------------------------------------------
    // 🌐 اللغة
    // ----------------------------------------------------------

    languageManager.localeNotifier.addListener(
      _onLanguageChanged,
    );

    // ----------------------------------------------------------
    // 📦 تحميل المراحل
    // ----------------------------------------------------------

    levels = PuzzleLevelData.getLevels(
      widget.island.id,
    );

    // ----------------------------------------------------------
    // 🔐 تحميل حالات الأقفال
    // ----------------------------------------------------------

    _loadUnlockedLevels();

    // ----------------------------------------------------------
    // 🌍 حركة الخريطة
    // ----------------------------------------------------------

    worldController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 12,
      ),
    )..repeat(
        reverse: true,
      );

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

    // ----------------------------------------------------------
    // ✨ وهج أزرار الواجهة
    // ----------------------------------------------------------

    _uiGlowController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1800,
      ),
    )..repeat(
        reverse: true,
      );
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
  // 🔑 مفتاح المرحلة
  // ============================================================

  String getLevelKey(int levelNumber) {
    return "${widget.island.id}_level_$levelNumber";
  }

  // ============================================================
  // 🔄 تحميل حالات فتح المراحل
  // ============================================================

  Future<void> _loadUnlockedLevels() async {
    final Map<String, bool> states = {};

    for (final level in levels) {
      final String levelKey =
          getLevelKey(level.levelNumber);

      // المرحلة الأولى مفتوحة دائمًا.
      if (level.levelNumber == 1) {
        states[levelKey] = true;
        continue;
      }

      final bool unlocked =
          await PuzzleProgressManager.isLevelUnlocked(
        levelKey,
      );

      states[levelKey] = unlocked;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _unlockedLevels
        ..clear()
        ..addAll(states);
    });
  }

  // ============================================================
  // 🔄 تحديث حالات الأقفال
  // ============================================================

  Future<void> _refreshLevels() async {
    await _loadUnlockedLevels();
  }

  // ============================================================
  // 🪙 سعر المرحلة
  // ============================================================

  int getLevelCoinCost(int levelNumber) {
    return PuzzleProgressManager.getLevelCoinCost(
      levelNumber,
    );
  }

  // ============================================================
  // 🎉 رسالة تم فتح المرحلة
  // ============================================================

  void _showLevelUnlockedMessage(
    int levelNumber,
  ) {
    _successMessageTimer?.cancel();

    if (!mounted) {
      return;
    }

    setState(() {
      _successMessage = _text(
        ar: "تم فتح المرحلة $levelNumber بنجاح!",
        en: "Level $levelNumber unlocked successfully!",
      );
    });

    _successMessageTimer = Timer(
      const Duration(
        seconds: 2,
      ),
      () {
        if (!mounted) {
          return;
        }

        setState(() {
          _successMessage = null;
        });
      },
    );
  }

  // ============================================================
  // 🎮 فتح المرحلة
  // ============================================================

  Future<void> openLevel(
    PuzzleLevelModel level,
  ) async {
    final int levelNumber =
        level.levelNumber;

    final String levelKey =
        getLevelKey(levelNumber);

    // ==========================================================
    // 🆓 المرحلة الأولى مفتوحة دائمًا
    // ==========================================================

    if (levelNumber == 1) {
      await PuzzleProgressManager.unlockLevel(
        levelKey,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _unlockedLevels[levelKey] = true;
      });

      await openPuzzle(level);
      return;
    }

    // ==========================================================
    // 🔓 التحقق من الحالة المحلية
    // ==========================================================

    bool unlocked =
        _unlockedLevels[levelKey] ?? false;

    // ==========================================================
    // 🔄 إذا لم تكن الحالة محملة نقرأها من التخزين
    // ==========================================================

    if (!_unlockedLevels.containsKey(levelKey)) {
      unlocked =
          await PuzzleProgressManager.isLevelUnlocked(
        levelKey,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _unlockedLevels[levelKey] = unlocked;
      });
    }

    // ==========================================================
    // 🔓 المرحلة مفتوحة
    // ==========================================================

    if (unlocked) {
      await openPuzzle(level);
      return;
    }

    // ==========================================================
    // 🆓 التحقق من إكمال المرحلة السابقة
    // ==========================================================

    final String previousLevelKey =
        getLevelKey(
      levelNumber - 1,
    );

    final bool previousCompleted =
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

      setState(() {
        _unlockedLevels[levelKey] = true;
      });

      await openPuzzle(level);
      return;
    }

    // ==========================================================
    // 🔒 المرحلة مغلقة
    // إظهار نافذة الشراء
    // ==========================================================

    await showPurchaseDialog(level);
  }

  // ============================================================
  // 💾 فحص وجود لعبة محفوظة لهذه المرحلة
  // ============================================================

  Future<bool> _checkSavedGame(
    PuzzleLevelModel level,
  ) async {
    try {
      final saved =
          await PuzzleProgressManager.loadProgress();

      if (saved == null) {
        return false;
      }

      // ----------------------------------------------------------
      // 🔐 الحفظ يجب أن يخص نفس الجزيرة ونفس المرحلة
      // ----------------------------------------------------------

      final String savedPuzzleId =
          saved["puzzleId"]?.toString() ?? "";

      final String savedLevelId =
          saved["levelId"]?.toString() ?? "";

      final String currentPuzzleId =
          widget.island.id.toString();

      final String currentLevelId =
          level.id.toString();

      return savedPuzzleId == currentPuzzleId &&
          savedLevelId == currentLevelId;
    } catch (e) {
      debugPrint(
        "❌ Error checking saved game: $e",
      );

      return false;
    }
  }

  // ============================================================
  // 💾 نافذة اللعبة المحفوظة
  // ============================================================

  Future<bool> _showContinueSavedGameDialog() async {
    if (!mounted) {
      return false;
    }

    final bool? result =
        await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF2A1B3D),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(24),
          ),

          title: const Row(
            children: [
              Icon(
                Icons.save_rounded,
                color: Colors.amber,
                size: 32,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "لعبة محفوظة",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          content: const Text(
            "توجد لعبة محفوظة لهذه المرحلة.\nهل تريد الاستمرار من حيث توقفت؟",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),

          actionsPadding:
              const EdgeInsets.fromLTRB(
            16,
            4,
            16,
            16,
          ),

          actions: [
            // ----------------------------------------------------
            // 🔄 ابدأ من جديد
            // ----------------------------------------------------

            TextButton(
              onPressed: () async {
                // مسح الحفظ لهذه اللعبة.
                await PuzzleProgressManager
                    .clearProgress();

                if (!dialogContext.mounted) {
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  false,
                );
              },

              child: const Text(
                "ابدأ من جديد",
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // ----------------------------------------------------
            // ▶️ متابعة
            // ----------------------------------------------------

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },

              icon: const Icon(
                Icons.play_arrow_rounded,
              ),

              label: const Text(
                "متابعة",
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.amber,
                foregroundColor:
                    const Color(0xFF1A0B2E),

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // ============================================================
  // 🎮 فتح شاشة البازل
  // ============================================================

  Future<void> openPuzzle(
    PuzzleLevelModel level,
  ) async {
    if (!mounted) {
      return;
    }

    // ==========================================================
    // 💾 فحص الحفظ قبل فتح PuzzleGameScreen
    //
    // مهم جدًا:
    // لا نغير أي شيء داخل منطق البازل.
    // فقط نقرر هل نعرض نافذة الحفظ أم لا.
    // ==========================================================

    final bool hasSavedGame =
        await _checkSavedGame(level);

    if (!mounted) {
      return;
    }

    // ==========================================================
    // 💾 توجد لعبة محفوظة
    // ==========================================================

    if (hasSavedGame) {
      await _showContinueSavedGameDialog();

      if (!mounted) {
        return;
      }
    }

    // ==========================================================
    // 🎮 فتح شاشة البازل
    // ==========================================================

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return PuzzleGameScreen(
            level: level,
            island: widget.island,
          );
        },
      ),
    );

    if (!mounted) {
      return;
    }

    // ==========================================================
    // 🔄 تحديث الأقفال بعد الرجوع
    // ==========================================================

    await _refreshLevels();
  }

  // ============================================================
  // 🪙 نافذة شراء المرحلة
  // ============================================================

  Future<void> showPurchaseDialog(
    PuzzleLevelModel level,
  ) async {
    final int levelNumber =
        level.levelNumber;

    final int cost =
        getLevelCoinCost(levelNumber);

    final int balance =
        await PuzzleProgressManager.getCoins();

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF2A1B3D),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(22),
          ),

          titlePadding:
              const EdgeInsets.fromLTRB(
            20,
            20,
            20,
            8,
          ),

          contentPadding:
              const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            8,
          ),

          actionsPadding:
              const EdgeInsets.fromLTRB(
            16,
            4,
            16,
            16,
          ),

          // ====================================================
          // 🔒 العنوان
          // ====================================================

          title: Row(
            children: [
              Image.asset(
                "assets/images/ui/lock_close.png",
                width: 44,
                height: 44,
                fit: BoxFit.contain,
                errorBuilder:
                    (_, __, ___) {
                  return const Icon(
                    Icons.lock,
                    color: Colors.amber,
                    size: 40,
                  );
                },
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: Text(
                  _text(
                    ar: "المرحلة مغلقة",
                    en: "Level Locked",
                  ),
                  style:
                      const TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // ====================================================
          // 📋 المحتوى
          // ====================================================

          content:
              SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                // ----------------------------------------------
                // رقم المرحلة
                // ----------------------------------------------

                Text(
                  _text(
                    ar:
                        "المرحلة $levelNumber",
                    en:
                        "Level $levelNumber",
                  ),
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                // ----------------------------------------------
                // سؤال الشراء
                // ----------------------------------------------

                Text(
                  _text(
                    ar:
                        "المرحلة مغلقة.\nهل تريد شراء المرحلة وفتحها الآن؟",
                    en:
                        "This level is locked.\nDo you want to purchase and unlock it now?",
                  ),
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                // =================================================
                // 🪙 سعر المرحلة
                // =================================================

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.black
                        .withOpacity(0.20),
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                    border:
                        Border.all(
                      color: Colors.amber
                          .withOpacity(0.45),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Image.asset(
                        coinAsset,
                        width: 44,
                        height: 44,
                        fit: BoxFit.contain,
                        errorBuilder:
                            (_, __, ___) {
                          return const Icon(
                            Icons
                                .monetization_on,
                            color:
                                Colors.amber,
                            size: 44,
                          );
                        },
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Text(
                        "$cost",
                        style:
                            const TextStyle(
                          color:
                              Colors.amber,
                          fontSize: 31,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 17,
                ),

                // =================================================
                // 💰 الرصيد
                // =================================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    Image.asset(
                      coinAsset,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (_, __, ___) {
                        return const Icon(
                          Icons
                              .monetization_on,
                          color:
                              Colors.amber,
                          size: 28,
                        );
                      },
                    ),

                    const SizedBox(
                      width: 7,
                    ),

                    Flexible(
                      child: Text(
                        _text(
                          ar:
                              "رصيدك: $balance",
                          en:
                              "Your balance: $balance",
                        ),
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          color:
                              Colors.white,
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 10,
                ),

                // =================================================
                // ⚠️ حالة الرصيد
                // =================================================

                Text(
                  balance >= cost
                      ? _text(
                          ar:
                              "لديك عملات كافية للشراء.",
                          en:
                              "You have enough coins to purchase this level.",
                        )
                      : _text(
                          ar:
                              "تحتاج إلى ${cost - balance} عملة إضافية.",
                          en:
                              "You need ${cost - balance} more coins.",
                        ),
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: balance >= cost
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // ====================================================
          // 🔘 الأزرار
          // ====================================================

          actions: [
            // --------------------------------------------------
            // ❌ إلغاء
            // --------------------------------------------------

            TextButton(
              onPressed:
                  purchasingLevel
                      ? null
                      : () {
                          Navigator.pop(
                            dialogContext,
                          );
                        },
              child: Text(
                _text(
                  ar: "غير موافق",
                  en: "Cancel",
                ),
                style:
                    const TextStyle(
                  color:
                      Colors.white70,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),

            // --------------------------------------------------
            // 🪙 شراء
            // --------------------------------------------------

            ElevatedButton.icon(
              onPressed:
                  purchasingLevel ||
                          balance < cost
                      ? null
                      : () async {
                          await handlePurchaseLevel(
                            level,
                            dialogContext,
                          );
                        },

              icon: Image.asset(
                coinAsset,
                width: 25,
                height: 25,
                fit: BoxFit.contain,
                errorBuilder:
                    (_, __, ___) {
                  return const Icon(
                    Icons
                        .monetization_on,
                  );
                },
              ),

              label: Text(
                _text(
                  ar: "موافق",
                  en: "Buy",
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
                disabledBackgroundColor:
                    Colors.grey.shade700,
                disabledForegroundColor:
                    Colors.white54,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 18,
                  vertical: 11,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
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

    final int levelNumber =
        level.levelNumber;

    final String levelKey =
        getLevelKey(levelNumber);

    // ==========================================================
    // 🔓 المرحلة الأولى
    // ==========================================================

    if (levelNumber <= 1) {
      await PuzzleProgressManager
          .unlockLevel(
        levelKey,
      );

      if (mounted) {
        setState(() {
          _unlockedLevels[levelKey] =
              true;
        });
      }

      if (dialogContext.mounted) {
        Navigator.pop(
          dialogContext,
        );
      }

      await openPuzzle(level);
      return;
    }

    // ==========================================================
    // 🪙 السعر
    // ==========================================================

    final int cost =
        getLevelCoinCost(levelNumber);

    // ==========================================================
    // 💰 الرصيد
    // ==========================================================

    final int balance =
        await PuzzleProgressManager
            .getCoins();

    // ==========================================================
    // ❌ الرصيد غير كافٍ
    // ==========================================================

    if (balance < cost) {
      if (dialogContext.mounted) {
        Navigator.pop(
          dialogContext,
        );
      }

      if (!mounted) {
        return;
      }

      _showSimpleMessage(
        _text(
          ar:
              "لا تملك عملات كافية.\nتحتاج إلى ${cost - balance} عملة إضافية.",
          en:
              "Not enough coins.\nYou need ${cost - balance} more coins.",
        ),
        success: false,
      );

      return;
    }

    // ==========================================================
    // 🔄 بدء الشراء
    // ==========================================================

    if (mounted) {
      setState(() {
        purchasingLevel = true;
      });
    }

    // ==========================================================
    // 🪙 تنفيذ الشراء
    // ==========================================================

    final bool purchased =
        await PuzzleProgressManager
            .buyLevelWithCoins(
      levelKey,
      levelNumber,
    );

    // ==========================================================
    // ❌ فشل الشراء
    // ==========================================================

    if (!purchased) {
      if (mounted) {
        setState(() {
          purchasingLevel = false;
        });
      }

      if (dialogContext.mounted) {
        Navigator.pop(
          dialogContext,
        );
      }

      if (!mounted) {
        return;
      }

      _showSimpleMessage(
        _text(
          ar:
              "تعذر شراء المرحلة. حاول مرة أخرى.",
          en:
              "Unable to purchase the level. Please try again.",
        ),
        success: false,
      );

      return;
    }

    // ==========================================================
    // 🔓 الشراء نجح
    // ==========================================================

    if (mounted) {
      setState(() {
        purchasingLevel = false;

        // أهم نقطة:
        // تغيير حالة القفل محليًا فورًا.
        _unlockedLevels[levelKey] =
            true;
      });
    }

    // ==========================================================
    // ❌ إغلاق نافذة الشراء
    // ==========================================================

    if (dialogContext.mounted) {
      Navigator.pop(
        dialogContext,
      );
    }

    if (!mounted) {
      return;
    }

    // ==========================================================
    // 🔐 التأكد من التخزين
    // ==========================================================

    final bool confirmed =
        await PuzzleProgressManager
            .isLevelUnlocked(
      levelKey,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _unlockedLevels[levelKey] =
          confirmed;
    });

    // ==========================================================
    // 🎉 رسالة نجاح
    // ==========================================================

    if (confirmed) {
      _showLevelUnlockedMessage(
        levelNumber,
      );
    }
  }

  // ============================================================
  // 💬 رسالة بسيطة فوق الخريطة
  // ============================================================

  void _showSimpleMessage(
    String message, {
    required bool success,
  }) {
    _successMessageTimer?.cancel();

    if (!mounted) {
      return;
    }

    setState(() {
      _successMessage = message;
    });

    _successMessageTimer = Timer(
      const Duration(
        seconds: 2,
      ),
      () {
        if (!mounted) {
          return;
        }

        setState(() {
          _successMessage = null;
        });
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
    final String levelKey =
        getLevelKey(
      level.levelNumber,
    );

    final bool unlocked =
        level.levelNumber == 1 ||
        (_unlockedLevels[levelKey] ??
            false);

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
                    .withOpacity(0.35),
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
              // 🔒 / 🔓 صورة القفل
              // =================================================

              Image.asset(
                unlocked
                    ? "assets/images/ui/lock_open.png"
                    : "assets/images/ui/lock_close.png",

                width: size,
                height: size,

                fit:
                    BoxFit.contain,

                errorBuilder:
                    (_, __, ___) {
                  return Icon(
                    unlocked
                        ? Icons.lock_open
                        : Icons.lock,
                    color: unlocked
                        ? Colors.greenAccent
                        : Colors.amber,
                    size:
                        size * 0.55,
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
                          blurRadius: 5,
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
  // ✨ مقياس حركة الواجهة
  // ============================================================

  double get _uiPulseScale {
    return 1.10 +
        (_uiGlowController.value *
            0.08);
  }

  // ============================================================
  // ✨ وهج المحفظة والرجوع
  // ============================================================

  BoxDecoration _uiGlowDecoration() {
    final double glowStrength =
        0.55 +
            (_uiGlowController
                    .value *
                0.30);

    return BoxDecoration(
      shape:
          BoxShape.circle,
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
  // 🎉 واجهة رسالة النجاح
  // ============================================================

  Widget _buildMessageOverlay() {
    if (_successMessage ==
        null) {
      return const SizedBox
          .shrink();
    }

    return Positioned(
      top: 18,
      left: 88,
      right: 18,

      child: IgnorePointer(
        child: Material(
          color:
              Colors.transparent,

          child: Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 16,
              vertical: 12,
            ),

            decoration:
                BoxDecoration(
              color:
                  const Color(
                0xFF21452A,
              ),

              borderRadius:
                  BorderRadius.circular(
                18,
              ),

              border:
                  Border.all(
                color: Colors
                    .greenAccent
                    .withOpacity(
                  0.75,
                ),
                width: 1.5,
              ),

              boxShadow: [
                BoxShadow(
                  color: Colors
                      .black
                      .withOpacity(
                    0.40,
                  ),
                  blurRadius: 15,
                  offset:
                      const Offset(
                    0,
                    5,
                  ),
                ),

                BoxShadow(
                  color: Colors
                      .greenAccent
                      .withOpacity(
                    0.25,
                  ),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),

            child: Row(
              children: [
                Image.asset(
                  "assets/images/ui/lock_open.png",
                  width: 42,
                  height: 42,
                  fit: BoxFit.contain,
                  errorBuilder:
                      (_, __, ___) {
                    return const Icon(
                      Icons.lock_open,
                      color: Colors
                          .greenAccent,
                      size: 36,
                    );
                  },
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child: Text(
                    _successMessage!,
                    textAlign:
                        TextAlign.center,
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 15,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🗺️ BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
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
              return const SizedBox
                  .shrink();
            }

            // ==================================================
            // 📐 مقياس الخريطة
            // ==================================================

            final double scale =
                math.max(
              screenWidth /
                  worldWidth,
              screenHeight /
                  worldHeight,
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

            // حجم زر المرحلة
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
                              Alignment
                                  .topLeft,

                          child:
                              SizedBox(
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

                                child:
                                    Stack(
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

                                          fit: BoxFit
                                              .cover,

                                          errorBuilder:
                                              (
                                            _,
                                            __,
                                            ___,
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

                                          fit: BoxFit
                                              .contain,

                                          alignment:
                                              Alignment
                                                  .center,

                                          errorBuilder:
                                              (
                                            _,
                                            __,
                                            ___,
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

                                    ...List
                                        .generate(
                                      levels.length,
                                      (index) {
                                        if (index >=
                                            levelPositions
                                                .length) {
                                          return const SizedBox
                                              .shrink();
                                        }

                                        final Offset
                                            position =
                                            levelPositions[
                                                index];

                                        return Positioned(
                                          left:
                                              (worldWidth *
                                                      position
                                                          .dx) -
                                                  (levelButtonSize /
                                                      2),

                                          top:
                                              (worldHeight *
                                                      position
                                                          .dy) -
                                                  (levelButtonSize /
                                                      2),

                                          child:
                                              levelButton(
                                            levels[
                                                index],
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
                          child:
                              child,
                        ),
                      );
                    },

                    child:
                        GestureDetector(
                      behavior:
                          HitTestBehavior
                              .opaque,

                      onTap: () {
                        if (purchasingLevel) {
                          return;
                        }

                        Navigator.pop(
                          context,
                        );
                      },

                      child:
                          SizedBox(
                        width: 56,
                        height: 56,

                        child:
                            Image.asset(
                          "assets/images/ui/back_screen.png",

                          fit: BoxFit
                              .contain,

                          errorBuilder:
                              (
                            _,
                            __,
                            ___,
                          ) {
                            return const Icon(
                              Icons
                                  .arrow_back,
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
                          child:
                              child,
                        ),
                      );
                    },

                    child:
                        const WalletIconWidget(),
                  ),
                ),

                // =================================================
                // 🎉 رسالة فتح المرحلة
                //
                // هذه الرسالة في Stack الرئيسي
                // لذلك تظهر فوق طبقات الخريطة.
                // =================================================

                _buildMessageOverlay(),

                // =================================================
                // ⏳ مؤشر الشراء
                //
                // يظهر فوق كل شيء أثناء عملية الشراء.
                // =================================================

                if (purchasingLevel)
                  Positioned.fill(
                    child:
                        IgnorePointer(
                      child:
                          Container(
                        color: Colors
                            .black
                            .withOpacity(
                          0.30,
                        ),

                        child:
                            const Center(
                          child:
                              CircularProgressIndicator(
                            color:
                                Colors.amber,
                            strokeWidth:
                                4,
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

  // ============================================================
  // 🧹 DISPOSE
  // ============================================================

  @override
  void dispose() {
    languageManager
        .localeNotifier
        .removeListener(
      _onLanguageChanged,
    );

    _successMessageTimer
        ?.cancel();

    worldController.dispose();

    _uiGlowController.dispose();

    super.dispose();
  }
}
