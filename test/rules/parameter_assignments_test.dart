// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ParameterAssignmentsTest);
  });
}

@reflectiveTest
class ParameterAssignmentsTest extends LintRuleTest {
  @override
  String get lintRule => 'parameter_assignments';

  @FailingTest(reason: 'Closures not implemented')
  test_closure_assignment() async {
    await assertDiagnostics(r'''
void f() {
  (int p) {
    p = 2;
  }(2);
}
''', [
      lint(27, 5),
    ]);
  }

  test_function_assignment() async {
    await assertDiagnostics(r'''
void f(int p) {
  p = 4;
}
''', [
      lint(18, 5),
    ]);
  }

  test_function_incrementAssignment() async {
    await assertDiagnostics(r'''
void f(int p) {
  p += 4;
}
''', [
      lint(18, 6),
    ]);
  }

  test_function_named_default() async {
    await assertDiagnostics(r'''
void f({int p = 5}) {
  print(p++);
}
''', [
      lint(30, 3),
    ]);
  }

  test_function_named_optional_ok() async {
    await assertNoDiagnostics(r'''
void f({int? optional}) {
  optional ??= 8;
}
''');
  }

  test_function_ok_noAssignment() async {
    await assertNoDiagnostics(r'''
void f(String p) {
  print(p);
}
''');
  }

  test_function_ok_shadow() async {
    await assertNoDiagnostics(r'''
void f(String? p) {
  if (p == null) {
    int p = 2;
    p = 3;
  }
}
''');
  }

  test_function_positional_optional_assignedTwice() async {
    await assertDiagnostics(r'''
void f([int? optional]) {
  optional ??= 8;
  optional ??= 16;
}
''', [
      error(StaticWarningCode.DEAD_NULL_AWARE_EXPRESSION, 59, 2),
      lint(46, 15),
    ]);
  }

  test_function_positional_optional_ok() async {
    await assertNoDiagnostics(r'''
void f([int? optional]) {
  optional ??= 8;
}
''');
  }

  test_function_positional_optional_re_incremented() async {
    await assertDiagnostics(r'''
void f([int? optional]) {
  optional ??= 8;
  optional += 16;
}
''', [
      lint(46, 14),
    ]);
  }

  test_function_positional_optional_reassigned() async {
    await assertDiagnostics(r'''
void f([int? optional]) {
  optional ??= 8;
  optional = 16;
}
''', [
      lint(46, 13),
    ]);
  }

  test_function_postfix() async {
    await assertDiagnostics(r'''
void f(int p) {
  p++;
}
''', [
      lint(18, 3),
    ]);
  }

  test_function_prefix() async {
    await assertDiagnostics(r'''
void f(int p) {
  ++p;
}
''', [
      lint(18, 3),
    ]);
  }

  // If and switch cases don't need verification since params aren't valid
  // constant pattern expressions.

  test_listAssignment() async {
    await assertDiagnostics(r'''
f(var b) {
  [b] = [1];
}
''', [
      lint(13, 3),
    ]);
  }

  test_localFunction() async {
    await assertDiagnostics(r'''
void f(int p) {
  void g() {
    p = 3;
  }
  g();
}
''', [
      lint(33, 5),
    ]);
  }

  test_mapAssignment() async {
    await assertDiagnostics(r'''
f(var a) {
  {'a': a} = {'a': 1};
}
''', [
      lint(13, 8),
    ]);
  }

  test_member_setter() async {
    await assertDiagnostics(r'''
class A {
  set x(int v) {
    v = 5;
  }
}
''', [
      lint(31, 5),
    ]);
  }

  test_objectAssignment() async {
    await assertDiagnostics(r'''
class A {
  int a;
  A(this.a);
}

f(var b) {
  A(a: b) = A(1);
}
''', [
      lint(48, 7),
    ]);
  }

  test_recordAssignment() async {
    await assertDiagnostics(r'''
void f(var a) {
  var b = 0;
  (a, b) = (1, 2);
}
''', [
      lint(31, 6),
    ]);
  }
}
