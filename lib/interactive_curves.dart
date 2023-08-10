import 'dart:math';

import 'package:slider_app/bezier.dart';

typedef CurvePointReference = ({int curveIndex, CurvePointType pointType});

class InteractiveCurvesList {
  final List<BezierCurve> _curves;
  CurvePointReference? _selectedPoint;

  InteractiveCurvesList({required List<BezierCurve> curves}) : _curves = curves;

  bool get dragging => _selectedPoint != null;
  Iterable<BezierCurve> get curves => _curves;

  void startDrag(CurvePointReference touchPoint) => _selectedPoint = touchPoint;

  void continueDrag(Point<double> dragPoint) {
    if (_selectedPoint == null) {
      throw Exception('startDrag must be called before continuing a drag.');
    }

    _curves[_selectedPoint!.curveIndex][_selectedPoint!.pointType] = dragPoint;
  }

  void endDrag() => _selectedPoint = null;

  CurvePointReference getClosestPoint(Point<double> touchPoint) {
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
          distance: distance,
        ));
      }
    }

    var min = withDistance.reduce((value, element) =>
        value.distance < element.distance ? value : element);

    return min.ref;
  }

  Point<double> operator [](CurvePointReference reference) =>
      _curves[reference.curveIndex][reference.pointType];
}
