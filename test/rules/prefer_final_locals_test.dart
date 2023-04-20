// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferFinalLocalsTestLanguage300);
  });
}

@reflectiveTest
class PreferFinalLocalsTestLanguage300 extends LintRuleTest
    with LanguageVersion300Mixin {
  @override
  String get lintRule => 'prefer_final_locals';

  test_destructured_listPattern() async {
    await assertDiagnostics(r'''
f() {
  var [a, b] = ['a', 'b'];
}
''', [
      lint(8, 3),
    ]);
  }

  test_destructured_listPattern_final() async {
    await assertNoDiagnostics(r'''
f() {
  final [a, b] = [1, 2];
}
''');
  }

  test_destructured_listPattern_mutated() async {
    await assertNoDiagnostics(r'''
f() {
  var [a, b] = [1, 2];
  ++a;
}
''');
  }

  test_destructured_listPatternWithRest() async {
    await assertDiagnostics(r'''
f() {
  var [a, b, ...rest] = [1, 2, 3, 4, 5, 6, 7];
}
''', [
      lint(8, 3),
    ]);
  }

  test_destructured_listPatternWithRest_mutated() async {
    await assertNoDiagnostics(r'''
f() {
  var [a, b, ...rest] = [1, 2, 3, 4, 5, 6, 7];
  ++a;
}
''');
  }

  test_destructured_mapPattern() async {
    await assertDiagnostics(r'''
f() {
  var {'first': a, 'second': b} = {'first': 1, 'second': 2};
}
''', [
      lint(8, 3),
    ]);
  }

  test_destructured_mapPattern_final() async {
    await assertNoDiagnostics(r'''
f() {
  final {'first': a, 'second': b} = {'first': 1, 'second': 2};
}
''');
  }

  test_destructured_mapPattern_mutated() async {
    await assertNoDiagnostics(r'''
f() {
  var {'first': a, 'second': b} = {'first': 1, 'second': 2};
  ++a;
}
''');
  }

  test_destructured_objectPattern() async {
    await assertDiagnostics(r'''
class A {
  int a;
  A(this.a);
}
f() {
  var A(a: b) = A(1);
}
''', [
      lint(42, 3),
    ]);
  }

  test_destructured_objectPattern_final() async {
    await assertNoDiagnostics(r'''
class A {
  int a;
  A(this.a);
}
f() {
  final A(a: b) = A(1);
}
''');
  }

  test_destructured_objectPattern_mutated() async {
    await assertNoDiagnostics(r'''
class A {
  int a;
  A(this.a);
}
f() {
  var A(a: b) = A(1);
  ++b;
}
''');
  }

  test_destructured_recordPattern() async {
    await assertDiagnostics(r'''
f() {
  var (a, b) = ('a', 'b');
}
''', [
      lint(8, 3),
    ]);
  }

  test_destructured_recordPattern_final() async {
    await assertNoDiagnostics(r'''
f() {
  final (a, b) = ('a', 'b');
}
''');
  }

  /// https://github.com/dart-lang/linter/issues/4286
  test_destructured_recordPattern_forLoop_final() async {
    await assertNoDiagnostics(r'''
f() {
  for (final (a, b) in [(1, 2), (3, 4), (5, 6)]) { }
}
''');
  }

  test_destructured_recordPattern_mutated() async {
    await assertNoDiagnostics(r'''
f() {
  var (a, b) = (1, 'b');
  ++a;
}
''');
  }

  test_destructured_recordPattern_withParenthesizedPattern() async {
    await assertDiagnostics(r'''
f() {
  var ((a, b)) = ('a', 'b');
}
''', [
      lint(8, 3),
    ]);
  }

  test_ifPatternList() async {
    await assertDiagnostics(r'''
f(Object o) {
  if (o case [int x, final int y]) x; 
}
''', [
      lint(28, 5),
    ]);
  }

  test_ifPatternList_final() async {
    await assertNoDiagnostics(r'''
f(Object o) {
  if (o case [final int x, final int y]) x; 
}
''');
  }

  test_ifPatternMap() async {
    await assertDiagnostics(r'''
f(Object o) {
  if (o case {'x': var x}) print('$x');
}
''', [
      lint(37, 1),
    ]);
  }

  test_ifPatternMap_final() async {
    await assertNoDiagnostics(r'''
f(Object o) {
  if (o case {'x': final x}) x;
}
''');
  }

  test_ifPatternObject() async {
    await assertDiagnostics(r'''
class C {
  int c;
  C(this.c);
}

f(Object o) {
  if (o case C(c: var x)) x;
}
''', [
      lint(71, 1),
    ]);
  }

  test_ifPatternObject_final() async {
    await assertNoDiagnostics(r'''
class C {
  int c;
  C(this.c);
}

f(Object o) {
  if (o case C(c: final x)) x;
}
''');
  }

  test_ifPatternRecord() async {
    await assertDiagnostics(r'''
f(Object o) {
  if (o case (int x, int y)) x;
}
''', [
      lint(28, 5),
      lint(35, 5),
    ]);
  }

  test_ifPatternRecord_final() async {
    await assertNoDiagnostics(r'''
f(Object o) {
  if (o case (final int x, final int y)) x;
}
''');
  }

  test_nonDeclaration_destructured_recordPattern() async {
    await assertNoDiagnostics(r'''
f(String a, String b) {
  [a, b] = ['a', 'b'];
}
''');
  }

  test_switch_objectPattern() async {
    await assertDiagnostics(r'''
class A {
  int a;
  A(this.a);
}

f() {
  switch (A(1)) {
    case A(a: >0 && var b): b;
  }
}
''', [
      lint(83, 1),
    ]);
  }

  test_switch_objectPattern_final() async {
    await assertNoDiagnostics(r'''
class A {
  int a;
  A(this.a);
}

f() {
  switch (A(1)) {
    case A(a: >0 && final b): b;
  }
}
''');
  }

  test_switch_objectPattern_mutated() async {
    await assertNoDiagnostics(r'''
class A {
  int a;
  A(this.a);
}

f() {
  switch (A(1)) {
    case A(a: >0 && var b): ++b;
  }
}
''');
  }

  test_switch_recordPattern() async {
    await assertDiagnostics(r'''
f() {
  switch ((1, 2)) {
    case (var a, int b): a;
  }
}
''', [
      lint(40, 1),
      lint(43, 5),
    ]);
  }

  test_switch_recordPattern_final() async {
    await assertNoDiagnostics(r'''
f() {
  switch ((1, 2)) {
    case (final a, final int b): a;
  }
}
''');
  }

  test_switch_recordPattern_mutated() async {
    await assertNoDiagnostics(r'''
f() {
  switch ((1, 2)) {
    case (var a, final int b): ++a;
  }
}
''');
  }
}
