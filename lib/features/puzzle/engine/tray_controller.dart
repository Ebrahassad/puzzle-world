import 'dart:ui';

class TrayController {

  double offsetX = 0;

  double _startX = 0;
  double _startOffset = 0;


  void startDrag(double x) {

    _startX = x;
    _startOffset = offsetX;

  }


  void updateDrag(double x) {

    offsetX = _startOffset + (x - _startX);

  }


  void reset() {

    offsetX = 0;

  }


  void clamp(double min, double max) {

    if (offsetX < min) {
      offsetX = min;
    }

    if (offsetX > max) {
      offsetX = max;
    }

  }
}