import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
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

  var curves = [
    BezierCurve(
      start: const Point(0, 0),
      controlPoint1: const Point(0.4, 10),
      controlPoint2: const Point(0.6, 70),
      end: const Point(1, 80),
    )
  ];

  var bounds = const Rect.fromLTWH(0, 0, horizontalMax, verticalMax);

  ({int curveIndex, CurvePointType curvePointType})? selectedPoint;

  final painterKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (details) => {
        if (details.pointerCount == 1)
          onPanStart(details)
        else
          onScaleStart(details)
      },
      onScaleUpdate: (details) => {
        if (details.pointerCount == 1)
          onPanUpdate(details)
        else
          onScaleUpdate(details)
      },
      onScaleEnd: (details) => {if (selectedPoint != null) onPanEnd()},
      child: CustomPaint(
        painter: ChartPainter(
          theme: Theme.of(context),
          curves: curves,
          bounds: bounds,
          controlRadius: controlRadius,
        ),
        key: painterKey,
        child: Container(), // Somehow makes this expand correctly
      ),
    );
  }

  onPanStart(ScaleStartDetails details) {
    var min = getClosestPoint(details.localFocalPoint.toPoint());

    if (min.distance < dragRadius) {
      setState(() {
        selectedPoint =
            (curveIndex: min.curveIndex, curvePointType: min.pointType);
      });
    }
  }

  onPanUpdate(ScaleUpdateDetails details) {
    if (selectedPoint == null) return;

    // not adding delta seems to be considerably smoother
    var newPos = details.localFocalPoint;
    var painter = getPainter();

    if (!painter.paintBounds.deflate(10.0).contains(newPos)) return;

    var chartSpace =
        transformPointToChartSpace(newPos.toPoint(), painter.size, bounds);

    setState(() {
      curves[selectedPoint!.curveIndex][selectedPoint!.curvePointType] =
          chartSpace;
    });
  }

  onPanEnd() {
    setState(() {
      selectedPoint = null;
    });
  }

  onScaleStart(ScaleStartDetails details) {}

  onScaleUpdate(ScaleUpdateDetails details) {}

  RenderBox getPainter() {
    var painter = painterKey.currentContext!.findRenderObject() as RenderBox;
    return painter;
  }

  ({int curveIndex, double distance, CurvePointType pointType}) getClosestPoint(
      Point<double> tapPoint) {
    var screenSpace = curves
        .map((e) => transformCurveToScreenSpace(e, getPainter().size, bounds));
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
