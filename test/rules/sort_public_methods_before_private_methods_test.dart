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

  test_public_methods_before_private_methods_in_class() async {
    await assertNoDiagnostics(r'''
class A {
  int a() => 0;
  int b() => _c();
  int _c() => 0;
}
''');
  }

  test_multiple_public_methods_before_private_methods_in_class() async {
    await assertNoDiagnostics(r'''
class A {
  int a() => 0;
  int b() => _c();
  int _c() => _d();
  int _d() => 0;
}
''');
  }

  test_public_method_is_after_private_method_in_class() async {
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

  test_only_public_methods_are_valid_in_class() async {
    await assertNoDiagnostics(r'''
class A {
  int a() => 0;
  int b() => 0;
}
''');
  }

  test_only_private_methods_are_valid_in_class() async {
    await assertNoDiagnostics(r'''
class A {
  int _a() => _b();
  int _b() => _a();
}
''');
  }

  test_public_methods_before_private_methods_in_enum() async {
    await assertNoDiagnostics(r'''
enum A {
  a,b,c;
  int d() => 0;
  int e() => _f();
  int _f() => 0;
}
''');
  }

  test_multiple_public_methods_before_private_methods_in_enum() async {
    await assertNoDiagnostics(r'''
enum A {
  a,b,c;
  int d() => 0;
  int e() => _f();
  int _f() => _g();
  int _g() => 0;
}
''');
  }

  test_public_method_is_after_private_method_in_enum() async {
    await assertDiagnostics(r'''
enum A {
  a,b,c;
  int d() => 0;
  int _f() => _g();
  int e() => _f();
  int _g() => 0;
}
''', [
      lint(56, 3),
    ]);
  }

  test_public_methods_before_private_methods_in_mixin() async {
    await assertNoDiagnostics(r'''
mixin A {
  int a() => 0;
  int b() => _c();
  int _c() => 0;
}
''');
  }

  test_multiple_public_methods_before_private_methods_in_mixin() async {
    await assertNoDiagnostics(r'''
mixin A {
  int a() => 0;
  int b() => _c();
  int _c() => _d();
  int _d() => 0;
}
''');
  }

  test_public_method_is_after_private_method_in_mixin() async {
    await assertDiagnostics(r'''
mixin A {
  int a() => 0;
  int _c() => _d();
  int b() => _c();
  int _d() => 0;
}
''', [
      lint(48, 3),
    ]);
  }

  test_public_methods_before_private_methods_in_extension() async {
    await assertNoDiagnostics(r'''
extension A on int {
  int a() => 0;
  int b() => _c();
  int _c() => 0;
}
''');
  }

  test_multiple_public_methods_before_private_methods_in_extension() async {
    await assertNoDiagnostics(r'''
extension A on int {
  int a() => 0;
  int b() => _c();
  int _c() => _d();
  int _d() => 0;
}
''');
  }

  test_public_method_is_after_private_method_in_extension() async {
    await assertDiagnostics(r'''
extension A on int {
  int a() => 0;
  int _c() => _d();
  int b() => _c();
  int _d() => 0;
}
''', [
      lint(59, 3),
    ]);
  }
}
