import 'package:flutter/material.dart';


class AppTheme {



  static ThemeData get lightTheme {



    return ThemeData(


      useMaterial3: true,


      // الخط الأساسي لكل التطبيق

      fontFamily: "Cairo",





      colorScheme: ColorScheme.fromSeed(

        seedColor: Colors.blue,

        brightness: Brightness.light,

      ),





      scaffoldBackgroundColor:

      Colors.transparent,







      //==================================================
      // AppBar Style
      //==================================================

      appBarTheme: const AppBarTheme(


        centerTitle: true,


        elevation: 0,


        titleTextStyle: TextStyle(


          fontFamily:"Cairo",


          fontSize:24,


          fontWeight:FontWeight.bold,


          color:Colors.white,


        ),


      ),







      //==================================================
      // Text Theme
      //==================================================

      textTheme: const TextTheme(



        bodyLarge: TextStyle(

          fontFamily:"Cairo",

          fontSize:18,

          fontWeight:FontWeight.w400,

        ),



        bodyMedium: TextStyle(

          fontFamily:"Cairo",

          fontSize:16,

          fontWeight:FontWeight.w400,

        ),



        titleLarge: TextStyle(

          fontFamily:"Cairo",

          fontSize:24,

          fontWeight:FontWeight.bold,

        ),



        headlineMedium: TextStyle(

          fontFamily:"Cairo",

          fontSize:32,

          fontWeight:FontWeight.bold,

        ),



      ),







      //==================================================
      // Elevated Button Style
      //==================================================

      elevatedButtonTheme:

      ElevatedButtonThemeData(


        style: ElevatedButton.styleFrom(


          textStyle: const TextStyle(


            fontFamily:"Cairo",


            fontSize:18,


            fontWeight:FontWeight.bold,


          ),


          shape: RoundedRectangleBorder(


            borderRadius:

            BorderRadius.circular(30),


          ),


          elevation:8,


        ),


      ),







      //==================================================
      // Dialog Style
      //==================================================

      dialogTheme: DialogThemeData(


        backgroundColor:

        Colors.white,


        elevation:12,


        shape:

        RoundedRectangleBorder(


          borderRadius:

          BorderRadius.circular(30),


        ),



        titleTextStyle:

        const TextStyle(


          fontFamily:"Cairo",


          fontSize:24,


          fontWeight:

          FontWeight.bold,


          color:

          Colors.black87,


        ),



        contentTextStyle:

        const TextStyle(


          fontFamily:"Cairo",


          fontSize:18,


          color:

          Colors.black54,


        ),


      ),







      //==================================================
      // SnackBar Style
      //==================================================

      snackBarTheme:


      SnackBarThemeData(



        behavior:

        SnackBarBehavior.floating,



        elevation:

        10,



        backgroundColor:

        Colors.blueAccent,



        shape:

        RoundedRectangleBorder(



          borderRadius:

          BorderRadius.circular(25),



        ),



        contentTextStyle:

        const TextStyle(



          fontFamily:"Cairo",



          fontSize:17,



          fontWeight:

          FontWeight.bold,



          color:

          Colors.white,



        ),



        actionTextColor:

        Colors.yellow,


      ),






    );

  }


}