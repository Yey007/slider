import 'dart:math';

import 'package:slider_app/cartesian_rectangle.dart';

class Bounds {
  final CartesianRectangle<double> _maxBounds;
  CartesianRectangle<double> _currentBounds;

  Point<double>? _previousFocalPoint;
  double? _previousScale;

  Bounds({required CartesianRectangle<double> maxBounds})
      : _maxBounds = maxBounds,
        _currentBounds = maxBounds;

  CartesianRectangle<double> get rect => _currentBounds;

  void startScale() {}

  void continueScale(double scale, Point<double> focalPoint) {
    _previousFocalPoint ??= focalPoint;
    _previousScale ??= scale;

    var scaleChange = scale / _previousScale!;

    var newWidth = _currentBounds.width / scaleChange;
    var newHeight = _currentBounds.height / scaleChange;

    // Take distance between current focal point and initial bottom left corner.
    var deltaFocalFromPrevCorner = focalPoint - _currentBounds.bottomLeft;
    var focalDelta = focalPoint - _previousFocalPoint!;
    // Scale that distance down, and move bottom left closer to the
    // focal point so that the new distance is the scaled down distance.
    var bottomLeft =
        focalPoint - deltaFocalFromPrevCorner * (1 / scaleChange) - focalDelta;

    var newBounds = CartesianRectangle.fromBLWH(
        bottomLeft: bottomLeft, width: newWidth, height: newHeight);

    _currentBounds = _chopBounds(newBounds);
    _previousFocalPoint = focalPoint;
    _previousScale = scale;
  }

  void endScale() {
    _previousFocalPoint = null;
    _previousScale = null;
  }

  CartesianRectangle<double> _chopBounds(CartesianRectangle<double> bounds) {
    var choppedBottomLeft = bounds.bottomLeft;
    var choppedTopRight = bounds.topRight;

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

    return CartesianRectangle(choppedBottomLeft, choppedTopRight);
  }
}
