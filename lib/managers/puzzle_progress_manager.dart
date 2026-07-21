import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../puzzle_engine/puzzle_piece.dart';



class PuzzleProgressManager {



  // إنشاء مفتاح خاص لكل صورة ومستوى

  static String _saveKey(

      String puzzleId,

      String levelId,

      ){

    return 'puzzle_${puzzleId}_$levelId';

  }






  // حفظ تقدم البازل

  static Future<void> saveProgress({


    required String puzzleId,


    required String levelId,


    required List<PuzzlePiece> pieces,


    required int moves,


    required int seconds,


  }) async {



    final prefs =

    await SharedPreferences.getInstance();




    final placedCount = pieces

        .where(

          (piece)=>piece.placed,

    )

        .length;




    final data = {



      'puzzleId': puzzleId,


      'levelId': levelId,


      'moves': moves,


      'seconds': seconds,


      'placedCount': placedCount,



      'lastSave':

      DateTime.now()

          .toIso8601String(),




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


      _saveKey(

        puzzleId,

        levelId,

      ),


      jsonEncode(data),


    );



  }







  // تحميل تقدم مستوى معين

  static Future<Map<String,dynamic>?>

  loadProgress({


    required String puzzleId,


    required String levelId,


  }) async {



    final prefs =

    await SharedPreferences.getInstance();




    final saved =

    prefs.getString(


      _saveKey(

        puzzleId,

        levelId,

      ),

    );





    if(saved == null){

      return null;

    }




    return jsonDecode(saved);

  }







  // هل يوجد حفظ لهذا المستوى؟

  static Future<bool> hasProgress({


    required String puzzleId,


    required String levelId,


  }) async {



    final prefs =

    await SharedPreferences.getInstance();



    return prefs.containsKey(


      _saveKey(

        puzzleId,

        levelId,

      ),

    );


  }







  // حذف حفظ مستوى بعد الفوز

  static Future<void> clearProgress({


    required String puzzleId,


    required String levelId,


  }) async {



    final prefs =

    await SharedPreferences.getInstance();



    await prefs.remove(


      _saveKey(

        puzzleId,

        levelId,

      ),

    );


  }







  // حذف كل تقدم البازل

  static Future<void> clearAllProgress() async {



    final prefs =

    await SharedPreferences.getInstance();



    final keys = prefs.getKeys();



    for(final key in keys){



      if(key.startsWith('puzzle_')){


        await prefs.remove(key);


      }


    }


  }



}