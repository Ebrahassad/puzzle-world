import 'dart:convert';

import '../managers/puzzle_progress_manager.dart';
import '../managers/reward_manager.dart';


class PuzzleExportService {


  const PuzzleExportService._();



  //==================================================
  // 📤 تصدير بيانات اللاعب
  //==================================================

  static Future<String> exportData() async {


    final data = {


      // ⭐ النجوم
      "stars":
      await PuzzleProgressManager.getTotalStars(),



      // 💡 التلميحات
      "hints":
      await PuzzleProgressManager.getHints(),



      // 🧩 تقدم البازل
      "progress":
      await PuzzleProgressManager.getProgress(),



      // 🏆 عدد المراحل المكتملة
      "completed":
      await PuzzleProgressManager.getCompletedPuzzleCount(),



      // 💰 العملات
      "coins":
      await RewardManager.getCoins(),



      // 💎 الجواهر
      "gems":
      await RewardManager.getGems(),



      // آخر عالم ومرحلة
      "lastPuzzle":
      await PuzzleProgressManager.getLastPuzzle(),



      // تاريخ النسخة
      "date":
      DateTime.now().toIso8601String(),


    };



    return jsonEncode(data);


  }






  //==================================================
  // 📥 استيراد البيانات
  //==================================================

  static Future<bool> importData(

      String json,

      ) async {


    try {


      final data = jsonDecode(json);



      if(data is! Map){

        return false;

      }





      if(data.containsKey("stars")){


        await PuzzleProgressManager.saveStars(

          data["stars"] ?? 0,

        );


      }





      if(data.containsKey("hints")){


        await PuzzleProgressManager.saveHints(

          data["hints"] ?? 0,

        );


      }





      if(data.containsKey("progress")){


        await PuzzleProgressManager.restoreProgress(

          data["progress"],

        );


      }





      if(data.containsKey("completed")){


        await PuzzleProgressManager.restoreCompleted(

          data["completed"] ?? 0,

        );


      }





      if(data.containsKey("coins")){


        await RewardManager.saveCoins(

          data["coins"] ?? 0,

        );


      }





      if(data.containsKey("gems")){


        await RewardManager.saveGems(

          data["gems"] ?? 0,

        );


      }





      return true;



    }catch(_){


      return false;


    }


  }







  //==================================================
  // 👁 معاينة النسخة
  //==================================================

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







  //==================================================
  // التحقق من النسخة
  //==================================================

  static bool isValidExport(

      String json,

      ) {


    try {


      final data = jsonDecode(json);



      return data is Map &&

          data.containsKey("stars") &&

          data.containsKey("progress");



    }catch(_){


      return false;


    }


  }


}