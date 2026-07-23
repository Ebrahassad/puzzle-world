import '../managers/puzzle_progress_manager.dart';


class PuzzleCloudService {


  const PuzzleCloudService._();



  //==================================================
  // 📤 تجهيز بيانات التقدم للرفع
  //==================================================

  static Future<Map<String, dynamic>>

  uploadProgress() async {


    return {


      "stars":

      await PuzzleProgressManager.getTotalStars(),



      "completed":

      await PuzzleProgressManager.getCompletedCount(),



      "hints":

      await PuzzleProgressManager.getHints(),



      "coins":

      await PuzzleProgressManager.getCoins(),



      "gems":

      await PuzzleProgressManager.getGems(),



      "timestamp":

      DateTime.now().toIso8601String(),


    };


  }







  //==================================================
  // 📥 استعادة التقدم
  //==================================================

  static Future<bool>

  restoreProgress(

      Map<String,dynamic> data,

      ) async {


    try {



      if(data.containsKey("stars")){


        final current =

        await PuzzleProgressManager.getTotalStars();


        final value =

        (data["stars"] as int) - current;



        if(value > 0){


          await PuzzleProgressManager.addStars(

            value,

          );


        }


      }






      if(data.containsKey("hints")){


        final current =

        await PuzzleProgressManager.getHints();


        final value =

        (data["hints"] as int) - current;



        if(value > 0){


          await PuzzleProgressManager.addHints(

            value,

          );


        }


      }






      if(data.containsKey("coins")){


        final current =

        await PuzzleProgressManager.getCoins();


        final value =

        (data["coins"] as int) - current;



        if(value > 0){


          await PuzzleProgressManager.addCoins(

            value,

          );


        }


      }






      if(data.containsKey("gems")){


        final current =

        await PuzzleProgressManager.getGems();


        final value =

        (data["gems"] as int) - current;



        if(value > 0){


          await PuzzleProgressManager.addGems(

            value,

          );


        }


      }




      return true;



    }catch(_){


      return false;


    }


  }







  //==================================================
  // 🔄 مزامنة
  //==================================================

  static Future<bool> sync() async {


    final data = await uploadProgress();



    return await restoreProgress(

      data,

    );


  }


}