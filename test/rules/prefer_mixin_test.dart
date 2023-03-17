// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferMixinTestLanguage219);
    defineReflectiveTests(PreferMixinTestLanguage300);
  });
}

abstract class BasePreferMixinTest extends LintRuleTest {
  @override
  String get lintRule => 'prefer_mixin';

  test_legacyCoreClasses() async {
    await assertNoDiagnostics(r'''
import 'dart:collection';
import 'dart:convert';

abstract class I with IterableMixin {}
abstract class L with ListMixin {}
abstract class MM with MapMixin {}
abstract class S with SetMixin {}
abstract class SCS with StringConversionSinkMixin {}
''');
  }

  test_mixedInMixin_ok() async {
    await assertNoDiagnostics(r'''
mixin M {}

class C with M {}
''');
  }

  test_mixedInTypeAlias_ok() async {
    await assertNoDiagnostics(r'''
mixin M {}

typedef AAA = M;

abstract class CCC with AAA { }
''');
  }
}

@reflectiveTest
class PreferMixinTestLanguage219 extends BasePreferMixinTest
    with LanguageVersion219Mixin {
  test_mixedInClass() async {
    await assertDiagnostics(r'''
class A {}

class B extends Object with A {}
''', [
      lint(40, 1),
    ]);
  }

  test_mixedInClass_typAlias() async {
    await assertDiagnostics(r'''
class A {}

typedef AA = A;

abstract class CC with AA { }
''', [
      lint(52, 2),
    ]);
  }
}

@reflectiveTest
class PreferMixinTestLanguage300 extends BasePreferMixinTest
    with LanguageVersion300Mixin {
  /// https://github.com/dart-lang/linter/issues/4065
  test_mixinClass() async {
    await assertNoDiagnostics(r'''
mixin class M { }

class Z with M { }
''');
  }
}
