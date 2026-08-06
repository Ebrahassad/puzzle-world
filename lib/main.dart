import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/puzzle/managers/ads_manager.dart';
import 'features/puzzle/screens/world_map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Unity Ads
  await AdsManager().initAds();

  runApp(
    const PuzzleWorldApp(),
  );
}

class PuzzleWorldApp extends StatelessWidget {
  const PuzzleWorldApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Puzzle World",
      theme: AppTheme.lightTheme,
      home: const WorldMapScreen(),
    );
  }
}