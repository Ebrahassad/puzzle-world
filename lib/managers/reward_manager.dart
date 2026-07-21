import 'package:shared_preferences/shared_preferences.dart';



class RewardManager {


  static const String coinsKey = "coins";

  static const String gemsKey = "gems";

  static const String puzzlesSolvedKey = "puzzles_solved";

  static const String dailyRewardKey = "daily_reward";





  // جلب العملات

  static Future<int> getCoins() async {

    final prefs =
    await SharedPreferences.getInstance();

    return prefs.getInt(coinsKey) ?? 0;

  }




  // إضافة عملات

  static Future<void> addCoins(int amount) async {


    final prefs =
    await SharedPreferences.getInstance();


    int current =
    prefs.getInt(coinsKey) ?? 0;


    await prefs.setInt(

      coinsKey,

      current + amount,

    );

  }






  // جلب الجواهر

  static Future<int> getGems() async {


    final prefs =
    await SharedPreferences.getInstance();


    return prefs.getInt(gemsKey) ?? 0;

  }





  // إضافة جواهر

  static Future<void> addGems(int amount) async {


    final prefs =
    await SharedPreferences.getInstance();


    int current =
    prefs.getInt(gemsKey) ?? 0;



    await prefs.setInt(

      gemsKey,

      current + amount,

    );

  }







  // تسجيل حل لغز

  static Future<void> puzzleCompleted() async {


    final prefs =
    await SharedPreferences.getInstance();



    int solved =

    prefs.getInt(puzzlesSolvedKey) ?? 0;



    await prefs.setInt(

      puzzlesSolvedKey,

      solved + 1,

    );



    // مكافأة الفوز

    await addCoins(50);



    // كل 10 ألغاز جواهر

    if((solved + 1) % 10 == 0){

      await addGems(1);

    }

  }







  // هل أخذ مكافأة اليوم

  static Future<bool> canClaimDaily() async {


    final prefs =
    await SharedPreferences.getInstance();


    String? last =

    prefs.getString(dailyRewardKey);



    if(last == null){

      return true;

    }



    DateTime oldDate =

    DateTime.parse(last);



    DateTime now = DateTime.now();



    return oldDate.day != now.day ||

        oldDate.month != now.month ||

        oldDate.year != now.year;


  }







  // أخذ الصندوق اليومي

  static Future<void> claimDaily() async {


    final prefs =
    await SharedPreferences.getInstance();



    await prefs.setString(

      dailyRewardKey,

      DateTime.now().toIso8601String(),

    );



    await addCoins(100);


    await addGems(1);


  }






  // مكافأة الإعلان

  static Future<void> rewardedAdBonus() async {


    // بعد مشاهدة الإعلان

    await addCoins(100);


  }



}