import 'dart:async';



class PuzzleTimerService {


  Timer? _timer;


  int _seconds = 0;


  bool _running = false;








  int get seconds => _seconds;


  bool get isRunning => _running;








  void start({

    Function(int)? onTick,

  }) {



    if(_running){

      return;

    }





    _running = true;





    _timer = Timer.periodic(

      const Duration(seconds:1),

          (_) {


        _seconds++;


        onTick?.call(

          _seconds,

        );


      },

    );


  }








  void pause(){



    _timer?.cancel();


    _running = false;


  }








  void resume({

    Function(int)? onTick,

  }) {



    start(

      onTick: onTick,

    );


  }








  void reset(){



    _timer?.cancel();


    _seconds = 0;


    _running = false;


  }








  void dispose(){



    _timer?.cancel();


    _timer = null;


  }


}