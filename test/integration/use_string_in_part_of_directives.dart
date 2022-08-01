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
  group('use_string_in_part_of_directives', () {
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

    test(timeout: Timeout.none, 'works correctly', () async {
      await cli.runLinter([
        '$integrationTestDir/use_string_in_part_of_directives',
        '--rules=use_string_in_part_of_directives',
      ], LinterOptions());
      var files =
          Directory('$integrationTestDir/use_string_in_part_of_directives')
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
      var output = collectingOut.trim();
      for (var entry in lintsByFile.entries) {
        for (var line in entry.value) {
          expect(output, contains('/${basename(entry.key.path)} $line:'));
        }
      }
      var fileCount = lintsByFile.length;
      var issueCount = lintsByFile.values.expand((e) => e).length;
      expect(
        output,
        contains(
          '$fileCount file${fileCount <= 1 ? '' : 's'} analyzed, '
          '$issueCount issue${issueCount <= 1 ? '' : 's'} found, in',
        ),
      );
      expect(exitCode, 1);
    });
  });
}
