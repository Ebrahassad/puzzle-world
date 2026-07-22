import '../engine/puzzle_piece.dart';
import '../managers/puzzle_progress_manager.dart';



class PuzzleHintManager {



  // =========================
  // 💡 عدد التلميحات
  // =========================


  static Future<int> getHints() async {


    return await PuzzleProgressManager.getHints();


  }








  // =========================
  // استهلاك تلميح
  // =========================


  static Future<bool> consumeHint() async {


    return await PuzzleProgressManager.useHint();


  }








  // =========================
  // إضافة تلميحات
  // =========================


  static Future<void> addHints(

      int amount,

      ) async {


    await PuzzleProgressManager.addHints(

      amount,

    );


  }








  // =========================
  // هل يوجد تلميح؟
  // =========================


  static Future<bool> hasHint() async {


    final hints = await getHints();


    return hints > 0;


  }








  // =========================
  // هل انتهت التلميحات؟
  // =========================


  static Future<bool> noHints() async {


    final hints = await getHints();


    return hints <= 0;


  }








  // =========================
  // إيجاد قطعة غير مكتملة
  // =========================


  static PuzzlePiece? findAvailablePiece(

      List<PuzzlePiece> pieces,

      ) {



    final available = pieces.where(

          (piece)=>!piece.placed,

    ).toList();




    if(available.isEmpty){

      return null;

    }




    return available.first;


  }








  // =========================
  // اختيار قطعة عشوائية
  // =========================


  static PuzzlePiece? getHintPiece(

      List<PuzzlePiece> pieces,

      ){



    final available = pieces.where(

          (piece)=>!piece.placed,

    ).toList();




    if(available.isEmpty){

      return null;

    }




    available.shuffle();



    return available.first;



  }








  // =========================
  // عدد القطع المتبقية
  // =========================


  static int remainingPieces(

      List<PuzzlePiece> pieces,

      ){



    return pieces.where(

          (piece)=>!piece.placed,

    ).length;



  }








  // =========================
  // هل اكتملت القطع؟
  // =========================


  static bool isFinished(

      List<PuzzlePiece> pieces,

      ){



    return pieces.every(

          (piece)=>piece.placed,

    );


  }



}