import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class PuzzleWorldApp extends StatelessWidget {
  const PuzzleWorldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puzzle World',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
      ),

      home: const HomeScreen(),
    );
  }
}
