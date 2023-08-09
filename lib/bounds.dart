import 'dart:math';

import 'package:slider_app/cartesian_rectangle.dart';

class Bounds {
  final CartesianRectangle<double> _maxBounds; // TODO: limit zoom
  CartesianRectangle<double>? _scaleStartBounds;
  CartesianRectangle<double> _currentBounds;

  Bounds({required CartesianRectangle<double> maxBounds})
      : _maxBounds = maxBounds,
        _currentBounds = maxBounds;

  CartesianRectangle<double> get rect => _currentBounds;

  void startScale() => _scaleStartBounds = _currentBounds;

  void scale(double scale, Point<double> focalPoint) {
    if (_scaleStartBounds == null) {
      throw Exception('startScale must be called before attempting a scale.');
    }

    var startBoundsWidth = _scaleStartBounds!.width;
    var startBoundsHeight = _scaleStartBounds!.height;

    var newWidth = startBoundsWidth / scale;
    var newHeight = startBoundsHeight / scale;

    // keep focal point in the same place in chart space
    // for some reason, the position from the event is not always accurate, so we use a mouseRegion.
    var startFocalDelta = focalPoint - _scaleStartBounds!.bottomLeft;
    var bottomLeft = Point(
      focalPoint.x - (startFocalDelta.x / startBoundsWidth * newWidth),
      focalPoint.y - (startFocalDelta.y / startBoundsHeight * newHeight),
    );

    _currentBounds = CartesianRectangle.fromBLWH(
        bottomLeft: bottomLeft, width: newWidth, height: newHeight);
  }

  void endScale() => _scaleStartBounds = null;
}
