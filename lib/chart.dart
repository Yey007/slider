import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:slider_app/bounds.dart';
import 'package:slider_app/custom_gesture_recognizer.dart';
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

  var curves = [
    BezierCurve(
      start: const Point(0, 0),
      controlPoint1: const Point(0.4, 10),
      controlPoint2: const Point(0.6, 70),
      end: const Point(1, 80),
    )
  ];

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
      child: CustomGestureRecognizer(
        onDragStart: onDragStart,
        onDragUpdate: onDragUpdate,
        onDragEnd: onDragEnd,
        onPanZoomStart: onScaleStart,
        onPanZoomUpdate: onScaleUpdate,
        child: CustomPaint(
          painter: ChartPainter(
            theme: Theme.of(context),
            curves: curves,
            bounds: bounds.rect,
            controlRadius: controlRadius,
          ),
          key: painterKey,
          child: Container(), // Somehow makes this expand correctly
        ),
      ),
    );
  }

  onDragStart(PointerMoveEvent details) {
    var min = getClosestPoint(details.localPosition.toPoint());

    if (min.distance < dragRadius) {
      setState(() {
        selectedPoint =
            (curveIndex: min.curveIndex, curvePointType: min.pointType);
      });
    }
  }

  onDragUpdate(PointerMoveEvent details) {
    // TODO: this is a pan
    if (selectedPoint == null) return;

    var newPos = details.localPosition;
    var painter = getPainter();

    if (!painter.paintBounds.deflate(10.0).contains(newPos)) return;

    var chartSpace =
        transformPointToChartSpace(newPos.toPoint(), painter.size, bounds.rect);

    setState(() {
      curves[selectedPoint!.curveIndex][selectedPoint!.curvePointType] =
          chartSpace;
    });
  }

  onDragEnd() {
    setState(() {
      selectedPoint = null;
    });
  }

  onScaleStart(PointerPanZoomStartEvent details) {
    setState(() {
      bounds.startScale();
    });
  }

  onScaleUpdate(PointerPanZoomUpdateEvent details) {
    setState(() {
      // for some reason, the position from the event is not always accurate, so we use a mouseRegion.
      var focalPoint = transformPointToChartSpace(
          mousePos.toPoint(), getPainter().size, bounds.rect);
      bounds.scale(details.scale, focalPoint);
    });
  }

  onScaleEnd(PointerPanZoomEndEvent details) {
    setState(() {
      bounds.endScale();
    });
  }

  RenderBox getPainter() {
    var painter = painterKey.currentContext!.findRenderObject() as RenderBox;
    return painter;
  }

  ({int curveIndex, double distance, CurvePointType pointType}) getClosestPoint(
      Point<double> tapPoint) {
    var screenSpace = curves.map(
        (e) => transformCurveToScreenSpace(e, getPainter().size, bounds.rect));
    var withIndex = screenSpace.toList().asMap().entries.map((e) => (
          index: e.key,
          curve: e.value,
        ));
    var points = withIndex.expand((e) => [
          (
            curve: e.curve,
            curveIndex: e.index,
            pointType: CurvePointType.start
          ),
          (curve: e.curve, curveIndex: e.index, pointType: CurvePointType.end),
          (
            curve: e.curve,
            curveIndex: e.index,
            pointType: CurvePointType.controlPoint1
          ),
          (
            curve: e.curve,
            curveIndex: e.index,
            pointType: CurvePointType.controlPoint2
          ),
        ]);
    var withDistance = points.map((e) => (
          curveIndex: e.curveIndex,
          pointType: e.pointType,
          distance: tapPoint.distanceTo(e.curve[e.pointType]),
        ));
    var min = withDistance.reduce((value, element) =>
        value.distance < element.distance ? value : element);

    return min;
  }
}
