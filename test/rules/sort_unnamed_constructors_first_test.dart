// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(SortUnnamedConstructorsFirstTest);
  });
}

@reflectiveTest
class SortUnnamedConstructorsFirstTest extends LintRuleTest {
  @override
  String get lintRule => 'sort_unnamed_constructors_first';

  test_class_sorted() async {
    await assertNoDiagnostics(r'''
class C {
  C(); 
  C.named();
  // ignore: unused_element
  C._();
}
''');
  }

  test_class_unsorted() async {
    await assertDiagnostics(r'''
class C {
  C.named();
  C();
  // ignore: unused_element
  C._();
}
''', [
      lint(25, 1),
    ]);
  }

  test_enum_sorted() async {
    await assertNoDiagnostics(r'''
enum A {
  a,b,c.aa();
  const A();
  const A.aa();
}
''');
  }

  test_enum_unsorted() async {
    await assertDiagnostics(r'''
enum A {
  a,b,c.aa();
  const A.aa();
  const A();
}
''', [
      lint(47, 1),
    ]);
  }
}
