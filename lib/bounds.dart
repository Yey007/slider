import 'dart:math';

import 'package:slider_app/cartesian_rectangle.dart';

class Bounds {
  final CartesianRectangle<double> _maxBounds;
  CartesianRectangle<double>? _scaleStartBounds;
  CartesianRectangle<double> _currentBounds;

  Bounds({required CartesianRectangle<double> maxBounds})
      : _maxBounds = maxBounds,
        _currentBounds = maxBounds;

  CartesianRectangle<double> get rect => _currentBounds;

  void startScale() => _scaleStartBounds = _currentBounds;

  void continueScale(double scale, Point<double> focalPoint) {
    if (_scaleStartBounds == null) {
      throw Exception('startScale must be called before continuing a scale.');
    }

    var startBoundsWidth = _scaleStartBounds!.width;
    var startBoundsHeight = _scaleStartBounds!.height;

    var newWidth = startBoundsWidth / scale;
    var newHeight = startBoundsHeight / scale;

    // keep focal point in the same place in chart space
    var startFocalDelta = focalPoint - _scaleStartBounds!.bottomLeft;
    var bottomLeft = Point(
      focalPoint.x - (startFocalDelta.x / startBoundsWidth * newWidth),
      focalPoint.y - (startFocalDelta.y / startBoundsHeight * newHeight),
    );

    var newBounds = CartesianRectangle.fromBLWH(
        bottomLeft: bottomLeft, width: newWidth, height: newHeight);

    // chop rectangle to fit in max bounds
    var choppedBottomLeft = newBounds.bottomLeft;
    var choppedTopRight = newBounds.topRight;

    if (choppedBottomLeft.x < _maxBounds.left) {
      choppedBottomLeft = Point(_maxBounds.left, choppedBottomLeft.y);
    }

    if (choppedTopRight.x > _maxBounds.right) {
      choppedTopRight = Point(_maxBounds.right, choppedTopRight.y);
    }

    if (choppedBottomLeft.y < _maxBounds.bottom) {
      choppedBottomLeft = Point(choppedBottomLeft.x, _maxBounds.bottom);
    }

    if (choppedTopRight.y > _maxBounds.top) {
      choppedTopRight = Point(choppedTopRight.x, _maxBounds.top);
    }

    _currentBounds = CartesianRectangle(choppedBottomLeft, choppedTopRight);
  }

  void endScale() => _scaleStartBounds = null;
}
