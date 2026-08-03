import 'package:flutter/foundation.dart';


class TrayController extends ChangeNotifier {

  double _offsetX = 0;

  double get offsetX => _offsetX;


  double minOffset = 0;

  double maxOffset = 0;


  void setBounds({
    required double contentWidth,
    required double viewportWidth,
  }) {

    maxOffset =
        (contentWidth - viewportWidth)
            .clamp(0, double.infinity);

    if (_offsetX > maxOffset) {
      _offsetX = maxOffset;
    }

    notifyListeners();
  }



  void startDrag(double x) {

  }



  void updateDrag(double x) {

    _offsetX -= x;

    if (_offsetX < minOffset) {
      _offsetX = minOffset;
    }

    if (_offsetX > maxOffset) {
      _offsetX = maxOffset;
    }


    notifyListeners();

  }



  void jumpTo(double value){

    _offsetX = value.clamp(
      minOffset,
      maxOffset,
    );

    notifyListeners();

  }



  void reset(){

    _offsetX = 0;

    notifyListeners();

  }


}