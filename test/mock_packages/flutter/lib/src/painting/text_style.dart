import 'package:flutter/foundation.dart';

@immutable
class TextStyle {
  final bool inherit;
  final double fontSize;

  const TextStyle({
    this.inherit: true,
    this.fontSize,
  });
}
