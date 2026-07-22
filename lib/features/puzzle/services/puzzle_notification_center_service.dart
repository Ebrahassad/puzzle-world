import '../managers/puzzle_progress_manager.dart';



class PuzzleNotificationCenterService {


  static Future<List<Map<String,dynamic>>>

  getNotifications() async {



    return await PuzzleProgressManager

        .getNotifications();


  }








  static Future<void> addNotification({

    required String title,

    required String message,

  }) async {



    final notifications =

    await getNotifications();





    notifications.add(



      {



        "title": title,


        "message": message,


        "read": false,


        "date":

        DateTime.now()

            .toIso8601String(),



      }



    );





    await PuzzleProgressManager

        .saveNotifications(

      notifications,

    );


  }








  static Future<void> markAsRead({

    required int index,

  }) async {



    final notifications =

    await getNotifications();





    if(index >= 0 &&

        index < notifications.length){



      notifications[index]["read"] = true;





      await PuzzleProgressManager

          .saveNotifications(

        notifications,

      );


    }


  }








  static Future<int> getUnreadCount() async {



    final notifications =

    await getNotifications();





    return notifications.where(

          (item) =>

      item["read"] == false,

    ).length;


  }








  static Future<void> clearAll() async {



    await PuzzleProgressManager

        .saveNotifications(

      [],

    );


  }


}