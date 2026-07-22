import 'package:flutter/material.dart';

import '../models/game_result_model.dart';
import '../models/reward_result_model.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

import '../managers/puzzle_progress_manager.dart';
import '../managers/reward_manager.dart';

import '../services/puzzle_audio_service.dart';
import '../services/puzzle_navigation_service.dart';
import '../services/puzzle_world_service.dart';
import '../services/reward_ad_service.dart';

class PuzzleWinScreen extends StatefulWidget {

  final GameResultModel result;

  final PuzzleModel puzzle;

  final PuzzleLevelModel level;

  final VoidCallback? onReplay;

  final VoidCallback? onNextLevel;

  final VoidCallback? onBack;

  const PuzzleWinScreen({

    super.key,

    required this.result,

    required this.puzzle,

    required this.level,

    this.onReplay,

    this.onNextLevel,

    this.onBack,

  });

  @override
  State<PuzzleWinScreen> createState() =>
      _PuzzleWinScreenState();

}

class _PuzzleWinScreenState
    extends State<PuzzleWinScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;

  late Animation<double> starAnimation;

  RewardResultModel reward =
      const RewardResultModel(
        coins: 0,
        gems: 0,
      );

  bool loading = true;

  bool rewardDoubled = false;

  int totalStars = 0;

  int totalCoins = 0;

  int totalGems = 0;

  @override
  void initState() {

    super.initState();

    controller = AnimationController(

      vsync: this,

      duration: const Duration(
        milliseconds: 900,
      ),

    )..repeat(
        reverse: true,
      );

    starAnimation = Tween<double>(
      begin: 1,
      end: 1.15,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    _prepareScreen();

  }

  Future<void> _prepareScreen() async {

    await PuzzleAudioService.playWinSound();

    await _saveProgress();

    reward = await RewardManager.completePuzzle(

      difficulty: widget.level.gridSize,

    );

    totalStars =
        await PuzzleProgressManager.getTotalStars();

    totalCoins =
        await RewardManager.getCoins();

    totalGems =
        await RewardManager.getGems();

    if (!mounted) return;

    setState(() {

      loading = false;

    });

  }

  Future<void> _saveProgress() async {

    final levelId =
        "${widget.puzzle.id}_level_${widget.level.gridSize}";

    await PuzzleProgressManager.completeLevel(
      levelId,
    );

    await PuzzleProgressManager.unlockNextLevel(
      levelId,
    );

    await PuzzleProgressManager.addStars(
      widget.result.stars,
    );

  }

  // =========================
  // 🎁 مضاعفة المكافأة
  // =========================

  Future<void> _doubleReward() async {

    if (rewardDoubled) {
      return;
    }

    final watched =
        await RewardAdService.showRewardAd();

    if (!watched) {
      return;
    }

    await RewardManager.addCoins(
      reward.coins,
    );

    if (reward.gems > 0) {

      await RewardManager.addGems(
        reward.gems,
      );

    }

    totalCoins =
        await RewardManager.getCoins();

    totalGems =
        await RewardManager.getGems();

    if (!mounted) return;

    setState(() {

      reward = reward.multiply(2);

      rewardDoubled = true;

    });

  }

  // =========================
  // ▶️ المرحلة التالية
  // =========================

  Future<void> _nextLevel() async {

    if (widget.onNextLevel != null) {

      widget.onNextLevel!();

      return;

    }

    await PuzzleWorldService.goToNextLevel(

      context,

      worldId: widget.puzzle.id,

      currentLevel: widget.level.gridSize,

    );

  }

  // =========================
  // 🔄 إعادة اللعب
  // =========================

  Future<void> _replay() async {

    if (widget.onReplay != null) {

      widget.onReplay!();

      return;

    }

    await PuzzleWorldService.replayLevel(

      context,

      world: widget.puzzle,

      level: widget.level,

    );

  }

  // =========================
  // 🔙 الرجوع للعالم
  // =========================

  Future<void> _back() async {

    if (widget.onBack != null) {

      widget.onBack!();

      return;

    }

    Navigator.pop(context);

  }

  @override
  void dispose() {

    controller.dispose();

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

      backgroundColor: const Color(0xffF7F9FC),

      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            padding: const EdgeInsets.all(20),

            child: Column(

              children: [

                ScaleTransition(

                  scale: starAnimation,

                  child: const Icon(

                    Icons.emoji_events,

                    size: 110,

                    color: Colors.amber,

                  ),

                ),

                const SizedBox(height: 16),

                const Text(

                  "🎉 أحسنت!",

                  style: TextStyle(

                    fontSize: 32,

                    fontWeight: FontWeight.bold,

                  ),

                ),

                const SizedBox(height: 8),

                Text(

                  widget.puzzle.title,

                  style: const TextStyle(

                    fontSize: 20,

                    color: Colors.grey,

                  ),

                ),

                const SizedBox(height: 25),

                Card(

                  elevation: 8,

                  shape: RoundedRectangleBorder(

                    borderRadius:

                        BorderRadius.circular(20),

                  ),

                  child: Padding(

                    padding: const EdgeInsets.all(20),

                    child: Column(

                      children: [

                        Row(

                          mainAxisAlignment:

                              MainAxisAlignment.spaceBetween,

                          children: [

                            const Text("⭐ النجوم"),

                            Text(

                              "${widget.result.stars}",

                              style: const TextStyle(

                                fontWeight: FontWeight.bold,

                              ),

                            ),

                          ],

                        ),

                        const Divider(),

                        Row(

                          mainAxisAlignment:

                              MainAxisAlignment.spaceBetween,

                          children: [

                            const Text("👣 الحركات"),

                            Text(

                              "${widget.result.moves}",

                            ),

                          ],

                        ),

                        const Divider(),

                        Row(

                          mainAxisAlignment:

                              MainAxisAlignment.spaceBetween,

                          children: [

                            const Text("⏱ الوقت"),

                            Text(

                              "${widget.result.seconds} ثانية",

                            ),

                          ],

                        ),

                      ],

                    ),

                  ),

                ),

                const SizedBox(height: 25),

                Card(

                  color: Colors.amber.shade50,

                  elevation: 5,

                  shape: RoundedRectangleBorder(

                    borderRadius:

                        BorderRadius.circular(20),

                  ),

                  child: Padding(

                    padding: const EdgeInsets.all(18),

                    child: Column(

                      children: [

                        const Text(

                          "🎁 المكافأة",

                          style: TextStyle(

                            fontWeight: FontWeight.bold,

                            fontSize: 20,

                          ),

                        ),

                        const SizedBox(height: 15),

                        Row(

                          mainAxisAlignment:

                              MainAxisAlignment.spaceEvenly,

                          children: [

                            Column(

                              children: [

                                const Icon(

                                  Icons.monetization_on,

                                  color: Colors.orange,

                                ),

                                Text(

                                  "${reward.coins}",

                                ),

                              ],

                            ),

                            Column(

                              children: [

                                const Icon(

                                  Icons.diamond,

                                  color: Colors.lightBlue,

                                ),

                                Text(

                                  "${reward.gems}",

                                ),

                              ],

                            ),

                          ],

                        ),

                      ],

                    ),

                  ),

                ),

                const SizedBox(height: 25),

                ElevatedButton.icon(

                  onPressed: rewardDoubled
                      ? null
                      : _doubleReward,

                  icon: const Icon(
                    Icons.play_circle_fill,
                  ),

                  label: Text(

                    rewardDoubled
                        ? "تمت مضاعفة المكافأة"
                        : "🎬 مضاعفة المكافأة",

                  ),

                  style: ElevatedButton.styleFrom(

                    minimumSize:
                        const Size(double.infinity, 55),

                    shape: RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius.circular(16),

                    ),

                  ),

                ),

                const SizedBox(height: 20),

                Row(

                  children: [

                    Expanded(

                      child: ElevatedButton(

                        onPressed: _replay,

                        child: const Text(

                          "🔄 إعادة",

                        ),

                      ),

                    ),

                    const SizedBox(width: 12),

                    Expanded(

                      child: ElevatedButton(

                        onPressed: _nextLevel,

                        child: const Text(

                          "➡ التالي",

                        ),

                      ),

                    ),

                  ],

                ),

                const SizedBox(height: 12),

                SizedBox(

                  width: double.infinity,

                  child: OutlinedButton(

                    onPressed: _back,

                    child: const Text(

                      "🏠 العودة",

                    ),

                  ),

                ),

                const SizedBox(height: 20),

                Text(

                  "⭐ $totalStars",

                  style: const TextStyle(

                    fontWeight: FontWeight.bold,

                    fontSize: 18,

                  ),

                ),

                const SizedBox(height: 8),

                Text(

                  "🪙 $totalCoins",

                  style: const TextStyle(

                    fontSize: 16,

                  ),

                ),

                Text(

                  "💎 $totalGems",

                  style: const TextStyle(

                    fontSize: 16,

                  ),

                ),

              ],

            ),

          ),

        ),

      ),

    );

  }

}