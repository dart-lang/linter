// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/src/lint/io.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/cli.dart' as cli;
import 'package:test/test.dart';

import '../mocks.dart';
import '../test_constants.dart';

void main() {
  group('prefer_const_constructors', () {
    var currentOut = outSink;
    var collectingOut = CollectingSink();
    setUp(() {
      exitCode = 0;
      outSink = collectingOut;
    });
    tearDown(() {
      collectingOut.buffer.clear();
      outSink = currentOut;
      exitCode = 0;
    });

    test('respect deferred imports', () async {
      await cli.runLinter([
        '$integrationTestDir/prefer_const_constructors',
        '--rules=prefer_const_constructors',
        '--packages',
        '$ruleTestDir/.mock_packages',
      ], LinterOptions());
      expect(
          collectingOut.trim(),
          stringContainsInOrder(
              ['var b = B();', '2 files analyzed, 1 issue found']));
      expect(exitCode, 1);
    });
  });
}
