import 'dart:math';
import 'dart:ui';
import 'package:slider_app/affine.dart';
import 'package:vector_math/vector_math.dart';

class CoordinateConverter {
  // Important to keep in mind that _additionalTransform happens when points are in "pseudo-screen space"
  AffineTransform _additionalTransform = AffineTransform.identity();
  final Size _chartSize;

  double _previousScale = 1;
  Offset _previousFocalPoint = Offset.zero;

  CoordinateConverter(Size chartSize) : _chartSize = chartSize;

  void startPanZoom(Offset focalPoint) {
    _previousScale = 1;
    _previousFocalPoint = focalPoint;
  }

  void continuePanZoom(double scale, Offset focalPoint, Size canvasSize) {
    var scaleDelta = scale / _previousScale;
    var pan = focalPoint - _previousFocalPoint;

    var panTransform =
        AffineTransform(Matrix2.identity(), Vector2(pan.dx, pan.dy));

    var shiftFocalToOrigin = AffineTransform(
        Matrix2.identity(), -Vector2(focalPoint.dx, focalPoint.dy));
    var scaleFromOrigin =
        AffineTransform(Matrix2(scaleDelta, 0, 0, scaleDelta), Vector2.zero());
    var scaleTransform = shiftFocalToOrigin
        .then(scaleFromOrigin)
        .then(shiftFocalToOrigin.inverse());

    _additionalTransform =
        _additionalTransform.then(panTransform).then(scaleTransform);

    _previousScale = scale;
    _previousFocalPoint = focalPoint;
  }

  Point<double> toScreenSpace(Point<double> point, Size canvasSize) {
    var result = _getTransform(canvasSize).apply(Vector2(point.x, point.y));
    return Point(result.x, result.y);
  }

  Point<double> toChartSpace(Point<double> point, Size canvasSize) {
    var result =
        _getTransform(canvasSize).inverse().apply(Vector2(point.x, point.y));
    return Point(result.x, result.y);
  }

  AffineTransform _getTransform(Size canvasSize) {
    return _getBaseTransform(canvasSize).then(_additionalTransform);
  }

  AffineTransform _getBaseTransform(Size canvasSize) {
    var matrix = Matrix2(canvasSize.width / _chartSize.width, 0, 0,
        -canvasSize.height / _chartSize.height);
    var constant = Vector2(0, canvasSize.height);
    return AffineTransform(matrix, constant);
  }
}
