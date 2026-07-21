import 'package:shared_preferences/shared_preferences.dart';



class HintManager {


  static const String hintKey =
      "puzzle_hints";




  static Future<int> getHints() async {


    final prefs =
    await SharedPreferences.getInstance();


    return prefs.getInt(hintKey) ?? 3;


  }






  static Future<void> addHints(int amount) async {


    final prefs =
    await SharedPreferences.getInstance();



    final current =
    prefs.getInt(hintKey) ?? 3;



    await prefs.setInt(

      hintKey,

      current + amount,

    );


  }






  static Future<bool> useHint() async {


    final prefs =
    await SharedPreferences.getInstance();



    final current =
    prefs.getInt(hintKey) ?? 0;




    if(current <=0){

      return false;

    }



    await prefs.setInt(

      hintKey,

      current - 1,

    );



    return true;


  }


}