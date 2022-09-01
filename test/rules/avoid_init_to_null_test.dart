// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidInitToNullTest);
    defineReflectiveTests(AvoidInitToNullSuperFormalsTest);
  });
}

@reflectiveTest
class AvoidInitToNullSuperFormalsTest extends LintRuleTest {
  @override
  String get lintRule => 'avoid_init_to_null';

  test_nullableStringInit() async {
    await assertDiagnostics(r'''
class A {
  String? a;
  A({this.a = null});
}
''', [
      lint(28, 13),
    ]);
  }

  test_superInit_2() async {
    await assertDiagnostics(r'''
class A {
  String? a;
  A({this.a = null});
}
class B extends A {
  B({super.a = null});
}
''', [
      lint(28, 13),
      lint(72, 14),
    ]);
  }

  /// https://github.com/dart-lang/linter/issues/3349
  test_superInit_nolint() async {
    await assertNoDiagnostics(r'''
class A {
  String? a;
  A({this.a = ''});
}

class B extends A {
  B({super.a = null});
}
''');
  }
}

@reflectiveTest
class AvoidInitToNullTest extends LintRuleTest {
  @override
  String get lintRule => 'avoid_init_to_null';

  test_invalidAssignment_field() async {
    await assertDiagnostics(r'''
class X {
  int x = null;
}
''', [
      // No lint
      error(CompileTimeErrorCode.INVALID_ASSIGNMENT, 20, 4),
    ]);
  }

  test_invalidAssignment_namedParameter() async {
    await assertDiagnostics(r'''
class X {
  X({int a: null});
}
''', [
      // No lint
      error(CompileTimeErrorCode.INVALID_ASSIGNMENT, 22, 4),
    ]);
  }

  test_invalidAssignment_namedParameter_fieldFormal() async {
    await assertDiagnostics(r'''
class X {
  int x;
  X({this.x: null});
}
''', [
      // No lint
      error(CompileTimeErrorCode.INVALID_ASSIGNMENT, 32, 4),
    ]);
  }

  test_invalidAssignment_topLevelVariable() async {
    await assertDiagnostics(r'''
int i = null;
''', [
      // No lint
      error(CompileTimeErrorCode.INVALID_ASSIGNMENT, 8, 4),
    ]);
  }

  test_nullable_topLevelVariable() async {
    await assertDiagnostics(r'''
int? ii = null;
''', [
      lint(5, 9),
    ]);
  }
}
