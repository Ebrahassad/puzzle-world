import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';



class PuzzleDatabaseService {


  static const String databaseKey =

      "puzzle_database";








  static Future<void> insert({

    required String key,

    required Map<String,dynamic> data,

  }) async {



    final database =

    await getDatabase();





    database[key] = data;





    await _saveDatabase(

      database,

    );


  }








  static Future<Map<String,dynamic>?>

  find({

    required String key,

  }) async {



    final database =

    await getDatabase();





    if(!database.containsKey(key)){

      return null;

    }





    return Map<String,dynamic>.from(

      database[key],

    );


  }








  static Future<List<Map<String,dynamic>>>

  getAll() async {



    final database =

    await getDatabase();





    return database.values

        .map(

          (e) =>

          Map<String,dynamic>.from(e),

    )

        .toList();


  }








  static Future<void> update({

    required String key,

    required Map<String,dynamic> data,

  }) async {



    await insert(

      key: key,

      data: data,

    );


  }








  static Future<void> remove({

    required String key,

  }) async {



    final database =

    await getDatabase();





    database.remove(

      key,

    );





    await _saveDatabase(

      database,

    );


  }








  static Future<void> clear() async {



    final prefs =

    await SharedPreferences.getInstance();





    await prefs.remove(

      databaseKey,

    );


  }








  static Future<Map<String,dynamic>>

  getDatabase() async {



    final prefs =

    await SharedPreferences.getInstance();





    final result =

    prefs.getString(

      databaseKey,

    );





    if(result == null){

      return {};

    }





    try {



      return Map<String,dynamic>.from(

        jsonDecode(

          result,

        ),

      );



    }catch(_){



      return {};

    }


  }








  static Future<void> _saveDatabase(

      Map<String,dynamic> data,

      ) async {



    final prefs =

    await SharedPreferences.getInstance();





    await prefs.setString(

      databaseKey,

      jsonEncode(

        data,

      ),

    );


  }


}