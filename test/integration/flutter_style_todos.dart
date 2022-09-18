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
  group('flutter_style_todos', () {
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

    test('on bad TODOs', () async {
      await cli.run([
        '$integrationTestDir/flutter_style_todos',
        '--rules=flutter_style_todos'
      ]);
      expect(
          collectingOut.trim(),
          stringContainsInOrder([
            'a.dart 8:1',
            'a.dart 9:1',
            'a.dart 10:1',
            'a.dart 11:1',
            'a.dart 12:1',
            'a.dart 13:1',
            'a.dart 14:1',
            'a.dart 15:1',
            'a.dart 16:1',
            'a.dart 17:1',
            'a.dart 18:1',
            '1 file analyzed, 11 issues found, in'
          ]));
      expect(exitCode, 1);
    });
  });
}
