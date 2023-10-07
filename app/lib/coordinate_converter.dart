import 'dart:math';
import 'dart:ui';
import 'package:slider_app/affine.dart';
import 'package:vector_math/vector_math.dart';

class CoordinateConverter {
  AffineTransform _additionalTransform = AffineTransform.identity();
  final Size _chartSize;

  CoordinateConverter(Size chartSize) : _chartSize = chartSize;

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
    return _additionalTransform.compose(_getBaseTransform(canvasSize));
  }

  AffineTransform _getBaseTransform(Size canvasSize) {
    var matrix = Matrix2(canvasSize.width / _chartSize.width, 0, 0,
        -canvasSize.height / _chartSize.height);
    var constant = Vector2(0, canvasSize.height);
    return AffineTransform(matrix, constant);
  }
}
