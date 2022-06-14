// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/src/lint/io.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/cli.dart' as cli;
import 'package:path/path.dart';
import 'package:test/test.dart';

import '../mocks.dart';
import '../test_constants.dart';

void main() {
  group('no_top_public_members_in_executable_libraries', () {
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

    test('detects lints', () async {
      await cli.runLinter([
        '$integrationTestDir/no_top_public_members_in_executable_libraries',
        '--rules=no_top_public_members_in_executable_libraries',
      ], LinterOptions());
      var files = Directory(
              '$integrationTestDir/no_top_public_members_in_executable_libraries')
          .listSync()
          .whereType<File>()
          .toList();
      var lintsByFile = <File, List<int>>{
        for (var file in files)
          file: file
              .readAsLinesSync()
              .asMap()
              .entries
              .where((e) => e.value.endsWith('// LINT'))
              .map((e) => e.key + 1)
              .toList()
      };
      expect(
        collectingOut.trim(),
        stringContainsInOrder([
          for (var entry in lintsByFile.entries) ...[
            for (var line in entry.value) '${basename(entry.key.path)} $line:',
          ],
          '${lintsByFile.length} file${lintsByFile.length == 1 ? '' : 's'} analyzed, ${lintsByFile.values.expand((e) => e).length} issues found, in',
        ]),
      );
      expect(exitCode, lintsByFile.values.expand((e) => e).isEmpty ? 0 : 1);
    });
  });
}
