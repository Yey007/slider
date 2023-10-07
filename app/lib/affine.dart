import 'package:vector_math/vector_math.dart';

class AffineTransform {
  final Matrix2 _matrix;
  final Vector2 _constant;

  AffineTransform(Matrix2 matrix, Vector2 constant)
      : _matrix = matrix,
        _constant = constant;

  Vector2 apply(Vector2 vector) {
    return _matrix * vector + _constant;
  }

  AffineTransform compose(AffineTransform other) {
    return AffineTransform(
        _matrix * other._matrix, _matrix * other._constant + _constant);
  }

  AffineTransform then(AffineTransform other) {
    return other.compose(this);
  }

  AffineTransform inverse() {
    var inverse = Matrix2.zero()..copyInverse(_matrix);
    return AffineTransform(inverse, -inverse * _constant);
  }

  factory AffineTransform.identity() {
    return AffineTransform(Matrix2.identity(), Vector2.zero());
  }
}
