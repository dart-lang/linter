// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:linter/src/rules/sort_interfaces.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(SortInterfacesTest);
  });
}

@reflectiveTest
class SortInterfacesTest extends LintRuleTest {
  @override
  String get lintRule => SortInterfaces.code.name;

  test_notSorted1() async {
    await assertDiagnostics(r'''
class I1 {}
class I2 {}
class A implements I2, I1 {}
''', [
      lint(47, 2),
    ]);
  }

  test_notSorted2() async {
    await assertDiagnostics(r'''
class I1 {}
class I2 {}
class I3 {}
class I4 {}
class A implements I2, I1, I4, I3 {}
''', [
      lint(71, 2),
    ]);
  }

  test_sorted() async {
    await assertNoDiagnostics(r'''
class I1 {}
class I2 {}
class A implements I1, I2 {}
''');
  }
}
