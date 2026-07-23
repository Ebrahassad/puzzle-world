import '../managers/puzzle_progress_manager.dart';



class PuzzleTutorialService {


  const PuzzleTutorialService._();




  //==================================================
  // 📘 هل تم إنهاء الشرح
  //==================================================

  static Future<bool> isCompleted() async {


    return await PuzzleProgressManager

        .isTutorialCompleted();


  }








  //==================================================
  // ✅ إنهاء الشرح
  //==================================================

  static Future<void> complete() async {


    await PuzzleProgressManager

        .completeTutorial();


  }








  //==================================================
  // 🔄 إعادة الشرح
  //==================================================

  static Future<void> reset() async {


    await PuzzleProgressManager

        .resetTutorial();


  }








  //==================================================
  // 📚 خطوات التعليم
  //==================================================

  static List<Map<String, String>>

  getSteps() {


    return [


      {


        "title": "حرك القطعة",


        "description":

        "اسحب قطع الصورة وضعها في المكان الصحيح",


      },





      {


        "title": "طابق الصورة",


        "description":

        "رتب جميع القطع حتى تكتمل الصورة",


      },





      {


        "title": "اجمع النجوم",


        "description":

        "أنهِ المراحل لتحصل على نجوم ومكافآت",


      },





      {


        "title": "استخدم المساعدة",


        "description":

        "يمكنك استخدام النجوم أو الإعلانات للحصول على تلميحات",


      },


    ];


  }








  //==================================================
  // 🔢 عدد الخطوات
  //==================================================

  static int getStepsCount(){


    return getSteps().length;


  }


}