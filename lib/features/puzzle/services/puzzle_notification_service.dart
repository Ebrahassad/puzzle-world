import 'package:flutter/material.dart';



class PuzzleNotificationService {


  static void showSuccess({

    required BuildContext context,

    required String message,

  }) {



    ScaffoldMessenger.of(context)

        .showSnackBar(

      SnackBar(

        behavior: SnackBarBehavior.floating,

        backgroundColor: Colors.green,

        shape: RoundedRectangleBorder(

          borderRadius:

          BorderRadius.circular(20),

        ),

        content: Text(

          message,

          textAlign: TextAlign.center,

        ),

      ),

    );


  }








  static void showError({

    required BuildContext context,

    required String message,

  }) {



    ScaffoldMessenger.of(context)

        .showSnackBar(

      SnackBar(

        behavior: SnackBarBehavior.floating,

        backgroundColor: Colors.red,

        shape: RoundedRectangleBorder(

          borderRadius:

          BorderRadius.circular(20),

        ),

        content: Text(

          message,

          textAlign: TextAlign.center,

        ),

      ),

    );


  }








  static void showInfo({

    required BuildContext context,

    required String message,

  }) {



    ScaffoldMessenger.of(context)

        .showSnackBar(

      SnackBar(

        behavior: SnackBarBehavior.floating,

        backgroundColor: Colors.orange,

        shape: RoundedRectangleBorder(

          borderRadius:

          BorderRadius.circular(20),

        ),

        content: Text(

          message,

          textAlign: TextAlign.center,

        ),

      ),

    );


  }








  static Future<bool?> showConfirm({

    required BuildContext context,

    required String title,

    required String message,

  }) async {



    return await showDialog<bool>(

      context: context,

      builder: (_) {



        return AlertDialog(

          shape:

          RoundedRectangleBorder(

            borderRadius:

            BorderRadius.circular(25),

          ),

          title: Text(

            title,

            textAlign: TextAlign.center,

          ),

          content: Text(

            message,

            textAlign: TextAlign.center,

          ),

          actionsAlignment:

          MainAxisAlignment.center,

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(

                  context,

                  false,

                );

              },

              child:

              const Text(

                "إلغاء",

              ),

            ),

            ElevatedButton(

              onPressed: () {

                Navigator.pop(

                  context,

                  true,

                );

              },

              child:

              const Text(

                "موافق",

              ),

            ),

          ],

        );


      },

    );


  }


}