import 'dart:math';

import 'package:flutter/material.dart';

extension ToPoint on Offset {
  Point<double> toPoint() => Point(dx, dy);
}

extension ToOffset on Point<double> {
  Offset toOffset() => Offset(x, y);
}
