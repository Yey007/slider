import 'dart:math';

import 'package:flutter/material.dart';
import 'package:slider_app/bezier.dart';
import 'package:slider_app/conversion_extensions.dart';

import 'cartesian_rectangle.dart';

class ChartPainter extends CustomPainter {
  ThemeData theme;
  Iterable<BezierCurve> curves;
  CartesianRectangle bounds;
  double controlRadius;

  ChartPainter({
    required this.theme,
    required this.curves,
    required this.bounds,
    required this.controlRadius,
  });

  @override
  paint(Canvas canvas, Size size) {
    // idea: use canvas transform functions to handle zoom and stuff instead
    // of doing it ourselves. Will require using inverse transform to get
    // back proper coordinates, i imagine.
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    var mainPaint = Paint()
      ..color = theme.colorScheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // draw axes
    var origin = Offset(0, size.height);
    canvas.drawLine(Offset.zero, origin, mainPaint);
    canvas.drawLine(origin, Offset(size.width, size.height), mainPaint);

    curves = curves.map((c) => c.toScreenSpace(size, bounds)).toList();

    for (var curve in curves) {
      drawCurve(curve, canvas, mainPaint);
    }

    for (var curve in curves) {
      drawPoint(curve.start, canvas, mainPaint);
      drawPoint(curve.end, canvas, mainPaint);
      drawControlPoint(curve.controlPoint1, curve.start, canvas, mainPaint);
      drawControlPoint(curve.controlPoint2, curve.end, canvas, mainPaint);
    }
  }

  drawCurve(BezierCurve curve, Canvas canvas, Paint paint) {
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

  drawPoint(Point<double> point, Canvas canvas, Paint paint) {
    canvas.drawCircle(point.toOffset(), controlRadius, paint);
  }

  drawControlPoint(Point<double> controlPoint, Point<double> relatedEndpoint,
      Canvas canvas, Paint paint) {
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
