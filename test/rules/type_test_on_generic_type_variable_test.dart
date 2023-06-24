// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(TypeTestOnGenericTypeVariableTest);
  });
}

@reflectiveTest
class TypeTestOnGenericTypeVariableTest extends LintRuleTest {
  @override
  String get lintRule => 'type_test_on_generic_type_variable';

  test_classGeneric() async {
    await assertDiagnostics(r'''
class C<T> {
  void m() {
    T is! String;
    T is int;
    T as num;
  }
}
''', [
      lint(32, 2),
      lint(50, 2),
      lint(64, 2),
    ]);
  }

  test_memberGeneric() async {
    await assertDiagnostics(r'''
class C {
  void m<T>() {
    T is! String;
    T is int;
    T as num;
  }
}
''', [
      lint(32, 2),
      lint(50, 2),
      lint(64, 2),
    ]);
  }

  test_topLevelGeneric() async {
    await assertDiagnostics(r'''
void f<T>() {
  T is! String;
  T is int;
  T as num;
}
''', [
      lint(18, 2),
      lint(34, 2),
      lint(46, 2),
    ]);
  }

  test_classNonGeneric() async {
    await assertNoDiagnostics(r'''
class C {
  Object? o;
  void m() {
    o is! String;
    o is int;
    o as num;
  }
}
''');
  }

  test_memberNonGeneric() async {
    await assertNoDiagnostics(r'''
class C {
  void m(Object o) {
    o is! String;
    o is int;
    o as num;
  }
}
''');
  }

  test_topLevelNonGeneric() async {
    await assertNoDiagnostics(r'''
void f(Object o) {
  o is! String;
  o is int;
  o as num;
}
''');
  }
}
