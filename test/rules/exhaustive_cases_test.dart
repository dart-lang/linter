// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ExhaustiveCasesTestLanguage219);
    defineReflectiveTests(ExhaustiveCasesTestLanguage300);
  });
}

abstract class BaseExhaustiveCasesTest extends LintRuleTest {
  final actualEnumSource = r'''
enum ActualEnum { e, f }

void ae(ActualEnum e) {
  switch (e) {
    case ActualEnum.e:
      print('e');
  }
}
''';

  @override
  String get lintRule => 'exhaustive_cases';

  test_enumLike() async {
    await assertDiagnostics(r'''
class E {
  final int i;
  const E._(this.i);

  static const e = E._(1);
  static const f = E._(2);
  static const g = E._(3);
}

void e(E e) {
  switch (e) {
    case E.e:
      print('e');
      break;
    case E.f:
      print('e');
  }
}
''', [
      lint(147, 10),
    ]);
  }

  test_enumLike_default_ok() async {
    await assertNoDiagnostics(r'''
class E {
  final int i;
  const E._(this.i);

  static const e = E._(1);
  static const f = E._(2);
  static const g = E._(3);
}

void okDefault(E e) {
  switch (e) {
    case E.e:
      print('e');
      break;
    default:
      print('default');
      break;
  }
}
''');
  }

  test_enumLike_deprecatedFields() async {
    await assertDiagnostics(r'''
class DeprecatedFields {
  final int i;
  const DeprecatedFields._(this.i);

  @deprecated
  static const oldFoo = newFoo;
  static const newFoo = DeprecatedFields._(1);
  static const bar = DeprecatedFields._(2);
  static const baz = DeprecatedFields._(3);
}

void dep(DeprecatedFields e) {
  switch (e) { 
    case DeprecatedFields.newFoo:
      print('newFoo');
      break;
    case DeprecatedFields.bar:
      print('bar');
      break;
    case DeprecatedFields.baz:
      print('baz');
      break;
  }

  switch (e) { 
    case DeprecatedFields.newFoo:
      print('newFoo');
      break;
    case DeprecatedFields.baz:
      print('baz');
      break;
  }

  switch (e) { 
    case DeprecatedFields.oldFoo:
      print('oldFoo');
      break;
    case DeprecatedFields.bar:
      print('bar');
      break;
    case DeprecatedFields.baz:
      print('baz');
      break;
  }
}
''', [
      lint(513, 10),
      error(HintCode.DEPRECATED_MEMBER_USE_FROM_SAME_PACKAGE, 708, 6),
    ]);
  }

  test_enumLike_ok() async {
    await assertNoDiagnostics(r'''
class E {
  final int i;
  const E._(this.i);

  static const e = E._(1);
  static const f = E._(2);
  static const g = E._(3);
}

void ok(E e) {
  switch (e) {
    case E.e:
      print('e');
      break;
    case E.f:
      print('e');
      break;
    case E.g:
      print('e');
      break;
  }
}
''');
  }

  test_enumLike_parenthesized_ok() async {
    await assertNoDiagnostics(r'''
class E {
  final int i;
  const E._(this.i);

  static const e = E._(1);
  static const f = E._(2);
  static const g = E._(3);
}

void okParenthesized(E e) {
  switch (e) {
    case (E.e):
      print('e');
      break;
    case ((E.f)):
      print('e');
      break;
    case (E.g):
      print('e');
      break;
  }
}
''');
  }

  test_notEnumLike_ok() async {
    await assertNoDiagnostics(r'''
class TooFew {
  const TooFew._();

  static const e = TooFew._();
}

void t(TooFew e) {
  switch (e) { 
    case TooFew.e:
      print('e');
  }
}

class PublicCons {
  const PublicCons();
  static const e = PublicCons();
  static const f = PublicCons();
}

void p(PublicCons e) {
  switch (e) { 
    case PublicCons.e:
      print('e');
  }
}
''');
  }

  test_notEnumLike_subclassed_ok() async {
    await assertNoDiagnostics(r'''
class Subclassed {
  const Subclassed._();

  static const e = Subclassed._();
  static const f = Subclassed._();
  static const g = Subclassed._();
}

class Subclass extends Subclassed {
  Subclass() : super._();
}

void s(Subclassed e) {
  switch (e) { 
    case Subclassed.e:
      print('e');
  }
}
''');
  }
}

@reflectiveTest
class ExhaustiveCasesTestLanguage219 extends BaseExhaustiveCasesTest
    with LanguageVersion219Mixin {
  test_enum_ok() async {
    await assertDiagnostics(actualEnumSource, [
      error(StaticWarningCode.MISSING_ENUM_CONSTANT_IN_SWITCH, 52, 10),
    ]);
  }
}

@reflectiveTest
class ExhaustiveCasesTestLanguage300 extends BaseExhaustiveCasesTest
    with LanguageVersion300Mixin {
  @override
  List<String> get experiments => ['records', 'patterns'];

  test_enum_ok() async {
    await assertDiagnostics(actualEnumSource, [
      error(CompileTimeErrorCode.NON_EXHAUSTIVE_SWITCH, 52, 6),
    ]);
  }
}
