// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidInitToNullTest);
  });
}

@reflectiveTest
class AvoidInitToNullTest extends LintRuleTest {
  @override
  String get lintRule => 'avoid_init_to_null';

  test_lintOnNullable() async {
    await assertHasLint(r'''
int? ii = null;
''');
  }

  test_NoLintOnInvalidAssignment_field() async {
    // Produces an invalid_assignment compilation error.
    await assertHasNoLint(r'''
class X {
  int x = null;
}
''');
  }

  test_NoLintOnInvalidAssignment_parameter() async {
    // Produces an invalid_assignment compilation error.
    await assertHasNoLint(r'''
class X {
  X({int a: null});
}
''');
  }

  test_NoLintOnInvalidAssignment_parameter2() async {
    // Produces an invalid_assignment compilation error.
    await assertHasNoLint(r'''
class X {
  int x;
  X({this.x: null});
}
''');
  }

  test_NoLintOnInvalidAssignment_topLevel() async {
    // Produces an invalid_assignment compilation error.
    await assertHasNoLint(r'''
int i = null;
''');
  }
}
