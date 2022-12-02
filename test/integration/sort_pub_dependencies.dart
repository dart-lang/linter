// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/src/lint/io.dart';
import 'package:linter/src/cli.dart' as cli;
import 'package:test/test.dart';

import '../mocks.dart';
import '../test_constants.dart';

void main() {
  group('sort_pub_dependencies', () {
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

    test('check order', () async {
      await cli.run([
        '$integrationTestDir/sort_pub_dependencies',
        '--rules=sort_pub_dependencies',
      ]);
      expect(
          collectingOut.trim(),
          stringContainsInOrder([
            'pubspec.yaml 19:3',
            'pubspec.yaml 26:3',
            'pubspec.yaml 33:3',
            '1 file analyzed, 3 issues found',
          ]));
      expect(exitCode, 1);
    });
  });
}
