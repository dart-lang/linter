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
  group('always depend on packages you use', () {
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

    test('lints files under bin', () async {
      var packagesFilePath = File('.packages').absolute.path;
      await cli.run([
        '--packages',
        packagesFilePath,
        '$integrationTestDir/always_depend_on_packages_you_use/bin',
        '--rules=always_depend_on_packages_you_use'
      ]);
      expect(
          collectingOut.trim(),
          stringContainsInOrder([
            "Depend on packages you use.",
            "import 'package:test/test.dart'; // LINT",
            "Depend on packages you use.",
            "import 'package:matcher/matcher.dart'; // LINT",
            "Depend on packages you use.",
            "export 'package:test/test.dart'; // LINT",
            "Depend on packages you use.",
            "export 'package:matcher/matcher.dart'; // LINT",
          ]));
      expect(exitCode, 1);
    });

    test('lints files under lib', () async {
      var packagesFilePath = File('.packages').absolute.path;
      await cli.run([
        '--packages',
        packagesFilePath,
        '$integrationTestDir/always_depend_on_packages_you_use/lib',
        '--rules=always_depend_on_packages_you_use'
      ]);
      expect(
          collectingOut.trim(),
          stringContainsInOrder([
            "Depend on packages you use.",
            "import 'package:test/test.dart'; // LINT",
            "Depend on packages you use.",
            "import 'package:matcher/matcher.dart'; // LINT",
            "Depend on packages you use.",
            "export 'package:test/test.dart'; // LINT",
            "Depend on packages you use.",
            "export 'package:matcher/matcher.dart'; // LINT",
          ]));
      expect(exitCode, 1);
    });

    test('lints files under test', () async {
      var packagesFilePath = File('.packages').absolute.path;
      await cli.run([
        '--packages',
        packagesFilePath,
        '$integrationTestDir/always_depend_on_packages_you_use/test',
        '--rules=always_depend_on_packages_you_use'
      ]);
      expect(
          collectingOut.trim(),
          stringContainsInOrder([
            "Depend on packages you use.",
            "import 'package:matcher/matcher.dart'; // LINT",
            "Depend on packages you use.",
            "export 'package:matcher/matcher.dart'; // LINT",
          ]));
      expect(exitCode, 1);
    });
  });
}
