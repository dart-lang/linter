// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:linter/src/util/unicode_utils.dart';
import 'package:test/test.dart';

void main() {
  group('unicode_utils', () {
    /// , , , U+202D, U+202E, U+2066, U+2067, U+2068, U+2069.
    test('unsafe', () {
      for (var c in [
        '‪', // U+202A
        '‫', // U+202B
        '‬', // U+202C
        '‭', // U+202D
        '‮', // U+202E
        '⁦', // U+2066
        '⁧', // U+2067
        '⁨', // U+2068
        '⁩', // U+2069
      ]) {
        var units = c.codeUnits;
        expect(units.length, 1);
        expect(unsafe(units.first), isTrue);
      }
    });

    test('safe', () {
      for (var c in [
        '', // U+000A
        '*',
        '→',
        '∑',
      ]) {
        var units = c.codeUnits;
        expect(units.length, 1);
        expect(unsafe(units.first), isFalse);
      }
    });
  });
}
