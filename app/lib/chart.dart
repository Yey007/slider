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
  ]);

  var bounds = Bounds(
    maxBounds: const CartesianRectangle<double>(
      Point(0, 0),
      Point(horizontalMax, verticalMax),
    ),
  );

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
    var painter = getPainter();
    var position = details.localPosition.toPoint();
    var chartSpace = position.toChartSpace(painter.size, bounds.rect);

    var ref = interactiveCurves.getClosestPoint(chartSpace);

    var closestScreenSpace = interactiveCurves[ref].toScreenSpace(
      painter.size,
      bounds.rect,
    );

    if (position.distanceTo(closestScreenSpace) < dragRadius) {
      setState(() {
        interactiveCurves.startDrag(ref);
      });
    } else {
      setState(() {
        bounds.startPan(chartSpace);
      });
    }
  }

  onDragUpdate(detector.DragUpdateDetails details) {
    var chartSpace = details.localPosition
        .toPoint()
        .toChartSpace(getPainter().size, bounds.rect);

    if (interactiveCurves.dragging) {
      setState(() {
        interactiveCurves.continueDrag(chartSpace);
      });
    } else {
      // print(chartSpace);
      setState(() {
        bounds.continuePan(chartSpace);
      });
    }
  }

  onDragEnd() {
    if (interactiveCurves.dragging) {
      setState(() {
        interactiveCurves.endDrag();
      });
    } else {
      setState(() {
        bounds.endPan();
      });
    }
  }

  onScaleStart(detector.PanZoomStartDetails details) {
    setState(() {
      bounds.startScale();
    });
  }

  onScaleUpdate(detector.PanZoomUpdateDetails details) {
    setState(() {
      // for some reason, the position from the event is not always accurate, so we use a mouseRegion.
      var focalPoint =
          mousePos.toPoint().toChartSpace(getPainter().size, bounds.rect);
      bounds.continueScale(details.scale, focalPoint);
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
