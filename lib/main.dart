import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'core/theme/app_theme.dart';
import 'features/puzzle/screens/world_map_screen.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await MobileAds.instance.initialize();

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

      debugShowCheckedModeBanner:false,

      title:"Puzzle World",

      theme: AppTheme.lightTheme,

      home: const WorldMapScreen(),

    );

  }

}