// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
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
  group('avoid_relative_lib_imports', () {
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

    test('avoid relative lib imports', () async {
      await cli.runLinter([
        '$integrationTestDir/avoid_relative_lib_imports',
        '--rules=avoid_relative_lib_imports',
      ], LinterOptions());
      expect(
          collectingOut.trim(),
          stringContainsInOrder(
              ['main.dart 3:8', '2 files analyzed, 1 issue found, in']));
      expect(exitCode, 1);
    });
  });
}
