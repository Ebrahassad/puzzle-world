import 'package:flutter/material.dart';

import 'splash_screen.dart';


class PuzzleWorldApp extends StatelessWidget {

  const PuzzleWorldApp({
    super.key,
  });


  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: "Puzzle World",


      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),

        useMaterial3: true,

      ),


      home: const SplashScreen(),

    );

  }

}