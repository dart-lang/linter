// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/src/lint/io.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/cli.dart' as cli;
import 'package:linter/src/rules/weak_mode_unnecessary_null_checks.dart';
import 'package:test/test.dart';

import '../mocks.dart';

void main() {
  group('weak_mode_unnecessary_null_checks', () {
    final currentOut = outSink;
    final collectingOut = CollectingSink();

    setUp(() {
      exitCode = 0;
      outSink = collectingOut;
    });

    tearDown(() {
      collectingOut.buffer.clear();
      outSink = currentOut;
      exitCode = 0;
    });

    test('weak_mode_unnecessary_null_checks', () async {
      await cli.runLinter(
        [
          'test/_data/weak_mode_unnecessary_null_checks',
          '--rules=weak_mode_unnecessary_null_checks',
        ],
        LinterOptions(
          [WeakModeUnnecessaryNullChecks()],
          File('test/_data/weak_mode_unnecessary_null_checks/analysis_options.yaml')
              .readAsStringSync(),
        ),
      );
      expect(
          collectingOut.trim(),
          stringContainsInOrder([
            'opted_out.dart 11:5 [lint] Unnecessary null check for non-nullable value.',
            'opted_out.dart 12:5 [lint] Unnecessary null check for non-nullable value.',
            'opted_out.dart 14:3 [lint] Unnecessary null check for non-nullable value.',
            'opted_out.dart 15:3 [lint] Unnecessary null check for non-nullable value.',
            'opted_out.dart 16:3 [lint] Unnecessary null check for non-nullable value.',
            'opted_out.dart 17:3 [lint] Unnecessary null check for non-nullable value.',
            'opted_out.dart 32:7 [lint] Unnecessary null check for non-nullable value.',
            'opted_out.dart 35:9 [lint] Unnecessary null check for non-nullable value.',
            'opted_out.dart 38:11 [lint] Unnecessary null check for non-nullable value.',
            '2 files analyzed, 9 issues found',
          ]));
      expect(exitCode, 1);
    });
  });
}
