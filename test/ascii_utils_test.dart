// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:linter/src/util/ascii_utils.dart';
import 'package:test/test.dart';

import '../test/utils_test.dart' as utils_test;

final badFileNames = utils_test.badFileNames;
final goodFileNames = utils_test.goodFileNames;

main() {
  group('fileNames', () {
    group('good', () {
      for (var name in goodFileNames) {
        test(name, () {
          expect(isValidFileName(name), isTrue);
        });
      }
    });
    group('bad', () {
      for (var name in badFileNames) {
        test(name, () {
          expect(isValidFileName(name), isFalse);
        });
      }
    });
  });
}
