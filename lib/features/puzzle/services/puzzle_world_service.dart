import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

import '../data/puzzle_data.dart';
import '../data/puzzle_level_data.dart';

import '../managers/puzzle_progress_manager.dart';
import '../managers/reward_manager.dart';

import '../screens/puzzle_home_screen.dart';
import '../screens/puzzle_level_screen.dart';
import '../screens/puzzle_game_screen.dart';
import '../screens/puzzle_win_screen.dart';
import '../screens/wallet_screen.dart';

import '../services/puzzle_navigation_service.dart';

class PuzzleWorldService {
  const PuzzleWorldService._();

  //==================================================
  // العوالم
  //==================================================

  static List<PuzzleModel> get worlds =>
      PuzzleData.puzzles;


  static Future<List<PuzzleModel>> loadWorlds() async {
    return PuzzleData.puzzles;
  }


  static Future<PuzzleModel?> getWorld(
      String worldId) async {

    try {

      return PuzzleData.puzzles.firstWhere(
        (e) => e.id == worldId,
      );

    } catch (_) {

      return null;

    }

  }



  //==================================================
  // المراحل
  //==================================================

  static Future<List<PuzzleLevelModel>> loadLevels(
      String worldId) async {

    return PuzzleLevelData.getLevels(worldId);

  }



  //==================================================
  // الموارد
  //==================================================

  static Future<int> getTotalStars() async {

    return PuzzleProgressManager.getTotalStars();

  }


  static Future<int> getCoins() async {

    return RewardManager.getCoins();

  }


  static Future<int> getGems() async {

    return RewardManager.getGems();

  }


  static Future<int> getHints() async {

    return PuzzleProgressManager.getHints();

  }



  //==================================================
  // فتح العالم
  //==================================================

  static Future<bool> isWorldUnlocked(
      PuzzleModel world) async {

    return true;

  }



  //==================================================
  // فتح شاشة العالم
  //==================================================

  static Future<void> openWorld(
      BuildContext context,
      PuzzleModel world,
      ) async {

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PuzzleLevelScreen(
          puzzle: world,
        ),
      ),
    );

  }



  //==================================================
  // فتح مرحلة
  //==================================================

  static Future<void> openLevel(
      BuildContext context, {

        required PuzzleModel world,

        required PuzzleLevelModel level,

      }) async {


    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PuzzleGameScreen(
          puzzle: world,
          level: level,
        ),
      ),
    );


  }



  //==================================================
  // المحفظة
  //==================================================

  static Future<void> openWallet(
      BuildContext context) async {

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WalletScreen(),
      ),
    );

  }



  //==================================================
  // الرئيسية
  //==================================================

  static Future<void> returnToHome(
      BuildContext context) async {


    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const PuzzleHomeScreen(),
      ),
          (route) => false,
    );


  }



  //==================================================
  // إكمال المرحلة
  //==================================================

  static Future<void> completeLevel({

    required String worldId,

    required int level,

    required int stars,

  }) async {


    final id =
        "${worldId}_level_$level";


    await PuzzleProgressManager.completeLevel(
      id,
    );


    await PuzzleProgressManager.unlockNextLevel(
      id,
    );


    await PuzzleProgressManager.addStars(
      stars,
    );


  }



  //==================================================
  // المرحلة التالية
  //==================================================

  static Future<void> goToNextLevel(
      BuildContext context, {

        required String worldId,

        required int currentLevel,

      }) async {


    await PuzzleNavigationService.openNextLevel(

      context,

      worldId: worldId,

      currentLevel: currentLevel,

    );


  }



  //==================================================
  // إعادة المرحلة
  //==================================================

  static Future<void> replayLevel(
      BuildContext context, {

        required PuzzleModel world,

        required PuzzleLevelModel level,

      }) async {


    await Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder: (_) => PuzzleGameScreen(

          puzzle: world,

          level: level,

        ),

      ),

    );


  }



  //==================================================
  // شاشة الفوز
  //==================================================

  static Future<void> openWinScreen(

      BuildContext context,

      PuzzleWinScreen screen,

      ) async {


    await Navigator.pushReplacement(

      context,

      MaterialPageRoute(

        builder: (_) => screen,

      ),

    );


  }


}