import 'package:flutter/material.dart';



class AppTheme {


  static ThemeData lightTheme = ThemeData(



    useMaterial3: true,



    fontFamily: "Cairo",




    scaffoldBackgroundColor:
    Colors.white,





    colorScheme: ColorScheme.fromSeed(

      seedColor: Colors.blueAccent,

    ),







    textTheme: const TextTheme(



      displayLarge: TextStyle(

        fontFamily: "Cairo",

        fontSize:34,

        fontWeight:

        FontWeight.bold,

      ),




      headlineLarge: TextStyle(

        fontFamily: "Cairo",

        fontSize:28,

        fontWeight:

        FontWeight.bold,

      ),





      titleLarge: TextStyle(

        fontFamily: "Cairo",

        fontSize:22,

        fontWeight:

        FontWeight.bold,

      ),





      bodyLarge: TextStyle(

        fontFamily: "Cairo",

        fontSize:18,

        fontWeight:

        FontWeight.w500,

      ),




      bodyMedium: TextStyle(

        fontFamily: "Cairo",

        fontSize:16,

        fontWeight:

        FontWeight.w400,

      ),



    ),








    elevatedButtonTheme:

    ElevatedButtonThemeData(



      style:

      ElevatedButton.styleFrom(



        elevation:6,



        padding:

        const EdgeInsets.symmetric(

          horizontal:28,

          vertical:14,

        ),



        shape:

        RoundedRectangleBorder(



          borderRadius:

          BorderRadius.circular(22),



        ),



        textStyle:

        const TextStyle(



          fontFamily:"Cairo",



          fontSize:18,



          fontWeight:

          FontWeight.bold,



        ),



      ),



    ),







    dialogTheme:

    DialogThemeData(



      backgroundColor:

      Colors.white,



      elevation:12,



      shape:

      RoundedRectangleBorder(



        borderRadius:

        BorderRadius.circular(28),



      ),



      titleTextStyle:

      const TextStyle(



        fontFamily:"Cairo",



        fontSize:22,



        fontWeight:

        FontWeight.bold,



        color:

        Colors.black,



      ),



    ),







    snackBarTheme:

    SnackBarThemeData(



      behavior:

      SnackBarBehavior.floating,



      elevation:8,



      shape:

      RoundedRectangleBorder(



        borderRadius:

        BorderRadius.circular(18),



      ),



      contentTextStyle:

      const TextStyle(



        fontFamily:"Cairo",



        fontSize:16,



        color:

        Colors.white,



      ),



    ),





  );



}
