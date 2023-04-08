// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UnrelatedTypeEqualityChecksTestLanguage300);
  });
}

@reflectiveTest
class UnrelatedTypeEqualityChecksTestLanguage300 extends LintRuleTest
    with LanguageVersion300Mixin {
  @override
  String get lintRule => 'unrelated_type_equality_checks';

  test_recordAndInterfaceType_unrelated() async {
    await assertDiagnostics(r'''
bool f((int, int) a, String b) => a == b;
''', [
      lint(34, 6),
    ]);
  }

  test_records_related() async {
    await assertNoDiagnostics(r'''
bool f((int, int) a, (num, num) b) => a == b;
''');
  }

  test_records_unrelated() async {
    await assertDiagnostics(r'''
bool f((int, int) a, (String, String) b) => a == b;
''', [
      lint(44, 6),
    ]);
  }

  @FailingTest(
      reason: 'Error code refactoring',
      issue: 'https://github.com/dart-lang/linter/issues/4256')
  test_switchExpression() async {
    await assertDiagnostics(r'''    
const space = 32;

String f(int char) {
  return switch (char) {
    == 'space' => 'space',
  };
}
''', [
      // todo(pq): update to new error code
      // error(CompileTimeErrorCode.NON_EXHAUSTIVE_SWITCH, 49, 6),
      lint(69, 10),
    ]);
  }

  @FailingTest(
      reason: 'Error code refactoring',
      issue: 'https://github.com/dart-lang/linter/issues/4256')
  test_switchExpression_lessEq_ok() async {
    await assertDiagnostics(r'''
String f(String char) {
  return switch (char) {
    <= 1 => 'space',
  };
}
''', [
      // No lint.
      // todo(pq): update to new error code
      // error(CompileTimeErrorCode.NON_EXHAUSTIVE_SWITCH, 33, 6),
      error(CompileTimeErrorCode.UNDEFINED_OPERATOR, 53, 2),
    ]);
  }

  @FailingTest(
      reason: 'Error code refactoring',
      issue: 'https://github.com/dart-lang/linter/issues/4256')
  test_switchExpression_notEq() async {
    await assertDiagnostics(r'''    
const space = 32;

String f(int char) {
  return switch (char) {
    != 'space' => 'space',
  };
}
''', [
      // todo(pq): update to new error code
      // error(CompileTimeErrorCode.NON_EXHAUSTIVE_SWITCH, 49, 6),
      lint(69, 10),
    ]);
  }

  @FailingTest(
      reason: 'Error code refactoring',
      issue: 'https://github.com/dart-lang/linter/issues/4256')
  test_switchExpression_ok() async {
    await assertDiagnostics(r'''
String f(String char) {
  return switch (char) {
    == 'space' => 'space',
  };
}
''', [
      // No lint.
      // todo(pq): update to new error code
      // error(CompileTimeErrorCode.NON_EXHAUSTIVE_SWITCH, 33, 6),
    ]);
  }
}
