// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferFinalLocalsPatternsTest);
  });
}

@reflectiveTest
class PreferFinalLocalsPatternsTest extends LintRuleTest {
  @override
  List<String> get experiments => ['patterns', 'records'];

  @override
  String get lintRule => 'prefer_final_locals';

  test_destructured_recordPattern() async {
    await assertDiagnostics(r'''
f() {
  var (a, b) = ('a', 'b');
  print('$a$b');
}
''', [
      lint(21, 10),
    ]);
  }

  test_destructured_recordPattern_list() async {
    await assertDiagnostics(r'''
f() {
  var [a, b] = ['a', 'b'];
  print('$a$b');
}
''', [
      lint(12, 6),
    ]);
  }

  test_destructured_recordPattern_list_mutated_ok() async {
    await assertNoDiagnostics(r'''
f() {
  var [a, b] = [1, 2];
  print('${++a}$b');
}
''');
  }

  test_destructured_recordPattern_list_ok() async {
    await assertNoDiagnostics(r'''
f() {
  final [a, b] = [1, 2];
  print('$a$b');
}
''');
  }

  test_destructured_recordPattern_mutated_ok() async {
    await assertNoDiagnostics(r'''
f() {
  var (a, b) = (1, 'b');
  print('${++a}$b');
}
''');
  }

  test_destructured_recordPattern_ok() async {
    await assertNoDiagnostics(r'''
f() {
  final (a, b) = ('a', 'b');
  print('$a$b');
}
''');
  }

  test_switch_recordPattern() async {
    await assertDiagnostics(r'''
f() {
  switch ((1, 2)) {
    case (var a, int b): print('$a$b');
  }
}
''', [
      lint(40, 1),
      lint(47, 1),
    ]);
  }

  test_switch_recordPattern_mutated_ok() async {
    await assertNoDiagnostics(r'''
f() {
  switch ((1, 2)) {
    case (var a, final int b): {
      print('${++a}$b');
    }
  }
}
''');
  }

  test_switch_recordPattern_ok() async {
    await assertNoDiagnostics(r'''
f() {
  switch ((1, 2)) {
    case (final a, final int b): print('$a$b');
  }
}
''');
  }
}
