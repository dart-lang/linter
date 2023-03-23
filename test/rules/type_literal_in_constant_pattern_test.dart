// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:linter/src/rules/type_literal_in_constant_pattern.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferPatternTypeLiteralEqualityTest);
  });
}

@reflectiveTest
class PreferPatternTypeLiteralEqualityTest extends LintRuleTest {
  @override
  String get lintRule => TypeLiteralInConstantPattern.lintName;

  test_matchNotType_constNotType() async {
    await assertNoDiagnostics(r'''
void f(Object? x) {
  if (x case 0) {}
}
''');
  }

  test_matchNotType_constType() async {
    await assertDiagnostics(r'''
void f(Object? x) {
  if (x case int) {}
}
''', [
      _lintNotType(33, 3),
    ]);
  }

  test_matchType_constNotType() async {
    await assertDiagnostics(r'''
void f(Type x) {
  if (x case 0) {}
}
''', [
      error(WarningCode.CONSTANT_PATTERN_NEVER_MATCHES_VALUE_TYPE, 30, 1),
    ]);
  }

  test_matchType_constType() async {
    await assertDiagnostics(r'''
void f(Type x) {
  if (x case int) {}
}
''', [
      _lintType(30, 3),
    ]);
  }

  test_matchType_constType_explicitConst() async {
    await assertDiagnostics(r'''
void f(Type x) {
  if (x case const (int)) {}
}
''', [
      _lintType(30, 11),
    ]);
  }

  test_matchType_constType_nested() async {
    await assertDiagnostics(r'''
void f(A x) {
  if (x case A(type: int)) {}
}

class A {
  final Type type;
  A(this.type);
}
''', [
      _lintType(35, 3),
    ]);
  }

  test_matchType_constType_switchExpression() async {
    await assertDiagnostics(r'''
int f(Type x) {
  return switch (x) {
    int => 0,
    _ => 0,
  };
}
''', [
      _lintType(42, 3),
    ]);
  }

  test_matchType_constType_switchStatement() async {
    await assertDiagnostics(r'''
void f(Type x) {
  switch (x) {
    case int:
      break;
  }
}
''', [
      _lintType(41, 3),
    ]);
  }

  test_matchType_constType_withImportPrefix() async {
    await assertDiagnostics(r'''
import 'dart:math' as math;

void f(Type x) {
  if (x case math.Random) {}
}
''', [
      _lintType(59, 11),
    ]);
  }

  ExpectedLint _lintNotType(int offset, int length) =>
      ExpectedLint.withLintCode(
          TypeLiteralInConstantPattern.matchNotType, offset, length);

  ExpectedLint _lintType(int offset, int length) => ExpectedLint.withLintCode(
      TypeLiteralInConstantPattern.matchType, offset, length);
}
