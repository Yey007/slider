import 'dart:math';

import 'package:flutter/material.dart';
import 'package:slider_app/bezier.dart';
import 'package:slider_app/conversion_extensions.dart';

class ChartPainter extends CustomPainter {
  ThemeData theme;

  List<BezierCurve> curves;

  int horizontalDivisions;
  int verticalDivisions;
  double horizontalMax;
  double verticalMax;
  double controlRadius;

  ChartPainter({
    required this.theme,
    required this.curves,
    required this.horizontalMax,
    required this.verticalMax,
    required this.horizontalDivisions,
    required this.verticalDivisions,
    required this.controlRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    var mainPaint = Paint()
      ..color = theme.colorScheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    var divisionPaint = Paint()
      ..color = theme.colorScheme.secondary
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // draw axes
    var origin = Offset(0, size.height);
    canvas.drawLine(Offset.zero, origin, mainPaint);
    canvas.drawLine(origin, Offset(size.width, size.height), mainPaint);

    var horizontalDivisionSize = size.width / horizontalDivisions;
    var verticalDivisionSize = size.height / verticalDivisions;

    for (var i = 1; i < horizontalDivisions; i++) {
      var x = i * horizontalDivisionSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), divisionPaint);
    }

    for (var i = 1; i < verticalDivisions; i++) {
      var y = i * verticalDivisionSize;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), divisionPaint);
    }

    curves = curves
        .map((c) =>
            transformCurveToScreenSpace(c, size, horizontalMax, verticalMax))
        .toList();

    for (var curve in curves) {
      _drawCurve(curve, canvas, mainPaint);
    }

    for (var curve in curves) {
      _drawPoint(curve.start, canvas, mainPaint);
      _drawPoint(curve.end, canvas, mainPaint);
      _drawControlPoint(curve.controlPoint1, curve.start, canvas, mainPaint);
      _drawControlPoint(curve.controlPoint2, curve.end, canvas, mainPaint);
    }
  }

  void _drawCurve(BezierCurve curve, Canvas canvas, Paint paint) {
    var path = Path()
      ..moveTo(curve.start.x, curve.start.y)
      ..cubicTo(
        curve.controlPoint1.x,
        curve.controlPoint1.y,
        curve.controlPoint2.x,
        curve.controlPoint2.y,
        curve.end.x,
        curve.end.y,
      );

    canvas.drawPath(path, paint);
  }

  void _drawPoint(Point<double> point, Canvas canvas, Paint paint) {
    canvas.drawCircle(point.toOffset(), controlRadius, paint);
  }

  void _drawControlPoint(Point<double> controlPoint,
      Point<double> relatedEndpoint, Canvas canvas, Paint paint) {
    var r = controlRadius;
    canvas.drawCircle(controlPoint.toOffset(), r, paint);

    var k = pow(controlPoint.x - relatedEndpoint.x, 2) +
        pow(controlPoint.y - relatedEndpoint.y, 2);

    var t0 = (2 * k + sqrt(4 * k * k - 4 * k * (k - r * r))) / (2 * k);
    var t1 = (2 * k - sqrt(4 * k * k - 4 * k * (k - r * r))) / (2 * k);

    double t;
    if (t0 < 1) {
      t = t0;
    } else if (t1 < 1) {
      t = t1;
    } else {
      return;
    }

    var x = (controlPoint.x - relatedEndpoint.x) * t + relatedEndpoint.x;
    var y = (controlPoint.y - relatedEndpoint.y) * t + relatedEndpoint.y;

    canvas.drawLine(
      relatedEndpoint.toOffset(),
      Offset(x, y),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // for now
    return true;
  }
}
