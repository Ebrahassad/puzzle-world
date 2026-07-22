import 'package:flutter/material.dart';

import '../models/game_result_model.dart';
import '../models/reward_result_model.dart';

import '../managers/puzzle_achievement_manager.dart';
import '../managers/puzzle_cloud_service.dart';
import '../managers/puzzle_event_service.dart';
import '../managers/puzzle_progress_manager.dart';
import '../managers/puzzle_save_manager.dart';
import '../managers/puzzle_statistics_manager.dart';
import '../managers/puzzle_world_manager.dart';
import '../managers/reward_manager.dart';

import '../services/puzzle_audio_service.dart';
import '../services/puzzle_navigation_service.dart';
import '../services/reward_ad_service.dart';



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







class _PuzzleWinScreenState extends State<PuzzleWinScreen>
    with SingleTickerProviderStateMixin {


  RewardResultModel? reward;


  bool loading = true;


  bool adUsed = false;



  late AnimationController animationController;


  late Animation<double> scaleAnimation;







  String? get _levelKey {
    if (widget.worldId == null || widget.level == null) {
      return null;
    }

    return "${widget.worldId}_level_${widget.level}";
  }







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

    _enterWinScreen();
    completeLevel();
  }







  Future<void> _enterWinScreen() async {
    await PuzzleAudioService.playWinSound();
    await PuzzleEventService.levelScreenOpened(
      worldId: widget.worldId,
      level: widget.level,
    );
  }







  Future<void> completeLevel() async {
    RewardResultModel rewardResult = const RewardResultModel(
      coins: 0,
      gems: 0,
    );

    final levelKey = _levelKey;

    if (levelKey != null) {
      final completed =
          await PuzzleProgressManager.isCompleted(levelKey);

      if (!completed) {
        await PuzzleProgressManager.completeLevel(levelKey);
        await PuzzleProgressManager.unlockNextLevel(levelKey);
        await PuzzleProgressManager.addStars(widget.result.stars);

        await _afterLevelCompleted(levelKey);
      }

      final claimed =
          await PuzzleProgressManager.isRewardClaimed(levelKey);

      if (!claimed) {
        rewardResult = await RewardManager.completePuzzle(
          difficulty: widget.difficulty,
        );

        await PuzzleProgressManager.markRewardClaimed(levelKey);
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







  Future<void> _afterLevelCompleted(String levelKey) async {
    await PuzzleStatisticsManager.recordPuzzleResult(
      worldId: widget.worldId,
      level: widget.level,
      stars: widget.result.stars,
      moves: widget.result.moves,
      time: widget.result.time,
    );

    await PuzzleWorldManager.updateWorldProgress(
      worldId: widget.worldId,
      level: widget.level,
      stars: widget.result.stars,
    );

    await PuzzleSaveManager.autoSavePuzzle(
      worldId: widget.worldId,
      level: widget.level,
    );

    await PuzzleCloudService.syncPuzzleProgress(
      worldId: widget.worldId,
      level: widget.level,
    );

    await PuzzleAchievementManager.checkPuzzleAchievements(
      worldId: widget.worldId,
      level: widget.level,
      result: widget.result,
    );

    PuzzleEventService.levelCompleted(
      worldId: widget.worldId,
      level: widget.level,
      stars: widget.result.stars,
      moves: widget.result.moves,
      seconds: widget.result.seconds,
    );
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

    await _afterRewardDoubled(extraCoins, extraGems);

    if (!mounted) return;

    setState(() {
      reward = reward!.multiply(2);
      adUsed = true;
    });
  }







  Future<void> _afterRewardDoubled(int coins, int gems) async {
    await PuzzleStatisticsManager.recordRewardDoubled(
      worldId: widget.worldId,
      level: widget.level,
      coins: coins,
      gems: gems,
    );

    PuzzleEventService.rewardDoubled(
      worldId: widget.worldId,
      level: widget.level,
      coins: coins,
      gems: gems,
    );
  }







  Future<void> _goToNextLevel() async {
    if (widget.onNextLevel != null) {
      widget.onNextLevel!();
      return;
    }

    final levelKey = _levelKey;