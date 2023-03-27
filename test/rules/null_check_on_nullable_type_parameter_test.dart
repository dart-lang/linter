// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NullCheckOnNullableTypeParameterTestLanguage300);
  });
}

@reflectiveTest
class NullCheckOnNullableTypeParameterTestLanguage300 extends LintRuleTest
    with LanguageVersion300Mixin {
  @override
  String get lintRule => 'null_check_on_nullable_type_parameter';

  test_nullAssertPattern_list() async {
    await assertDiagnostics(r'''
f<T>(List<T?> l){
  var [x!, y] = l;
}
''', [
      lint(26, 1),
    ]);
  }

  test_nullAssertPattern_map() async {
    await assertDiagnostics(r'''
f<T>(Map<String, T?> m){
  var {'x': y!} = m;
}
''', [
      lint(38, 1),
    ]);
  }

  @FailingTest(issue: 'https://github.com/dart-lang/linter/issues/4218')
  test_nullAssertPattern_object() async {
    await assertDiagnostics(r'''
class A {
  Object? a;
  A(this.a);
}

void f<T>(T? t, A u) {
  var A(a: t!) = u;
}
''', [
      lint(75, 1),
    ]);
  }

  test_nullAssertPattern_record() async {
    await assertDiagnostics(r'''
f<T>((T?, T?) p){
  var (x!, y) = p;
}
''', [
      lint(26, 1),
    ]);
  }
}
