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

  test_notSorted_private2() async {
    await assertDiagnostics(r'''
class _I1 {}
class _I2 {}
class A implements _I2, _I1 {}
''', [
      lint(50, 3),
    ]);
  }

  test_notSorted_private_public() async {
    await assertDiagnostics(r'''
class I1 {}
class _I1 {}
class A implements _I1, I1 {}
''', [
      lint(49, 2),
    ]);
  }

  /// This should not happen in good code - lower case class names.
  test_notSorted_private_public_lowerCase() async {
    await assertDiagnostics(r'''
class i1 {}
class _i1 {}
class A implements _i1, i1 {}
''', [
      lint(49, 2),
    ]);
  }

  test_notSorted_public2() async {
    await assertDiagnostics(r'''
class I1 {}
class I2 {}
class A implements I2, I1 {}
''', [
      lint(47, 2),
    ]);
  }

  test_notSorted_public4_reportOnlyOne() async {
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
class _I1 {}
class _I2 {}
class A implements I1, I2, _I1, _I2 {}
''');
  }
}
