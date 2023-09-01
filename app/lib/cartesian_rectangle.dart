import 'dart:math';

import 'package:flutter/material.dart';

/// An immutable rectangle using the standard cartesian coordinate system.
@immutable
class CartesianRectangle<T extends num> {
  final Point<T> _bottomLeft;
  final Point<T> _topRight;

  const CartesianRectangle(Point<T> bottomLeft, Point<T> topRight)
      : _bottomLeft = bottomLeft,
        _topRight = topRight;

  factory CartesianRectangle.fromBLWH({
    required Point<T> bottomLeft,
    required T width,
    required T height,
  }) {
    return CartesianRectangle(bottomLeft, bottomLeft + Point<T>(width, height));
  }

  String toString() {
    return 'CartesianRectangle(bottomLeft: $_bottomLeft, topRight: $_topRight)';
  }

  Point<T> get bottomLeft => _bottomLeft;
  Point<T> get topRight => _topRight;
  Point<T> get topLeft => Point<T>(_bottomLeft.x, _topRight.y);
  Point<T> get bottomRight => Point<T>(_topRight.x, _bottomLeft.y);

  Point<T> get center => Point<T>(
        (_bottomLeft.x + _topRight.x) / 2 as T,
        (_bottomLeft.y + _topRight.y) / 2 as T,
      );

  T get left => _bottomLeft.x;
  T get right => _topRight.x;
  T get top => _topRight.y;
  T get bottom => _bottomLeft.y;

  T get width => (_topRight.x - _bottomLeft.x) as T;
  T get height => (_topRight.y - _bottomLeft.y) as T;
}
