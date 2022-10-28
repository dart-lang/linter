// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(SortPrivateMethodsLastTest);
  });
}

@reflectiveTest
class SortPrivateMethodsLastTest extends LintRuleTest {
  @override
  String get lintRule => 'sort_private_methods_last';

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
      lint(0, 81),
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

  test_static_methods_are_ignored() async {
    await assertNoDiagnostics(r'''
class A {
  int a() => _e();
  int _b() => _c();
  int _c() => _b();
  static int d() => 0;
  static int _e() => 0;
}
''');
  }

  test_static_methods_are_ignored_2() async {
    await assertNoDiagnostics(r'''
class A {
  int a() => _e();
  static int _e() => 0;
  int _b() => _c();
  int _c() => _b();
  static int d() => 0;
}
''');
  }

  test_rule_does_not_apply_to_nested_methods() async {
    await assertNoDiagnostics(r'''
class A {
  int a() {
    int b() => 0;
    int _c() => b();
    int _d() => _c();
    int e() => _d();
    return e();
  }
}
''');
  }

  test_multiple_cases_are_reported_simultaneously() async {
    await assertDiagnostics(r'''
class A {
  int _a() => 0;
  int b() => _a();
  int _d() => _e();
  int c() => _d();
  int _e() => _f();
  int _f() => c();
}
''', [
      lint(0, 125),
    ]);
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
      lint(0, 91),
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
      lint(0, 83),
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
      lint(0, 94),
    ]);
  }
}
