import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../puzzle_engine/puzzle_piece.dart';



class PuzzleProgressManager {



  static const String _saveKey =
      'puzzle_current_progress';





  // حفظ تقدم اللعبة

  static Future<void> saveProgress({

    required String puzzleId,

    required String levelId,

    required List<PuzzlePiece> pieces,

    required int moves,

    required int seconds,

  }) async {



    final prefs =
    await SharedPreferences.getInstance();




    final data = {


      'puzzleId': puzzleId,


      'levelId': levelId,


      'moves': moves,


      'seconds': seconds,



      'pieces': pieces.map((piece){


        return {


          'id': piece.id,


          'x': piece.position.dx,


          'y': piece.position.dy,


          'placed': piece.placed,


        };


      }).toList(),



    };





    await prefs.setString(

      _saveKey,

      jsonEncode(data),

    );


  }





  // جلب آخر لعبة محفوظة

  static Future<Map<String,dynamic>?>

  loadProgress() async {



    final prefs =
    await SharedPreferences.getInstance();



    final saved =
    prefs.getString(_saveKey);




    if(saved == null){

      return null;

    }



    return jsonDecode(saved);

  }





  // هل يوجد تقدم محفوظ؟

  static Future<bool> hasProgress() async {



    final prefs =
    await SharedPreferences.getInstance();



    return prefs.containsKey(_saveKey);


  }





  // حذف الحفظ بعد إكمال اللعبة

  static Future<void> clearProgress() async {



    final prefs =
    await SharedPreferences.getInstance();



    await prefs.remove(_saveKey);


  }


}
