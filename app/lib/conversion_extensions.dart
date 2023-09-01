import 'dart:math';

import 'package:flutter/material.dart';

import 'cartesian_rectangle.dart';

extension ToPoint on Offset {
  Point<double> toPoint() => Point(dx, dy);
}

extension ToOffset on Point<double> {
  Offset toOffset() => Offset(x, y);
}

extension SpaceTransform on Point<double> {
  Point<double> toScreenSpace(Size screenSize, CartesianRectangle bounds) {
    var x = (this.x - bounds.left) * (screenSize.width / bounds.width);
    var y = screenSize.height -
        (this.y - bounds.bottom) * (screenSize.height / bounds.height);
    return Point(x, y);
  }

  Point<double> toChartSpace(Size screenSize, CartesianRectangle bounds) {
    var x = this.x * (bounds.width / screenSize.width) + bounds.left;
    var y =
        -(this.y - screenSize.height) * (bounds.height / screenSize.height) +
            bounds.bottom;
    return Point(x, y);
  }
}
