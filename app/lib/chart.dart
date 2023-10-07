import 'dart:math';

import 'package:flutter/material.dart';
import 'package:slider_app/coordinate_converter.dart';
import 'package:slider_app/interactive_curves.dart';
import 'custom_gesture_detector.dart' as detector;
import 'conversion_extensions.dart';

import 'bezier.dart';
import 'chart_painter.dart';

class Chart extends StatefulWidget {
  const Chart({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  static const horizontalMax = 1.0;
  static const verticalMax = 80.0;
  static const controlRadius = 10.0;
  static const dragRadius = 20.0;

  var coordinateConverter =
      CoordinateConverter(const Size(horizontalMax, verticalMax));

  var interactiveCurves = InteractiveCurvesList(curves: [
    BezierCurve(
      start: const Point(0, 0),
      controlPoint1: const Point(0.4, 10),
      controlPoint2: const Point(0.6, 70),
      end: const Point(1, 80),
    )
  ]);

  final painterKey = GlobalKey();
  Offset mousePos = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (event) => setState(() {
        mousePos = event.localPosition;
      }),
      child: detector.CustomGestureDetector(
        onDragStart: onDragStart,
        onDragUpdate: onDragUpdate,
        onDragEnd: onDragEnd,
        onPanZoomStart: onScaleStart,
        onPanZoomUpdate: onScaleUpdate,
        child: CustomPaint(
          painter: ChartPainter(
            theme: Theme.of(context),
            curves: interactiveCurves.curves.map(convertCurveToScreenSpace),
            controlRadius: controlRadius,
          ),
          key: painterKey,
          child: Container(), // Somehow makes this expand correctly
        ),
      ),
    );
  }

  onDragStart(detector.DragStartDetails details) {
    var painter = getPainter();
    var position = details.localPosition.toPoint();
    var chartSpace = coordinateConverter.toChartSpace(position, painter.size);

    var ref = interactiveCurves.getClosestPoint(chartSpace);

    var closestScreenSpace =
        coordinateConverter.toScreenSpace(interactiveCurves[ref], painter.size);

    if (position.distanceTo(closestScreenSpace) < dragRadius) {
      setState(() {
        interactiveCurves.startDrag(ref);
      });
    } else {
      setState(() {
        coordinateConverter.startPanZoom(details.localPosition);
      });
    }
  }

  onDragUpdate(detector.DragUpdateDetails details) {
    var painterSize = getPainter().size;
    var chartSpace = coordinateConverter.toChartSpace(
        details.localPosition.toPoint(), painterSize);

    if (interactiveCurves.dragging) {
      setState(() {
        interactiveCurves.continueDrag(chartSpace);
      });
    } else {
      setState(() {
        coordinateConverter.continuePanZoom(
            1, details.localPosition, painterSize);
      });
    }
  }

  onDragEnd() {
    if (interactiveCurves.dragging) {
      setState(() {
        interactiveCurves.endDrag();
      });
    }
  }

  onScaleStart(detector.PanZoomStartDetails details) {
    setState(() {
      coordinateConverter.startPanZoom(details.localPosition);
    });
  }

  onScaleUpdate(detector.PanZoomUpdateDetails details) {
    setState(() {
      coordinateConverter.continuePanZoom(
          details.scale, details.localPosition, getPainter().size);
    });
  }

  RenderBox getPainter() {
    var painter = painterKey.currentContext!.findRenderObject() as RenderBox;
    return painter;
  }

  BezierCurve convertCurveToScreenSpace(BezierCurve curve) {
    var size = getPainter().size;
    Point<double> transformPoint(Point<double> p) {
      return coordinateConverter.toScreenSpace(p, size);
    }

    return BezierCurve(
        start: transformPoint(curve.start),
        end: transformPoint(curve.end),
        controlPoint1: transformPoint(curve.controlPoint1),
        controlPoint2: transformPoint(curve.controlPoint2));
  }
}
