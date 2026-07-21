import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';



class CustomPuzzleManager {


  static const String key =
      "custom_puzzles";





  static Future<void> savePuzzle({

    required String imagePath,

    required int gridSize,

  }) async {



    final prefs =
    await SharedPreferences.getInstance();




    final list =
    prefs.getStringList(key) ?? [];




    final data = jsonEncode({


      "image": imagePath,


      "gridSize": gridSize,


      "created":

      DateTime.now()

          .toIso8601String(),



    });





    list.add(data);




    await prefs.setStringList(

      key,

      list,

    );


  }






  static Future<List<Map<String,dynamic>>>

  getPuzzles() async {



    final prefs =

    await SharedPreferences.getInstance();



    final list =

    prefs.getStringList(key) ?? [];





    return list.map((item){



      return Map<String,dynamic>.from(

        jsonDecode(item),

      );



    }).toList();



  }






  static Future<void> clear() async {


    final prefs =

    await SharedPreferences.getInstance();



    await prefs.remove(key);


  }



}