import 'package:flutter/material.dart';

import '../models/game_result_model.dart';
import '../models/reward_result_model.dart';

import '../managers/reward_manager.dart';
import '../managers/puzzle_progress_manager.dart';
import '../services/reward_ad_service.dart';


// مستقبلياً سننشئ هذه الملفات ونفعلها.
// ignore_for_file: unused_import
// import '../managers/puzzle_star_manager.dart';
// import '../managers/puzzle_world_manager.dart';
// import '../managers/puzzle_statistics_manager.dart';
// import '../managers/puzzle_save_manager.dart';
// import '../services/puzzle_audio_service.dart';
// import '../services/puzzle_navigation_service.dart';
// import '../services/puzzle_achievement_service.dart';
// import '../services/puzzle_cloud_service.dart';
// import '../services/puzzle_event_service.dart';



class PuzzleWinScreen extends StatefulWidget {
  final GameResultModel result;
  final int difficulty;
  final String? worldId;
  final int? level;

  // تجهيز مستقبلي للربط بدون العودة للملف
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







class _PuzzleWinScreenState extends State<PuzzleWinScreen>
    with SingleTickerProviderStateMixin {
  RewardResultModel? reward;
  bool loading = true;
  bool adUsed = false;

  late AnimationController animationController;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    scaleAnimation = Tween<double>(
      begin: 1,
      end: 1.15,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Hook مستقبلي للصوت/الاحتفال
    _onEnterWinScreen();

    completeLevel();
  }

  Future<void> _onEnterWinScreen() async {
    // مستقبلاً:
    // await PuzzleAudioService.playWinMusic();
    // await PuzzleEventService.levelScreenOpened(...);
  }

  Future<void> completeLevel() async {
    RewardResultModel rewardResult = const RewardResultModel(
      coins: 0,
      gems: 0,
    );

    final hasLevelContext =
        widget.worldId != null && widget.level != null;

    if (hasLevelContext) {
      final levelId = "${widget.worldId}_level_${widget.level}";

      final completed =
          await PuzzleProgressManager.isCompleted(levelId);

      if (!completed) {
        await PuzzleProgressManager.completeLevel(levelId);
        await PuzzleProgressManager.unlockNextLevel(levelId);
        await PuzzleProgressManager.addStars(widget.result.stars);

        // Hooks مستقبلية
        await _afterLevelCompleted(levelId);
      }

      final claimed =
          await PuzzleProgressManager.isRewardClaimed(levelId);

      if (!claimed) {
        rewardResult = await RewardManager.completePuzzle(
          difficulty: widget.difficulty,
        );

        await PuzzleProgressManager.markRewardClaimed(levelId);
      }
    } else {
      rewardResult = await RewardManager.completePuzzle(
        difficulty: widget.difficulty,
      );
    }

    if (!mounted) return;

    setState(() {
      reward = rewardResult;
      loading = false;
    });
  }

  Future<void> _afterLevelCompleted(String levelId) async {
    // هذه الدوال جاهزة للربط لاحقاً عند إنشاء الملفات الخاصة بها:
    //
    // await PuzzleStarManager.addStars(widget.result.stars);
    // await PuzzleStatisticsManager.onLevelCompleted(...);
    // await PuzzleWorldManager.updateWorldProgress(widget.worldId);
    // await PuzzleSaveManager.autoSave();
    // await PuzzleCloudService.sync();
    // await PuzzleAchievementService.checkAchievements();
    // PuzzleEventService.levelCompleted(...);
  }

  Future<void> doubleReward() async {
    if (adUsed || reward == null) {
      return;
    }

    final watched = await RewardAdService.showRewardAd();

    if (!watched) {
      return;
    }

    final extraCoins = reward!.coins;
    final extraGems = reward!.gems;

    await RewardManager.addCoins(extraCoins);

    if (extraGems > 0) {
      await RewardManager.addGems(extraGems);
    }

    // Hooks مستقبلية
    await _afterRewardDoubled(extraCoins, extraGems);

    if (!mounted) return;

    setState(() {
      reward = reward!.multiply(2);
      adUsed = true;
    });
  }

  Future<void> _afterRewardDoubled(int coins, int gems) async {
    // مستقبلًا:
    // await PuzzleStatisticsManager.onRewardDoubled();
    // PuzzleEventService.rewardDoubled(...);
    // await PuzzleAudioService.playRewardSound();
  }

  Future<void> _goToNextLevel() async {
    if (widget.onNextLevel != null) {
      widget.onNextLevel!();
      return;
    }

    // مستقبلًا:
    // await PuzzleNavigationService.openNextLevel(
    //   context,
    //   worldId: widget.worldId,
    //   currentLevel: widget.level,
    // );
  }

  Future<void> _goBackToWorld() async {
    if (widget.onBackToWorld != null) {
      widget.onBackToWorld!();
      return;
    }

    // مستقبلًا:
    // await PuzzleNavigationService.openWorld(context, widget.worldId);
  }

  Future<void> _goBackToHome() async {
    if (widget.onBackToHome != null) {
      widget.onBackToHome!();
      return;
    }

    // مستقبلًا:
    // await PuzzleNavigationService.openHome(context);
  }

  @override
  void dispose() {
    // مستقبلًا:
    // PuzzleAudioService.stopWinMusic();

    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffffd166),
              Color(0xffff9f1c),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: scaleAnimation,
                    child: const Text(
                      "🏆",
                      style: TextStyle(
                        fontSize: 90,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "أحسنت! 🎉",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "النجوم: ${widget.result.stars}  •  الحركات: ${widget.result.moves}  •  الوقت: ${widget.result.formattedTime}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 28),

                  rewardBox(),

                  const SizedBox(height: 28),

                  if (!adUsed)
                    ElevatedButton.icon(
                      onPressed: doubleReward,
                      icon: const Icon(Icons.play_circle),
                      label: const Text(
                        "🎬 مضاعفة المكافأة ×2",
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                    ),

                  const SizedBox(height: 14),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text(
                      "متابعة 🧩",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: _goBackToWorld,
                    child: const Text(
                      "العودة للعالم",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),

                  TextButton(
                    onPressed: _goBackToHome,
                    child: const Text(
                      "العودة للرئيسية",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget rewardBox() {
    return Container(
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "⭐ +${widget.result.stars}",
            style: const TextStyle(
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "🪙 +${reward!.coins}",
            style: const TextStyle(
              fontSize: 32,
            ),
          ),
          if (reward!.gems > 0) ...[
            const SizedBox(height: 8),
            Text(
              "💎 +${reward!.gems}",
              style: const TextStyle(
                fontSize: 30,
              ),
            ),
          ],
        ],
      ),
    );
  }
}