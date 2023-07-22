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

BezierCurve transformCurveToScreenSpace(BezierCurve curve, Size screenSize,
    double horizontalMax, double verticalMax) {
  transformPoint(Point point) {
    var x = point.x / horizontalMax * screenSize.width;
    var y = (verticalMax - point.y) / verticalMax * screenSize.height;
    return Point(x, y);
  }

  return BezierCurve(
    start: transformPoint(curve.start),
    end: transformPoint(curve.end),
    controlPoint1: transformPoint(curve.controlPoint1),
    controlPoint2: transformPoint(curve.controlPoint2),
  );
}

Point<double> transformPointToScreenSpace(
    Point point, Size screenSize, double horizontalMax, double verticalMax) {
  var x = point.x / horizontalMax * screenSize.width;
  var y = (verticalMax - point.y) / verticalMax * screenSize.height;
  return Point(x, y);
}

Point<double> transformPointToChartSpace(
    Point point, Size screenSize, double horizontalMax, double verticalMax) {
  var x = point.x / screenSize.width * horizontalMax;
  var y = verticalMax * (1 - point.y / screenSize.height);
  return Point(x, y);
}
