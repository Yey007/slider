import 'dart:math';

import 'package:slider_app/bezier.dart';

typedef CurvePointReference = ({int curveIndex, CurvePointType pointType});

class InteractiveCurvesList {
  final List<BezierCurve> _curves;
  CurvePointReference? _selectedPoint;

  final double pointControlRadius;

  InteractiveCurvesList(
      {required List<BezierCurve> curves, required this.pointControlRadius})
      : _curves = curves;

  bool get dragging => _selectedPoint != null;
  Iterable<BezierCurve> get curves => _curves;

  /// Starts tracking a drag starting at the given point.
  /// Returns true if the touch point was close enough to a curve point to start
  /// dragging, and false otherwise.
  bool startDrag(Point<double> touchPoint) {
    var closestPoint = _getClosestPoint(touchPoint);
    if (closestPoint.distance < pointControlRadius) {
      _selectedPoint = closestPoint.ref;
      return true;
    } else {
      return false;
    }
  }

  void updateDrag(Point<double> dragPoint) {
    if (_selectedPoint == null) {
      throw Exception('A drag must be started before updating it.');
    }

    _curves[_selectedPoint!.curveIndex][_selectedPoint!.pointType] = dragPoint;
  }

  void endDrag() {
    _selectedPoint = null;
  }

  ({CurvePointReference ref, double distance}) _getClosestPoint(
      Point<double> touchPoint) {
    List<({CurvePointReference ref, double distance})> withDistance = [];
    for (int i = 0; i < _curves.length; i++) {
      var curve = _curves[i];
      for (CurvePointType pointType in CurvePointType.values) {
        var distance = touchPoint.distanceTo(curve[pointType]);
        withDistance.add((
          ref: (
            curveIndex: i,
            pointType: pointType,
          ),
          distance: distance
        ));
      }
    }

    var min = withDistance.reduce((value, element) =>
        value.distance < element.distance ? value : element);

    return min;
  }
}
