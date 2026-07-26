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