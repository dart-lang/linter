// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(OverrideVoidReturnTest);
  });
}

@reflectiveTest
class OverrideVoidReturnTest extends LintRuleTest {
  @override
  String get lintRule => 'override_void_return';

  test_abstract() async {
    await assertDiagnostics(r'''
abstract class A {
  void m();
}
class B extends A {
  Future<void> m() async {}
}
''', [
      lint(68, 1),
    ]);
  }

  test_extended() async {
    await assertDiagnostics(r'''
class A {
  void m() {}
}
class B extends A {
  int m() => 7;
}
''', [
      lint(52, 1),
    ]);
  }

  test_genericInstantiation() async {
    await assertDiagnostics(r'''
import 'dart:async';

abstract class A<T> {
  T m();
}
class B extends A<void> {
  FutureOr<void> m() async {}
}
''', [
      lint(98, 1),
    ]);
  }

  test_implemented() async {
    await assertDiagnostics(r'''
class A {
  void m() {}
}
class B implements A {
  int m() => 7;
}
''', [
      lint(55, 1),
    ]);
  }

  test_mixedIn() async {
    await assertDiagnostics(r'''
mixin M {
  void m() {}
}
class B with M {
  Future<void> m() async {}
}
''', [
      lint(58, 1),
    ]);
  }

  @FailingTest(reason: 'Not implemented yet')
  test_mixinApplication() async {
    await assertDiagnostics(r'''
class A {
  void m() {}
}
mixin M {
  Future<void> m() async {}
}
class B = A with M;
''', [
      lint(56, 1),
    ]);
  }

  test_superConstraint() async {
    await assertDiagnostics(r'''
class A {
  void m() {}
}
mixin M on A {
  Future<void> m() async {}
}
''', [
      lint(56, 1),
    ]);
  }

  test_voidOverride() async {
    await assertNoDiagnostics(r'''
class A {
  void m() {}
}
class B extends A {
  void m() {}
}
''');
  }
}
