// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// String utilities that use underlying ASCII codes for improved performance.
/// Ultimately we should consider carefully when we use RegExps where a simple
/// loop would do (and would do so far more performantly).
/// See: https://github.com/dart-lang/linter/issues/1828
library ascii_utils;

import 'package:charcode/ascii.dart';

/// Return `true` if the given [character] is the ASCII '.' character.
bool isDot(int character) => character == $dot;

/// Return `true` if the given [character] is a lowercase ASCII character.
bool isLowerCase(int character) => character >= $a && character <= $z;

/// Return `true` if the given [character] an ASCII number character.
bool isNumber(int character) => character >= 48 && character <= 57;

/// Return `true` if the given [character] is the ASCII '_' character.
bool isUnderScore(int character) => character == $_;

/// Check if the given [name] is a valid filename.
/// Valid file names are
/// * `lower_snake_case`
/// * limited to valid Dart identifiers, and
/// * may contain `.`s (e.g., to delimit extensions like `foo.dart` or `foo.g.dart`)
bool isValidFileName(String name) {
  var dot = false;
  final length = name.length;
  for (int i = 0; i < length; ++i) {
    final character = name.codeUnitAt(i);
    if (isLowerCase(character) || isUnderScore(character)) {
      dot = false;
    } else {
      if (isNumber(character)) {
        if (i == 0) {
          return false;
        }
        continue;
      }
      if (!dot) {
        dot = isDot(character);
        if (!dot || i == length - 1) {
          return false;
        }
      } else {
        return false;
      }
    }
  }
  return true;
}
