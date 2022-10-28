// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(SortConstructorsFirstTest);
  });
}

@reflectiveTest
class SortConstructorsFirstTest extends LintRuleTest {
  @override
  String get lintRule => 'sort_public_methods_before_private_methods';

  test_public_methods_before_private_methods() async {
    await assertNoDiagnostics(r'''
class A {
  int a() => 0;
  int b() => _c();
  int _c() => 0;
}
''');
  }

  test_multiple_public_methods_before_private_methods() async {
    await assertNoDiagnostics(r'''
class A {
  int a() => 0;
  int b() => _c();
  int _c() => _d();
  int _d() => 0;
}
''');
  }

  test_public_method_is_after_private_method() async {
    await assertDiagnostics(r'''
class A {
  int a() => 0;
  int b() => _c();
  int _c() => d();
  int d() => 0;
}
''', [
      lint(66, 3),
    ]);
  }
}
