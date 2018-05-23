import 'package:flutter/foundation.dart';

class EdgeInsets extends EdgeInsetsGeometry {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const EdgeInsets.all(double value)
      : left = value,
        top = value,
        right = value,
        bottom = value;

  const EdgeInsets.fromLTRB(this.left, this.top, this.right, this.bottom);

  const EdgeInsets.only(
      {this.left: 0.0, this.top: 0.0, this.right: 0.0, this.bottom: 0.0});

  const EdgeInsets.symmetric({double vertical: 0.0, double horizontal: 0.0})
      : left = horizontal,
        top = vertical,
        right = horizontal,
        bottom = vertical;
}

@immutable
abstract class EdgeInsetsGeometry {
  const EdgeInsetsGeometry();
}
