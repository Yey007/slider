import 'dart:math';

import 'package:flutter/material.dart';
import 'package:slider_app/interactive_curves.dart';
import 'bounds.dart';
import 'custom_gesture_detector.dart' as detector;
import 'conversion_extensions.dart';

import 'bezier.dart';
import 'chart_painter.dart';
import 'cartesian_rectangle.dart';

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

  var interactiveCurves = InteractiveCurvesList(curves: [
    BezierCurve(
      start: const Point(0, 0),
      controlPoint1: const Point(0.4, 10),
      controlPoint2: const Point(0.6, 70),
      end: const Point(1, 80),
    )
  ], pointControlRadius: dragRadius);

  var bounds = Bounds(
    maxBounds: const CartesianRectangle<double>(
      Point(0, 0),
      Point(horizontalMax, verticalMax),
    ),
  );

  ({int curveIndex, CurvePointType curvePointType})? selectedPoint;

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
        onPanZoomEnd: onScaleEnd,
        child: CustomPaint(
          painter: ChartPainter(
            theme: Theme.of(context),
            curves: interactiveCurves.curves,
            bounds: bounds.rect,
            controlRadius: controlRadius,
          ),
          key: painterKey,
          child: Container(), // Somehow makes this expand correctly
        ),
      ),
    );
  }

  onDragStart(detector.DragStartDetails details) {
    var chartSpace = transformPointToChartSpace(
        details.localPosition.toPoint(), getPainter().size, bounds.rect);
    setState(() {
      interactiveCurves.startDrag(chartSpace);
    });
  }

  onDragUpdate(detector.DragUpdateDetails details) {
    // TODO: this is a pan
    if (!interactiveCurves.dragging) {
      return;
    }

    var chartSpace = transformPointToChartSpace(
        details.localPosition.toPoint(), getPainter().size, bounds.rect);

    setState(() {
      interactiveCurves.updateDrag(chartSpace);
    });
  }

  onDragEnd() {
    setState(() {
      interactiveCurves.endDrag();
    });
  }

  onScaleStart(detector.PanZoomStartDetails details) {
    setState(() {
      bounds.startScale();
    });
  }

  onScaleUpdate(detector.PanZoomUpdateDetails details) {
    setState(() {
      // for some reason, the position from the event is not always accurate, so we use a mouseRegion.
      var focalPoint = transformPointToChartSpace(
          mousePos.toPoint(), getPainter().size, bounds.rect);
      bounds.scale(details.scale, focalPoint);
    });
  }

  onScaleEnd(detector.PanZoomEndDetails details) {
    setState(() {
      bounds.endScale();
    });
  }

  RenderBox getPainter() {
    var painter = painterKey.currentContext!.findRenderObject() as RenderBox;
    return painter;
  }
}
