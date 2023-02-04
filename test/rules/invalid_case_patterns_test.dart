// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(InvalidCasePatternsTest);
  });
}

@reflectiveTest
class InvalidCasePatternsTest extends LintRuleTest {
  @override
  String get lintRule => 'invalid_case_patterns';

  test_binaryExpression() async {
    await assertDiagnostics(r'''
void f(Object o) {
  switch (o) {
    case 1 + 2:
  }
}
''', [
      lint(43, 5),
    ]);
  }

  test_binaryExpression_logic() async {
    await assertDiagnostics(r'''
f(bool b) {
  switch (b) {
    case true && false:
  }
}
''', [
      lint(36, 13),
    ]);
  }

  test_conditionalExpression() async {
    await assertDiagnostics(r'''
void f(Object o) {
  switch (o) {
    case true ? 1 : 2: 
  }
}
''', [
      lint(43, 12),
      error(HintCode.DEAD_CODE, 54, 1),
    ]);
  }

  test_constConstructorCall() async {
    await assertDiagnostics(r'''
class C {
  const C();
}

f(C c) {
  switch (c) {
    case C():
  }
}
''', [
      lint(59, 3),
    ]);
  }

  test_identicalCall() async {
    await assertDiagnostics(r'''
void f(Object o) {
  switch (o) {
    case identical(1, 2):
  }
}
''', [
      lint(43, 15),
    ]);
  }

  test_isExpression() async {
    await assertDiagnostics(r'''
void f(Object o) {
  switch (o) {
      case 1 is int:
  }
}
''', [
      error(HintCode.UNNECESSARY_TYPE_CHECK_TRUE, 45, 8),
      lint(45, 8),
    ]);
  }

  test_lengthCall() async {
    await assertDiagnostics(r'''
void f(Object o) {
  switch (o) {
    case ''.length: 
  }
}
''', [
      lint(43, 9),
    ]);
  }

  test_listLiteral() async {
    await assertDiagnostics(r'''
void f(Object o) {
  switch (o) {
    case [1, 2]:
  }
}
''', [
      lint(43, 6),
    ]);
  }

  test_mapLiteral() async {
    await assertDiagnostics(r'''
void f(Object o) {
  switch (o) {
   case {'k': 'v'}:
  }
}
''', [
      lint(42, 10),
    ]);
  }

  test_parenthesizedExpression() async {
    await assertDiagnostics(r'''
void f(Object o) {
  switch (o) {
    case (1):
  }
}
''', [
      lint(43, 3),
    ]);
  }

  test_prefixedExpression() async {
    await assertDiagnostics(r'''
void f(Object o) {
  switch (o) {
    case -1:
  }
}
''', [
      lint(43, 2),
    ]);
  }

  test_setLiteral() async {
    await assertDiagnostics(r'''
void f(Object o) {
  switch (o) {
    case {1}:
  }
}
''', [
      lint(43, 3),
    ]);
  }

  test_wildcard() async {
    await assertDiagnostics(r'''
f(int n) {
  const _ = 3;
  switch (n) {
    case _:
  }
}
''', [
      lint(50, 1),
    ]);
  }
}
