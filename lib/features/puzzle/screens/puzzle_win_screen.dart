import 'package:flutter/material.dart';

import '../models/game_result_model.dart';
import '../models/reward_result_model.dart';

import '../managers/reward_manager.dart';
import '../managers/puzzle_progress_manager.dart';

import '../services/puzzle_navigation_service.dart';
import '../services/puzzle_reward_ad_service.dart';
import '../services/puzzle_audio_service.dart';
import '../services/puzzle_event_service.dart';

class PuzzleWinScreen extends StatefulWidget {
  final GameResultModel result;

  final int difficulty;

  final String? worldId;

  final int? level;

  final VoidCallback? onNextLevel;

  final VoidCallback? onBackToWorld;

  final VoidCallback? onBackToHome;

  const PuzzleWinScreen({
    super.key,
    required this.result,
    this.difficulty = 1,
    this.worldId,
    this.level,
    this.onNextLevel,
    this.onBackToWorld,
    this.onBackToHome,
  });

  @override
  State<PuzzleWinScreen> createState() =>
      _PuzzleWinScreenState();
}

class _PuzzleWinScreenState
    extends State<PuzzleWinScreen>
    with SingleTickerProviderStateMixin {

  RewardResultModel? reward;

  bool loading = true;

  bool adUsed = false;

  bool doubling = false;

  bool saved = false;

  late AnimationController animationController;

  late Animation<double> scaleAnimation;

  bool get hasNextLevel {
    if (widget.worldId == null ||
        widget.level == null) {
      return false;
    }

    return widget.level! < 10;
  }

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 1,
      ),
    )..repeat(
        reverse: true,
      );

    scaleAnimation = Tween<double>(
      begin: 1,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );

    initialize();
  }

  Future<void> initialize() async {
    try {
      await PuzzleAudioService.playWinSound();

      await saveCompletion();

      await loadReward();
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  //==================================================
  // حفظ إنهاء المرحلة
  //==================================================

  Future<void> saveCompletion() async {
    try {
      if (saved) return;

      if (widget.worldId == null ||
          widget.level == null) {
        return;
      }

      final levelKey =
          "${widget.worldId}_level_${widget.level}";

      await PuzzleProgressManager.completeLevel(
        levelKey,
      );

      await PuzzleProgressManager.saveLevelStars(
        levelKey,
        widget.result.stars,
      );

      await PuzzleProgressManager.unlockNextLevel(
        widget.worldId!,
        widget.level!,
      );

      await PuzzleProgressManager.saveLastPuzzle(
        widget.worldId!,
        "level_${widget.level}",
      );

      await PuzzleProgressManager.saveGameState({

  "puzzleId": widget.puzzle.id,

  "levelId": widget.level.levelNumber,

  "completed": true,

  "stars": widget.stars,

  "moves": widget.moves,

  "time": widget.time,

});

      await PuzzleProgressManager.addCompletedPuzzle(
        moves: widget.result.moves,
        seconds: widget.result.seconds,
      );

      saved = true;
    } catch (e) {
      debugPrint(
        "Save completion error : $e",
      );
    }
  }

  //==================================================
  // تحميل المكافأة من RewardManager
  //==================================================

  Future<void> loadReward() async {
    try {
      final rewardKey =
          (widget.worldId != null &&
                  widget.level != null)
              ? "${widget.worldId}_level_${widget.level}"
              : "default_reward";

      reward =
          await RewardManager.completePuzzle(
        difficulty: widget.difficulty,
        rewardKey: rewardKey,
      );

      reward ??= RewardResultModel(
        stars: widget.result.stars,
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  //==================================================
  // مضاعفة المكافأة بعد الإعلان
  //==================================================

  Future<void> doubleReward() async {
    try {
      if (reward == null ||
          adUsed ||
          doubling) {
        return;
      }

      setState(() {
        doubling = true;
      });

      final watched =
          await PuzzleRewardAdService
              .watchAdForDoubleReward();

      if (!watched) {
        if (mounted) {
          setState(() {
            doubling = false;
          });
        }
        return;
      }

      final oldReward = reward!;

      final newReward =
          await RewardManager.doubleReward(
        oldReward,
      );

      await PuzzleEventService.rewardDoubled(
        coins: oldReward.coins,
        gems: oldReward.gems,
      );

      if (!mounted) return;

      setState(() {
        reward = newReward;
        adUsed = true;
        doubling = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        doubling = false;
      });
    }
  }

  //==================================================
  // المستوى التالي
  //==================================================

  Future<void> nextLevel() async {
    try {
      if (widget.onNextLevel != null) {
        widget.onNextLevel!();
        return;
      }

      if (widget.worldId != null &&
          widget.level != null) {
        await PuzzleNavigationService.openNextLevel(
          context,
          worldId: widget.worldId!,
          currentLevel: widget.level!,
        );
      }
    } catch (_) {}
  }

  void backWorld() {
    if (widget.onBackToWorld != null) {
      widget.onBackToWorld!();
      return;
    }

    Navigator.pop(context);
  }

  void backHome() {
    if (widget.onBackToHome != null) {
      widget.onBackToHome!();
      return;
    }

    Navigator.popUntil(
      context,
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              "assets/images/background/win_background.png",
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.25),
            ),
          ),

          SafeArea(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: [

                      const SizedBox(height: 70),

                      ScaleTransition(
                        scale: scaleAnimation,
                        child: const Text(
                          "أحسنت! أكملت المرحلة 🎉",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      resultCard(),

                      const SizedBox(height: 15),

                      Text(
                        "الحركات: ${widget.result.moves}",
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "الوقت: ${widget.result.seconds} ثانية",
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 15),

                      if (reward != null)
                        rewardInfo(),

                      const Spacer(),

                      actionButton(
                        hasNextLevel
                            ? "🚀 المستوى التالي"
                            : "🌍 العودة للعالم",
                        hasNextLevel
                            ? Colors.purple
                            : Colors.blue,
                        hasNextLevel
                            ? nextLevel
                            : backHome,
                      ),

                      const SizedBox(height: 12),

                      if (!adUsed)
                        actionButton(
                          doubling
                              ? "⏳ جاري مضاعفة المكافأة..."
                              : "🎁 مضاعفة المكافأة",
                          Colors.orange,
                          doubleReward,
                        ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [

                          actionButton(
                            "العودة للجزيرة",
                            Colors.green,
                            backWorld,
                          ),

                          const SizedBox(width: 10),

                          actionButton(
                            "العودة للعالم",
                            Colors.blue,
                            backHome,
                          ),

                        ],
                      ),

                      const SizedBox(height: 30),

                    ],
                  ),
          ),

        ],
      ),
    );
  }

  //==================================================
  // عرض المكافأة
  //==================================================

  Widget rewardInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 40,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [

          if (reward!.coins > 0)
            Text(
              "🪙 العملات : ${reward!.coins}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

          if (reward!.gems > 0) ...[
            const SizedBox(height: 5),
            Text(
              "💎 الجواهر : ${reward!.gems}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],

          if (reward!.stars > 0) ...[
            const SizedBox(height: 5),
            Text(
              "⭐ Golden Star : ${reward!.stars}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],

          if (reward!.hints > 0) ...[
            const SizedBox(height: 5),
            Text(
              "💡 التلميحات : ${reward!.hints}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],

        ],
      ),
    );
  }

  //==================================================
  // بطاقة النتيجة
  //==================================================

  Widget resultCard() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 40,
      ),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.85),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [

          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 6),
          ),

        ],
      ),
      child: Column(
        children: [

          const SizedBox(height: 10),

          if (reward != null && reward!.stars > 0)
            Text(
              "+${reward!.stars} Golden Star",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

        ],
      ),
    );
  }

  //==================================================
  // زر موحد
  //==================================================

  Widget actionButton(
    String text,
    Color color,
    VoidCallback action,
  ) {
    return ElevatedButton(
      onPressed: action,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(25),
        ),
        elevation: 5,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  //==================================================
  // تنظيف الموارد
  //==================================================

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}