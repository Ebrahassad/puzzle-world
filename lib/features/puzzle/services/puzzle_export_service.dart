import 'dart:convert';



import '../managers/puzzle_progress_manager.dart';



class PuzzleExportService {


  static Future<String> exportData() async {



    final data = {



      "stars":

      await PuzzleProgressManager

          .getTotalStars(),



      "hints":

      await PuzzleProgressManager

          .getHints(),



      "progress":

      await PuzzleProgressManager

          .getProgress(),



      "completed":

      await PuzzleProgressManager

          .getCompletedPuzzleCount(),



      "date":

      DateTime.now()

          .toIso8601String(),



    };





    return jsonEncode(

      data,

    );


  }








  static Future<bool> importData(

      String json,

      ) async {



    try {



      final data =

      jsonDecode(

        json,

      );





      if(data is! Map){

        return false;

      }





      if(data.containsKey("stars")){



        await PuzzleProgressManager

            .saveStars(

          data["stars"],

        );


      }





      if(data.containsKey("hints")){



        await PuzzleProgressManager

            .saveHints(

          data["hints"],

        );


      }





      return true;



    }catch(_){



      return false;



    }


  }








  static Map<String,dynamic> decodePreview(

      String json,

      ) {



    try {



      return Map<String,dynamic>.from(

        jsonDecode(json),

      );



    }catch(_){



      return {};



    }


  }


}