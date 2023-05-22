// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AwaitOnlyFuturesTest);
  });
}

@reflectiveTest
class AwaitOnlyFuturesTest extends LintRuleTest {
  @override
  String get lintRule => 'await_only_futures';

  test_undefinedClass() async {
    await assertDiagnostics(r'''
Undefined f() async => await f();
''', [
      // No lint
      error(CompileTimeErrorCode.UNDEFINED_CLASS, 0, 9),
    ]);
  }
}
