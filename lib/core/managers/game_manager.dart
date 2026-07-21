import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_profile.dart';

class GameManager extends StateNotifier<PlayerProfile> {
  GameManager() : super(const PlayerProfile()) {
    load();
  }

  static const String _saveKey = "player_profile";

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final json = prefs.getString(_saveKey);

    if (json == null) {
      return;
    }

    final data = jsonDecode(json);

    state = PlayerProfile(
      coins: data["coins"] ?? 0,
      gems: data["gems"] ?? 0,
      hints: data["hints"] ?? 3,
      adsWatched: data["adsWatched"] ?? 0,
      completedPuzzles: data["completedPuzzles"] ?? 0,
      unlockedWorlds: data["unlockedWorlds"] ?? 1,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _saveKey,
      jsonEncode({
        "coins": state.coins,
        "gems": state.gems,
        "hints": state.hints,
        "adsWatched": state.adsWatched,
        "completedPuzzles": state.completedPuzzles,
        "unlockedWorlds": state.unlockedWorlds,
      }),
    );
  }

  Future<void> addCoins(int value) async {
    state = state.copyWith(
      coins: state.coins + value,
    );

    await save();
  }

  Future<void> removeCoins(int value) async {
    if (state.coins < value) return;

    state = state.copyWith(
      coins: state.coins - value,
    );

    await save();
  }

  Future<void> addGems(int value) async {
    state = state.copyWith(
      gems: state.gems + value,
    );

    await save();
  }

  Future<void> addHints(int value) async {
    state = state.copyWith(
      hints: state.hints + value,
    );

    await save();
  }

  Future<bool> useHint() async {
    if (state.hints <= 0) {
      return false;
    }

    state = state.copyWith(
      hints: state.hints - 1,
    );

    await save();

    return true;
  }

  Future<void> addAdWatch() async {
    state = state.copyWith(
      adsWatched: state.adsWatched + 1,
    );

    await save();
  }

  Future<void> completePuzzle() async {
    state = state.copyWith(
      completedPuzzles: state.completedPuzzles + 1,
    );

    await save();
  }

  Future<void> unlockNextWorld() async {
    state = state.copyWith(
      unlockedWorlds: state.unlockedWorlds + 1,
    );

    await save();
  }

  Future<void> resetProfile() async {
    state = const PlayerProfile();

    await save();
  }
}

final gameManagerProvider =
    StateNotifierProvider<GameManager, PlayerProfile>(
  (ref) => GameManager(),
);
