import '../managers/puzzle_progress_manager.dart';



class PuzzleCloudService {


  static Future<Map<String, dynamic>>

  uploadProgress() async {



    final data = {



      "stars":

      await PuzzleProgressManager

          .getTotalStars(),



      "completed":

      await PuzzleProgressManager

          .getCompletedPuzzleCount(),



      "hints":

      await PuzzleProgressManager

          .getHints(),



      "timestamp":

      DateTime.now()

          .toIso8601String(),



    };





    return data;


  }








  static Future<bool> restoreProgress(

      Map<String, dynamic> data,

      ) async {



    try {



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








  static Future<bool> sync() async {



    final data =

    await uploadProgress();





    return await restoreProgress(

      data,

    );


  }


}