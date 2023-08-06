import 'dart:math';

import 'package:slider_app/cartesian_rectangle.dart';

class Bounds {
  final CartesianRectangle<double> maxBounds;
  CartesianRectangle<double>? scaleStartBounds;
  CartesianRectangle<double> currentBounds;

  Bounds({required this.maxBounds}) : currentBounds = maxBounds;

  CartesianRectangle<double> get rect => currentBounds;

  startScale() {
    scaleStartBounds = currentBounds;
  }

  scale(double scale, Point<double> focalPoint) {
    if (scaleStartBounds == null) {
      throw Exception('startScale must be called before attempting a scale.');
    }

    var startBoundsWidth = scaleStartBounds!.width;
    var startBoundsHeight = scaleStartBounds!.height;

    var newWidth = startBoundsWidth / scale;
    var newHeight = startBoundsHeight / scale;

    // keep focal point in the same place in chart space
    // for some reason, the position from the event is not always accurate, so we use a mouseRegion.
    var startFocalDelta = focalPoint - scaleStartBounds!.bottomLeft;
    var bottomLeft = Point(
      focalPoint.x - (startFocalDelta.x / startBoundsWidth * newWidth),
      focalPoint.y - (startFocalDelta.y / startBoundsHeight * newHeight),
    );

    currentBounds = CartesianRectangle.fromBLWH(
        bottomLeft: bottomLeft, width: newWidth, height: newHeight);
  }

  endScale() {
    scaleStartBounds = null;
  }
}
