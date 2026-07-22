import '../managers/puzzle_progress_manager.dart';



class PuzzleBackupService {


  static Future<Map<String, dynamic>>

  createBackup() async {



    final stars =

    await PuzzleProgressManager

        .getTotalStars();





    final hints =

    await PuzzleProgressManager

        .getHints();





    final progress =

    await PuzzleProgressManager

        .getProgress();





    return {



      "stars": stars,


      "hints": hints,


      "progress": progress,


      "date":

      DateTime.now()

          .toIso8601String(),



    };


  }








  static Future<void> restoreBackup(

      Map<String, dynamic> data,

      ) async {



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





    if(data.containsKey("progress")){



      await PuzzleProgressManager

          .restoreProgress(

        data["progress"],

      );


    }


  }








  static bool isValidBackup(

      Map<String, dynamic> data,

      ) {



    return data.containsKey(

      "stars",

    ) &&

        data.containsKey(

          "progress",

        );


  }


}