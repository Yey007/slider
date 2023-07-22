import 'dart:math';

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

  ({int curveIndex, CurvePointType curvePointType})? selectedPoint;

  final painterKey = GlobalKey();

  RenderBox getPainter() {
    var painter = painterKey.currentContext!.findRenderObject() as RenderBox;
    return painter;
  }

  ({int curveIndex, double distance, CurvePointType pointType}) getClosestPoint(
      Point<double> tapPoint) {
    var screenSpace = curves.map((e) => transformCurveToScreenSpace(
        e, getPainter().size, horizontalMax, verticalMax));
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => setState(() {
        var min = getClosestPoint(details.localPosition.toPoint());

        if (min.distance < dragRadius) {
          selectedPoint =
              (curveIndex: min.curveIndex, curvePointType: min.pointType);
        }
      }),
      onPanUpdate: (details) => setState(() {
        if (selectedPoint == null) return;

        // not adding delta seems to be considerably smoother
        var newPos = details.localPosition;
        var painter = getPainter();

        if (!painter.paintBounds.deflate(10.0).contains(newPos)) return;

        curves[selectedPoint!.curveIndex][selectedPoint!.curvePointType] =
            transformPointToChartSpace(
                newPos.toPoint(), painter.size, horizontalMax, verticalMax);
      }),
      onPanEnd: (details) => setState(() {
        selectedPoint = null;
      }),
      child: CustomPaint(
        painter: ChartPainter(
          theme: Theme.of(context),
          curves: curves,
          horizontalMax: horizontalMax,
          verticalMax: verticalMax,
          controlRadius: controlRadius,
        ),
        key: painterKey,
        child: Container(), // Somehow makes this expand correctly
      ),
    );
  }
}
