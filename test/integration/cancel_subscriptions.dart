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
  group('cancel_subscriptions', () {
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

    test('cancel subscriptions', () async {
      await cli.run([
        '$integrationTestDir/cancel_subscriptions',
        '--rules=cancel_subscriptions'
      ]);
      expect(
          collectingOut.trim(),
          stringContainsInOrder([
            'StreamSubscription _subscriptionA; // LINT',
            'StreamSubscription _subscriptionF; // LINT',
            '2 files analyzed, 3 issues found, in'
          ]));
      expect(exitCode, 1);
    });
  });
}
