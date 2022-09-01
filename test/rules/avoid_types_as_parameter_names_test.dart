// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidTypesAsParameterNamesTest);
    defineReflectiveTests(AvoidTypesAsParameterNamesRecordsTest);
  });
}

@reflectiveTest
class AvoidTypesAsParameterNamesTest extends LintRuleTest {
  @override
  String get lintRule => 'avoid_types_as_parameter_names';

  test_super() async {
    await assertDiagnostics(r'''
class A {
  String a;
  A(this.a);
}
class B extends A {
  B(super.String);
}
''', [
      lint(67, 6),
    ]);
  }
}

@reflectiveTest
class AvoidTypesAsParameterNamesRecordsTest extends LintRuleTest {
  @override
  List<String> get experiments => ['records'];

  @override
  String get lintRule => 'avoid_types_as_parameter_names';

  @FailingTest(issue: 'https://github.com/dart-lang/linter/issues/3628')
  test_records() async {
    await assertDiagnostics(r'''
var c = (int: 1);
''', [
      lint('avoid_types_as_parameter_names', 10, 3),
    ]);
  }
}
