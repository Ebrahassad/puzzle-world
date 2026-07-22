import 'package:flutter/material.dart';

import '../managers/puzzle_progress_manager.dart';



class PuzzleThemeService {


  static Future<bool> isDarkMode() async {


    return await PuzzleProgressManager

        .isDarkMode();


  }








  static Future<void> setDarkMode(

      bool value,

      ) async {



    await PuzzleProgressManager

        .saveDarkMode(

      value,

    );


  }








  static ThemeData getLightTheme(){



    return ThemeData(

      brightness: Brightness.light,

      primarySwatch: Colors.orange,

      scaffoldBackgroundColor:

      const Color(0xfffff8e7),

      fontFamily: "Cairo",

    );


  }








  static ThemeData getDarkTheme(){



    return ThemeData(

      brightness: Brightness.dark,

      primarySwatch: Colors.orange,

      scaffoldBackgroundColor:

      const Color(0xff202020),

      fontFamily: "Cairo",

    );


  }








  static ThemeData getTheme(

      bool dark,

      ){



    return dark

        ? getDarkTheme()

        : getLightTheme();


  }


}