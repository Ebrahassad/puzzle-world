import 'package:flutter/services.dart';



class PuzzleShareService {


  static Future<void> shareResult({

    required String worldName,

    required int level,

    required int stars,

  }) async {



    final message =

        "🧩 أكملت عالم $worldName\n"

        "🏆 المرحلة: $level\n"

        "⭐ حصلت على $stars نجوم\n"

        "🎉 العب لعبة البازل معي!";





    await Clipboard.setData(

      ClipboardData(

        text: message,

      ),

    );


  }








  static Future<void> copyResult({

    required String text,

  }) async {



    await Clipboard.setData(

      ClipboardData(

        text: text,

      ),

    );


  }








  static String buildShareText({

    required String worldName,

    required int level,

    required int stars,

  }) {



    return

        "🧩 عالم $worldName\n"

        "🎮 المرحلة $level\n"

        "⭐ النجوم $stars\n"

        "🌟 Kids World";


  }


}