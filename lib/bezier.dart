import 'dart:math';
import 'dart:ui';

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
}

enum CurvePointType {
  start,
  end,
  controlPoint1,
  controlPoint2,
}

BezierCurve transformCurveToScreenSpace(
    BezierCurve curve, Size screenSize, Rect bounds) {
  transformPoint(Point point) {
    return transformPointToScreenSpace(point, screenSize, bounds);
  }

  return BezierCurve(
    start: transformPoint(curve.start),
    end: transformPoint(curve.end),
    controlPoint1: transformPoint(curve.controlPoint1),
    controlPoint2: transformPoint(curve.controlPoint2),
  );
}

Point<double> transformPointToScreenSpace(
    Point point, Size screenSize, Rect bounds) {
  var x = (point.x - bounds.left) / bounds.width * screenSize.width;
  var y = (bounds.height - (point.y - bounds.top)) /
      bounds.height *
      screenSize.height;
  return Point(x, y);
}

Point<double> transformPointToChartSpace(
    Point point, Size screenSize, Rect bounds) {
  var x = point.x / screenSize.width * bounds.width + bounds.left;
  var y =
      -point.y / screenSize.height * bounds.height + bounds.top + bounds.height;
  return Point(x, y);
}
