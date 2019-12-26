// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:linter/src/util/lint_cache.dart';
import 'package:test/test.dart';

Future<void> main() async {
  final lintCache = LintCache();
  await lintCache.init();

  group('@IncompatibleWith', () {
    group('check for (backwards) pointers', () {
      for (var lintDetail in lintCache.details) {
        if (lintDetail.incompatibleRules.isNotEmpty) {
          test(lintDetail.id, () {
            for (var incompatibleRule in lintDetail.incompatibleRules) {
              final ruleDetail = lintCache.findDetailsById(incompatibleRule);
              expect(ruleDetail, isNotNull,
                  reason:
                      'No rule found for id: $incompatibleRule (check for typo?)');
              expect(ruleDetail.incompatibleRules, contains(lintDetail.id),
                  reason:
                      '${ruleDetail.id} should declare ${lintDetail.id} as `@IncompatibleWith` but does not.');
            }
          });
        }
      }
    });
  });
}
