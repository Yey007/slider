import 'dart:math';
import 'dart:ui';

import 'cartesian_rectangle.dart';
import 'conversion_extensions.dart';

class BezierCurve {
  Point<double> start;
  Point<double> end;
  Point<double> controlPoint1;
  Point<double> controlPoint2;

  BezierCurve({
    required this.start,
    required this.end,
    required this.controlPoint1,
    required this.controlPoint2,
  });

  operator [](CurvePointType point) {
    switch (point) {
      case CurvePointType.start:
        return start;
      case CurvePointType.end:
        return end;
      case CurvePointType.controlPoint1:
        return controlPoint1;
      case CurvePointType.controlPoint2:
        return controlPoint2;
    }
  }

  operator []=(CurvePointType point, Point<double> value) {
    switch (point) {
      case CurvePointType.start:
        start = value;
        break;
      case CurvePointType.end:
        end = value;
        break;
      case CurvePointType.controlPoint1:
        controlPoint1 = value;
        break;
      case CurvePointType.controlPoint2:
        controlPoint2 = value;
        break;
    }
  }

  BezierCurve toScreenSpace(Size screenSize, CartesianRectangle bounds) {
    transformPoint(Point<double> point) {
      return point.toScreenSpace(screenSize, bounds);
    }

    return BezierCurve(
      start: transformPoint(start),
      end: transformPoint(end),
      controlPoint1: transformPoint(controlPoint1),
      controlPoint2: transformPoint(controlPoint2),
    );
  }
}

enum CurvePointType {
  start,
  end,
  controlPoint1,
  controlPoint2,
}
