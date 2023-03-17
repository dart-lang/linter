// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    // TODO(srawlins): Add tests for unreachable public constructors.
    defineReflectiveTests(UnreachableFromMainTest);
  });
}

@reflectiveTest
class UnreachableFromMainTest extends LintRuleTest {
  @override
  bool get addMetaPackageDep => true;

  @override
  String get lintRule => 'unreachable_from_main';

  test_class_reachable_mainInPart() async {
    newFile('$testPackageLibPath/part.dart', r'''
part of 'test.dart';

void main() => A()
''');
    await assertNoDiagnostics(r'''
part 'part.dart';

class A {}
''');
  }

  test_class_reachableViaAnnotation() async {
    await assertNoDiagnostics(r'''
void main() {
  f();
}

class C {
  const C();
}

@C()
void f() {}
''');
  }

  test_class_reachableViaComment() async {
    await assertNoDiagnostics(r'''
/// See [C].
void main() {}

class C {}
''');
  }

  test_class_reachableViaDefaultValueType() async {
    await assertNoDiagnostics(r'''
void main() {
  f();
}

class C {
  const C();
}

void f([Object? p = const C()]) {}
''');
  }

  test_class_reachableViaTypedefBound() async {
    await assertNoDiagnostics(r'''
void main() {
  f();
}

class C {}

void f<T extends C>() {}
''');
  }

  test_class_reachableViaTypeInFunction() async {
    await assertNoDiagnostics(r'''
void main() {
  f();
}

class C {}

void Function(C)? f() => null;
''');
  }

  test_class_unreachable() async {
    await assertDiagnostics(r'''
void main() {}

class C {}
''', [
      lint(22, 1),
    ]);
  }

  test_class_unreachable_hasNamedConstructors() async {
    await assertDiagnostics(r'''
void main() {}

class C {
  C();
  C.named();
}
''', [
      lint(22, 1),
      // TODO(srawlins): See if we can skip reporting a declaration if it's
      //enclosing declaration is being reported.
      lint(28, 1),
      lint(37, 5),
    ]);
  }

  test_class_unreachable_mainInPart() async {
    newFile('$testPackageLibPath/part.dart', r'''
part of 'test.dart';

void main() {}
''');
    await assertDiagnostics(r'''
part 'part.dart';

class A {}
''', [
      lint(25, 1),
    ]);
  }

  test_classInPart_reachable() async {
    newFile('$testPackageLibPath/part.dart', r'''
part of 'test.dart';

class A {}
''');
    await assertNoDiagnostics(r'''
part 'part.dart';

void main() => A();
''');
  }

  test_classInPart_reachable_mainInPart() async {
    newFile('$testPackageLibPath/part.dart', r'''
part of 'test.dart';

class A {}

void main() => A()
''');
    await assertNoDiagnostics(r'''
part 'part.dart';
''');
  }

  test_classInPart_unreachable() async {
    newFile('$testPackageLibPath/part.dart', r'''
part of 'test.dart';

class A {}
''');
    await assertDiagnostics(r'''
part 'part.dart';

void main() {}
''', [
      lint(28, 1),
    ]);
  }

  test_classInPart_unreachable_mainInPart() async {
    newFile('$testPackageLibPath/part.dart', r'''
part of 'test.dart';

class A {}

void main() {}
''');
    await assertDiagnostics(r'''
part 'part.dart';
''', [
      lint(28, 1),
    ]);
  }

  test_constructor_named_onEnum() async {
    await assertDiagnostics(r'''
void main() {
  E.one;
  E.two;
}

enum E {
  one(), two();

  const E();
  const E.named();
}
''', [
      // No lint.
      error(HintCode.UNUSED_ELEMENT, 84, 5),
    ]);
  }

  test_constructor_named_reachableViaDirectCall() async {
    await assertNoDiagnostics(r'''
void main() {
  C.named();
}

class C {
  C.named();
}
''');
  }

  test_constructor_named_reachableViaExplicitSuperCall() async {
    await assertNoDiagnostics(r'''
void main() {
  D();
}

class C {
  C.named();
}

class D extends C {
  D() : super.named();
}
''');
  }

  test_constructor_named_reachableViaRedirectedConstructor() async {
    await assertNoDiagnostics(r'''
void main() {
  C.two();
}

class C {
  C.named();
  factory C.two() = C.named;
}
''');
  }

  test_constructor_named_reachableViaRedirection() async {
    await assertNoDiagnostics(r'''
void main() {
  C.two();
}

class C {
  C.named();

  C.two() : this.named();
}
''');
  }

  test_constructor_named_reachableViaTearoff() async {
    await assertNoDiagnostics(r'''
void main() {
  C.named;
}

class C {
  C.named();
}
''');
  }

  test_constructor_named_unreachable() async {
    await assertDiagnostics(r'''
void main() {
  C;
}

class C {
  C.named();
}
''', [
      lint(36, 5),
    ]);
  }

  test_constructor_named_unreachable_otherHasRedirectedConstructor() async {
    await assertDiagnostics(r'''
void main() {
  C.two();
}

class C {
  C.named();
  C.one();
  factory C.two() = C.one;
}
''', [
      lint(42, 5),
    ]);
  }

  test_constructor_unnamed_reachableViaDefaultImplicitSuperCall() async {
    await assertNoDiagnostics(r'''
void main() {
  D();
}

class C {
  C();
}

class D extends C {
  // Just a default constructor.
}
''');
  }

  test_constructor_unnamed_reachableViaDirectCall() async {
    await assertNoDiagnostics(r'''
void main() {
  C();
}

class C {
  C();
}
''');
  }

  test_constructor_unnamed_reachableViaExplicitSuperCall() async {
    await assertNoDiagnostics(r'''
void main() {
  D();
}

class C {
  C();
}

class D extends C {
  D() : super();
}
''');
  }

  test_constructor_unnamed_reachableViaImplicitSuperCall() async {
    await assertNoDiagnostics(r'''
void main() {
  D();
}

class C {
  C();
}

class D extends C {
  D();
}
''');
  }

  test_constructor_unnamed_reachableViaImplicitSuperCall_indirectly() async {
    await assertNoDiagnostics(r'''
void main() {
  E();
}

class C {
  C();
}

class D extends C {
  // Just a default constructor.
}

class E extends D {
  E();
}
''');
  }

  test_constructor_unnamed_reachableViaImplicitSuperCall_superParameters() async {
    await assertNoDiagnostics(r'''
void main() {
  D(1);
}

class C {
  C(int p);
}

class D extends C {
  D(super.p);
}
''');
  }

  test_constructor_unnamed_reachableViaRedirectedConstructor() async {
    await assertNoDiagnostics(r'''
void main() {
  C.two();
}

class C {
  C();
  factory C.two() = C;
}
''');
  }

  test_constructor_unnamed_reachableViaRedirection() async {
    await assertNoDiagnostics(r'''
void main() {
  C.two();
}

class C {
  C();

  C.two() : this();
}
''');
  }

  test_constructor_unnamed_reachableViaTearoff() async {
    await assertNoDiagnostics(r'''
void main() {
  C.new;
}

class C {
  C();
}
''');
  }

  test_constructor_unnamed_unreachable() async {
    await assertDiagnostics(r'''
void main() {
  C;
}

class C {
  C();
}
''', [
      lint(34, 1),
    ]);
  }

  test_constructor_unnamed_unreachable_otherHasRedirection() async {
    await assertDiagnostics(r'''
void main() {
  C.two();
}

class C {
  C();
  C.one();
  C.two() : this.one();
}
''', [
      lint(40, 1),
    ]);
  }

  test_enum_reachableViaValue() async {
    await assertNoDiagnostics(r'''
void main() {
  E.one;
}

enum E { one, two }
''');
  }

  test_enum_unreachable() async {
    await assertDiagnostics(r'''
void main() {}

enum E { one, two }
''', [
      lint(21, 1),
    ]);
  }

  test_extension_unreachable() async {
    await assertDiagnostics(r'''
void main() {}

extension IntExtension on int {}
''', [
      lint(26, 12),
    ]);
  }

  test_instanceFieldOnClass_unreachable() async {
    await assertNoDiagnostics(r'''
void main() {
  C();
}

class C {
  int f = 1;
}
''');
  }

  test_instanceMethodOnClass_unreachable() async {
    await assertNoDiagnostics(r'''
void main() {
  C();
}

class C {
  void f() {}
}
''');
  }

  test_mixin_unreachable() async {
    await assertDiagnostics(r'''
void main() {}

mixin M {}
''', [
      lint(22, 1),
    ]);
  }

  test_staticField_unreachable() async {
    await assertDiagnostics(r'''
void main() {
  C;
}

class C {
  static int f = 1;
}
''', [
      lint(45, 1),
    ]);
  }

  test_staticFieldOnClass_reachable() async {
    await assertNoDiagnostics(r'''
void main() {
  C.f;
}

class C {
  static int f = 1;
}
''');
  }

  test_staticFieldOnEnum_reachable() async {
    await assertNoDiagnostics(r'''
void main() {
  E.f;
}

enum E {
  one, two, three;
  static int f = 1;
}
''');
  }

  test_staticFieldOnExtension_reachable() async {
    await assertNoDiagnostics(r'''
void main() {
  E.f;
}

extension E on int {
  static int f = 1;
}
''');
  }

  test_staticFieldOnMixin_reachable() async {
    await assertNoDiagnostics(r'''
void main() {
  M.f;
}

mixin M {
  static int f = 1;
}
''');
  }

  test_staticGetter_reachable() async {
    await assertNoDiagnostics(r'''
void main() {
  C.g;
}

class C {
  static int get g => 7;
}
''');
  }

  test_staticGetter_unreachable() async {
    await assertDiagnostics(r'''
void main() {
  C;
}

class C {
  static int get g => 7;
}
''', [
      lint(34, 6),
    ]);
  }

  test_staticMethod_unreachable() async {
    await assertDiagnostics(r'''
void main() {
  C;
}

class C {
  static void f() {}
}
''', [
      lint(34, 6),
    ]);
  }

  test_staticMethodOnClass_reachable() async {
    await assertNoDiagnostics(r'''
void main() {
  C.f();
}

class C {
  static void f() {}
}
''');
  }

  test_staticMethodOnEnum_reachable() async {
    await assertNoDiagnostics(r'''
void main() {
  E.f();
}

enum E {
  one, two, three;
  static void f() {}
}
''');
  }

  test_staticMethodOnExtension_reachable() async {
    await assertNoDiagnostics(r'''
void main() {
  E.f();
}

extension E on int {
  static void f() {}
}
''');
  }

  test_staticMethodOnMixin_reachable() async {
    await assertNoDiagnostics(r'''
void main() {
  M.f();
}

mixin M {
  static void f() {}
}
''');
  }

  test_staticSetter_reachable() async {
    await assertNoDiagnostics(r'''
void main() {
  C.s = 1;
}

class C {
  static set s(int value) {}
}
''');
  }

  test_staticSetter_unreachable() async {
    await assertDiagnostics(r'''
void main() {
  C;
}

class C {
  static set s(int value) {}
}
''', [
      lint(34, 6),
    ]);
  }

  test_topLevelFunction_reachable() async {
    await assertNoDiagnostics(r'''
void main() {
  f1();
}

void f1() {
  f2();
}

void f2() {}
''');
  }

  test_topLevelFunction_reachable_private() async {
    await assertNoDiagnostics(r'''
void main() {
  _f();
}

void _f() {}
''');
  }

  test_topLevelFunction_unreachable() async {
    await assertDiagnostics(r'''
void main() {}

void f() {}
''', [
      lint(21, 1),
    ]);
  }

  test_topLevelFunction_unreachable_unrelatedPragma() async {
    await assertDiagnostics(r'''
void main() {}

@pragma('other')
void f() {}
''', [
      lint(38, 1),
    ]);
  }

  test_topLevelFunction_unreachable_visibleForTesting() async {
    await assertNoDiagnostics(r'''
import 'package:meta/meta.dart';
void main() {}

@visibleForTesting
void f() {}
''');
  }

  test_topLevelFunction_vmEntryPoint() async {
    await assertNoDiagnostics(r'''
@pragma('vm:entry-point')
void f6() {}
''');
  }

  test_topLevelFunction_vmEntryPoint_const() async {
    await assertNoDiagnostics(r'''
const entryPoint = pragma('vm:entry-point');
@entryPoint
void f6() {}
''');
  }

  test_topLevelGetter_reachable() async {
    await assertNoDiagnostics(r'''
void main() {
  g;
}

int get g => 7;
''');
  }

  test_topLevelGetter_unreachable() async {
    await assertDiagnostics(r'''
void main() {}

int get g => 7;
''', [
      lint(24, 1),
    ]);
  }

  test_topLevelSetter_reachable() async {
    await assertNoDiagnostics(r'''
void main() {
  s = 7;
}

set s(int value) {}
''');
  }

  test_topLevelSetter_unreachable() async {
    await assertDiagnostics(r'''
void main() {}

set s(int value) {}
''', [
      lint(20, 1),
    ]);
  }

  test_topLevelVariable_reachable() async {
    await assertNoDiagnostics(r'''
void main() {
  _f();
}

void _f() {
  x;
}

int x = 1;
''');
  }

  test_topLevelVariable_unreachable() async {
    await assertDiagnostics(r'''
void main() {}

int x = 1;
''', [
      lint(20, 1),
    ]);
  }

  test_typedef_unreachable() async {
    await assertDiagnostics(r'''
void main() {}

typedef T = String;
''', [
      lint(24, 1),
    ]);
  }
}
