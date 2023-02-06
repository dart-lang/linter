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

  test_binaryExpression_logicalAnd() async {
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

  test_binaryExpression_plus() async {
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

  test_constConstructorCall_explicitConst() async {
    await assertDiagnostics(r'''
class C {
  const C();
}
f(C c) {
  switch (c) {
    case const C():
  }
}
''', [
      lint(58, 9),
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
      error(HintCode.UNNECESSARY_TYPE_CHECK_TRUE, 43, 8),
      lint(43, 8),
    ]);
  }

  test_isNotExpression() async {
    await assertDiagnostics(r'''
void f(Object o) {
  switch (o) {
    case 1 is! int:
  }
}
''', [
      error(HintCode.UNNECESSARY_TYPE_CHECK_FALSE, 43, 9),
      lint(43, 9),
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

  test_listLiteral_typeArgs() async {
    await assertDiagnostics(r'''
void f(Object o) {
  switch (o) {
    case <int>[1, 2]:
  }
}
''', [
      lint(43, 11),
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

  test_mapLiteral_typeArgs() async {
    await assertDiagnostics(r'''
void f(Object o) {
  switch (o) {
   case <String,String>{'k': 'v'}:
  }
}
''', [
      lint(42, 25),
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

  test_prefixedExpression_intLiteral_ok() async {
    await assertNoDiagnostics(r'''
void f(Object o) {
  switch (o) {
    case -1:
  }
}
''');
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

  test_setLiteral_typeArgs() async {
    await assertDiagnostics(r'''
void f(Object o) {
  switch (o) {
    case <int>{1}:
  }
}
''', [
      lint(43, 8),
    ]);
  }

  test_unaryOperator_minus() async {
    await assertDiagnostics(r'''
void f() {
  const o = 1;
  switch (1) {
    case -o:
  }
}
''', [
      lint(50, 2),
    ]);
  }

  test_unaryOperator_not() async {
    await assertDiagnostics(r'''
  void f() {
    const b = false;
    switch (true) {
      case !b:
    }
  }
''', [
      lint(65, 2),
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
