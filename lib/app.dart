import 'package:flutter/material.dart';

import 'screens/home_screen.dart';


class PuzzleWorldApp extends StatelessWidget {

  const PuzzleWorldApp({super.key});


  @override
  Widget build(BuildContext context) {


    return MaterialApp(

      debugShowCheckedModeBanner:false,


      title:'Puzzle World',


      theme: ThemeData(

        useMaterial3:true,

        colorSchemeSeed:Colors.blue,

      ),


      home:const HomeScreen(),

    );

  }

}