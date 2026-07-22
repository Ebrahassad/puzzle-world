import 'package:flutter/animation.dart';



class PuzzleAnimationService {


  static AnimationController createController({

    required TickerProvider vsync,

    Duration duration = const Duration(milliseconds:500),

  }) {



    return AnimationController(

      vsync: vsync,

      duration: duration,

    );


  }








  static Animation<double> scaleAnimation(

      AnimationController controller,

      ) {



    return Tween<double>(

      begin: 0.8,

      end: 1.0,

    ).animate(

      CurvedAnimation(

        parent: controller,

        curve: Curves.elasticOut,

      ),

    );


  }








  static Animation<double> fadeAnimation(

      AnimationController controller,

      ) {



    return Tween<double>(

      begin: 0,

      end: 1,

    ).animate(

      CurvedAnimation(

        parent: controller,

        curve: Curves.easeIn,

      ),

    );


  }








  static Animation<Offset> slideAnimation(

      AnimationController controller,

      ) {



    return Tween<Offset>(

      begin: const Offset(0, 0.5),

      end: Offset.zero,

    ).animate(

      CurvedAnimation(

        parent: controller,

        curve: Curves.easeOut,

      ),

    );


  }








  static void start(

      AnimationController controller,

      ) {



    controller.forward();


  }








  static void repeat(

      AnimationController controller,

      ) {



    controller.repeat(

      reverse: true,

    );


  }








  static void stop(

      AnimationController controller,

      ) {



    controller.stop();


  }


}