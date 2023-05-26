// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UnrelatedTypeEqualityChecksTest);
  });
}

@reflectiveTest
class UnrelatedTypeEqualityChecksTest extends LintRuleTest {
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

  test_recordsWithNamed_related() async {
    await assertNoDiagnostics(r'''
bool f(({int one, int two}) a, ({num two, num one}) b) => a == b;
''');
  }

  test_recordsWithNamed_unrelated() async {
    await assertDiagnostics(r'''
bool f(({int one, int two}) a, ({String one, String two}) b) => a == b;
''', [
      lint(64, 6),
    ]);
  }

  test_recordsWithNamedAndPositional_related() async {
    await assertNoDiagnostics(r'''
bool f((int, {int two}) a, (num one, {num two}) b) => a == b;
''');
  }

  test_recordsWithNamedAndPositional_unrelated() async {
    await assertDiagnostics(r'''
bool f((int, {int two}) a, (String one, {String two}) b) => a == b;
''', [
      lint(60, 6),
    ]);
  }

  test_switchExpression() async {
    await assertDiagnostics(r'''    
const space = 32;

String f(int char) {
  return switch (char) {
    == 'space' => 'space',
  };
}
''', [
      error(CompileTimeErrorCode.NON_EXHAUSTIVE_SWITCH_EXPRESSION, 49, 6),
      lint(69, 10),
    ]);
  }

  test_switchExpression_lessEq_ok() async {
    await assertDiagnostics(r'''
String f(int i) {
  return switch (i) {
    <= 1 => 'one',
  };
}
''', [
      // No lint.
      error(CompileTimeErrorCode.NON_EXHAUSTIVE_SWITCH_EXPRESSION, 27, 6)
    ]);
  }

  test_switchExpression_notEq() async {
    await assertDiagnostics(r'''    
const space = 32;

String f(int char) {
  return switch (char) {
    != 'space' => 'space',
  };
}
''', [
      error(CompileTimeErrorCode.NON_EXHAUSTIVE_SWITCH_EXPRESSION, 49, 6),
      lint(69, 10),
    ]);
  }

  test_switchExpression_ok() async {
    await assertDiagnostics(r'''
String f(String char) {
  return switch (char) {
    == 'space' => 'space',
  };
}
''', [
      // No lint.
      error(CompileTimeErrorCode.NON_EXHAUSTIVE_SWITCH_EXPRESSION, 33, 6),
    ]);
  }
}
