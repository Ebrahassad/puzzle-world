import '../managers/puzzle_progress_manager.dart';


class PuzzleCloudService {


  //==================================================
  // 📤 تجهيز بيانات التقدم للرفع
  //==================================================

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







  //==================================================
  // 📥 استعادة التقدم
  //==================================================

  static Future<bool>

  restoreProgress(

      Map<String, dynamic> data,

      ) async {


    try {


      if(data.containsKey("stars")){


        await PuzzleProgressManager

            .saveStars(

          data["stars"] as int,

        );


      }





      if(data.containsKey("hints")){


        await PuzzleProgressManager

            .saveHints(

          data["hints"] as int,

        );


      }





      if(data.containsKey("completed")){


        await PuzzleProgressManager

            .restoreCompleted(

          data["completed"] as int,

        );


      }





      return true;



    } catch(_){



      return false;



    }


  }







  //==================================================
  // 🔄 مزامنة التقدم
  // حالياً محلية
  // لاحقاً تربط Firebase
  //==================================================

  static Future<bool>

  sync() async {


    final data =

    await uploadProgress();




    return await restoreProgress(

      data,

    );


  }


}