import 'dart:convert';

import '../managers/puzzle_progress_manager.dart';



class PuzzleBackupManagerService {


  static Future<String> createBackup() async {



    final backup = {



      "stars":

      await PuzzleProgressManager

          .getTotalStars(),



      "hints":

      await PuzzleProgressManager

          .getHints(),



      "completed":

      await PuzzleProgressManager

          .getCompletedPuzzleCount(),



      "levels":

      await PuzzleProgressManager

          .getProgress(),



      "createdAt":

      DateTime.now()

          .toIso8601String(),



    };





    return jsonEncode(

      backup,

    );


  }








  static Future<bool> restoreBackup(

      String backup,

      ) async {



    try {



      final data =

      jsonDecode(

        backup,

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





      if(data.containsKey("levels")){



        await PuzzleProgressManager

            .restoreProgress(

          data["levels"],

        );


      }





      if(data.containsKey("completed")){



        await PuzzleProgressManager

            .restoreCompleted(

          data["completed"],

        );


      }





      return true;



    }catch(_){



      return false;



    }


  }








  static Map<String,dynamic> preview(

      String backup,

      ) {



    try {



      return Map<String,dynamic>.from(

        jsonDecode(

          backup,

        ),

      );



    }catch(_){



      return {};

    }


  }








  static bool validate(

      String backup,

      ) {



    try {



      final data =

      jsonDecode(

        backup,

      );





      return data is Map &&

          data.containsKey(

            "stars",

          );



    }catch(_){



      return false;



    }


  }


}