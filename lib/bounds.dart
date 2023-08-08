import 'dart:math';

import 'package:slider_app/cartesian_rectangle.dart';

// TODO: important question. How deep should immutability go? I'm not sure
// if what we have right now is okay, because it might give a false sense
// of immutability. If we make Bounds immutable, should we make curves immutable
// too? Should the entire list of curves be immutable? Sometimes I miss Haskell.
class Bounds {
  final CartesianRectangle<double> _maxBounds; // TODO: limit zoom
  CartesianRectangle<double>? _scaleStartBounds;
  CartesianRectangle<double> _currentBounds;

  Bounds({required CartesianRectangle<double> maxBounds})
      : _maxBounds = maxBounds,
        _currentBounds = maxBounds;

  CartesianRectangle<double> get rect => _currentBounds;

  Bounds startScale() => this.._scaleStartBounds = _currentBounds;

  Bounds scale(double scale, Point<double> focalPoint) {
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

    return this
      .._currentBounds = CartesianRectangle.fromBLWH(
          bottomLeft: bottomLeft, width: newWidth, height: newHeight);
  }

  Bounds endScale() => this.._scaleStartBounds = null;
}
