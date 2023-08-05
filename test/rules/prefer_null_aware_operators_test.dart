// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferNullAwareOperatorsTest);
  });
}

@reflectiveTest
class PreferNullAwareOperatorsTest extends LintRuleTest {
  @override
  String get lintRule => 'prefer_null_aware_operators';

  test_nullableEqualEqualNull_null_elsePropertyAccess() async {
    await assertDiagnostics(r'''
void f(A? a) {
  a == null ? null : a.b;
}

class A {
  int get b;
}
''', [
      // TODO
    ]);
  }

  test_nullableEqualEqualNull_null_elseMethodCall() async {
    await assertDiagnostics(r'''
void f(A? a) {
  a == null ? null : a.b();
}

class A {
  void b();
}
''', [
      // TODO
    ]);
  }

  test_nullableIdentifierEqualEqualNull_null_elsePropertyAccess() async {
    await assertDiagnostics(r'''
void f(A? a) {
  a == null ? null : a.b.c;
}

class A {
  A get b;
  A get c;
}
''', [
      // TODO
    ]);
  }

  test_prefixed_equalEqualNull_null_elsePropertyAccess() async {
    await assertDiagnostics(r'''
void f(A? a) {
  a.b == null ? null : a.b.c;
''', [
      // TODO
    ]);
  }

  test_5() async {
    await assertDiagnostics(r'''
m(p) {
  a.b == null ? null : a.b.c(); // LINT
''', [
      // TODO
    ]);
  }

  test_6() async {
    await assertDiagnostics(r'''
  p == null ? null : p.b; // LINT
m(p) {
''', [
      // TODO
    ]);
  }

  test_7() async {
    await assertDiagnostics(r'''
m(p) {
  null == a ? null : a.b; // LINT
}
''', [
      // TODO
    ]);
  }

  test_8() async {
    await assertDiagnostics(r'''
m(p) {
  null == a ? null : a.b(); // LINT
}
''', [
      // TODO
    ]);
  }

  test_9() async {
    await assertDiagnostics(r'''
m(p) {
  null == a.b ? null : a.b.c; // LINT
}
''', [
      // TODO
    ]);
  }

  test_nullEqualEqualIdentifier_null_elsePrefixedIdentifier() async {
    await assertDiagnostics(r'''
m(p) {
  null == p ? null : p.b;
}
''', [
      // TODO
    ]);
  }

  test_identifierNotEqualPrefixedIdentifier_elseNull() async {
    await assertDiagnostics(r'''
void f(A? a) {
  a != null ? a.b : null;
}

abstract class A {
  int get b;
}
''', [
      // TODO
    ]);
  }

  test_prefixedIdentifierNotEqualNull_propertyAccess_elseNull() async {
    await assertDiagnostics(r'''
void f(A a) {
  a.b != null ? a.b!.c : null;
}

abstract class A {
  A? get b;
  int get c;
}
''', [
      // TODO
    ]);
  }

  test_nullableIdentifierNotEqualNull_prefixedIdentifier_null() async {
    await assertDiagnostics(r'''
void f(A? a) {
  a != null ? a.b : null;
}

abstract class A {
  int get b;
}
''', [
      lint(17, 22),
    ]);
  }

  test_nullNotEqualIdentifier_prefixedIdentifier_elseNull() async {
    await assertDiagnostics(r'''
void f(A? a) {
  null != a ? a.b : null;
}

abstract class A {
  int get b;
}
''', [
      lint(17, 22),
    ]);
  }

  test_nullNotEqualPrefixedIdentifier_propertyAccess_elseNull() async {
    await assertDiagnostics(r'''
void f(A a) {
  null != a.b ? a.b!.c : null;
}

abstract class A {
  A? get b;
  int get c;
}
''', [
      // TODO
    ]);
  }

  test_nullableIdentifierEqualEqualNull_unrelatedBranch() async {
    // This is covered by another rule.
    await assertNoDiagnostics(r'''
void f(int? a, int b) {
  a == null ? b : a;
}
''');
  }

  test_nullableIdentifierEqualEqualNull_unrelatedBranches() async {
    await assertNoDiagnostics(r'''
void f(int? a, int b) {
  a == null ? b.isEven : null;
}
''');
  }

  test_nullablePrefixedIdentifierNotEqualNull_prefixedIdentifier_elseNull() async {
    await assertNoDiagnostics(r'''
void f(A a) {
  a.b != null ? a.b : null;
}

abstract class A {
  int? get b;
}
''');
  }

  test_nullableIdentifierEqualEqualNull_null_elseBinaryExpression() async {
    await assertNoDiagnostics(r'''
void f(A? a) {
  a == null ? null : a.b + 10;
}

abstract class A {
  int get b;
}
''');
  }
}
