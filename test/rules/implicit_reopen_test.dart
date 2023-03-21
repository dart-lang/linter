// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(ImplicitReopenTest);
    defineReflectiveTests(ImplicitReopenInducedModifierTest);
  });
}

@reflectiveTest
class ImplicitReopenInducedModifierTest extends LintRuleTest
    with LanguageVersion300Mixin {
  @override
  bool get addMetaPackageDep => true;

  @override
  String get lintRule => 'implicit_reopen';

  test_class_classSealed_classFinal_ok() async {
    await assertDiagnostics(r'''
final class F {}
sealed class S extends F {}
class C extends S {}
''', [
      // No lint.
      error(CompileTimeErrorCode.SUBTYPE_OF_FINAL_IS_NOT_BASE_FINAL_OR_SEALED,
          51, 1),
    ]);
  }

  test_inducedFinal() async {
    await assertDiagnostics(r'''
final class F {}
sealed class S extends F {}
base class C extends S {}
''', [
      lint(56, 1),
    ]);
  }

  test_inducedFinal_base_interface() async {
    await assertDiagnostics(r'''
base class C {}
interface class D {}
sealed class E extends D implements C {}
base class B extends E {}
''', [
      lint(89, 1),
    ]);
  }

  test_inducedFinal_baseMixin_interface() async {
    await assertDiagnostics(r'''
interface class D {}
base mixin G {}
sealed class H extends D with G {}
base class B extends H {}
''', [
      lint(83, 1),
    ]);
  }

  test_inducedFinal_mixin_finalClass() async {
    await assertDiagnostics(r'''
final class S {}
mixin M {}
sealed class A extends S with M {}
base class B extends A {}
''', [
      lint(74, 1),
    ]);
  }

  test_inducedInterface() async {
    await assertDiagnostics(r'''
interface class I {}
sealed class S extends I {}
class C extends S {}
''', [
      lint(55, 1),
    ]);
  }

  test_inducedInterface_base() async {
    await assertDiagnostics(r'''
interface class I {}
sealed class S extends I {}
base class C extends S {}
''', [
      lint(60, 1),
    ]);
  }

  test_inducedInterface_base_mixin_interface() async {
    await assertDiagnostics(r'''
interface class S {}
mixin M {}
sealed class A extends S with M {}
base class C extends A {}
''', [
      lint(78, 1),
    ]);
  }

  test_inducedInterface_mixin_interface() async {
    await assertDiagnostics(r'''
interface class S {}
mixin M {}
sealed class A extends S with M {}
class C extends A {}
''', [
      lint(73, 1),
    ]);
  }
}

@reflectiveTest
class ImplicitReopenTest extends LintRuleTest with LanguageVersion300Mixin {
  @override
  bool get addMetaPackageDep => true;

  @override
  String get lintRule => 'implicit_reopen';

  test_class_classFinal_ok() async {
    await assertDiagnostics(r'''
final class F {}

class C extends F {}
''', [
      error(CompileTimeErrorCode.SUBTYPE_OF_FINAL_IS_NOT_BASE_FINAL_OR_SEALED,
          24, 1),
    ]);
  }

  test_class_classInterface() async {
    await assertDiagnostics(r'''
interface class I {}

class C extends I {}
''', [
      lint(28, 1),
    ]);
  }

  test_class_classInterface_outsideLib_ok() async {
    newFile('$testPackageLibPath/a.dart', r'''
interface class I {}
''');

    await assertDiagnostics(r'''
import 'a.dart';

class C extends I {}
''', [
      error(CompileTimeErrorCode.INTERFACE_CLASS_EXTENDED_OUTSIDE_OF_LIBRARY,
          34, 1),
    ]);
  }

  test_class_classInterface_reopened_ok() async {
    await assertNoDiagnostics(r'''
import 'package:meta/meta.dart';

interface class I {}

@reopen
class C extends I {}
''');
  }

  test_classBase_classFinal() async {
    await assertDiagnostics(r'''
final class F {}

base class B extends F {}
''', [
      lint(29, 1),
    ]);
  }

  test_classBase_classInterface() async {
    await assertDiagnostics(r'''
interface class I {}

base class B extends I {}
''', [
      lint(33, 1),
    ]);
  }

  test_classFinal_classInterface_ok() async {
    await assertNoDiagnostics(r'''
interface class I {}

final class C extends I {}
''');
  }

//
//   test_extends_class_classSealed_classInterface() async {
//     await assertDiagnostics(r'''
// interface class I {}
//
// sealed class S extends I {}
//
// class C extends S {}
// ''', [
//       lint(57, 1),
//     ]);
//   }
//
//   test_extends_class_classSealed_mixinInterface() async {
//     await assertDiagnostics(r'''
// interface class I {}
//
// sealed class S extends I {}
//
// class C extends S {}
// ''', [
//       lint(57, 1),
//     ]);
//   }
//
//

//
//   test_extends_classBase_classSealed_classFinal() async {
//     await assertDiagnostics(r'''
// final class F {}
//
// sealed class S extends F {}
//
// base class C extends S {}
// ''', [
//       lint(58, 1),
//     ]);
//   }
//
//   test_extends_classBase_classSealed_classInterface() async {
//     await assertDiagnostics(r'''
// interface class I {}
//
// sealed class S extends I {}
//
// base class C extends S {}
// ''', [
//       lint(62, 1),
//     ]);
//   }
//
//   test_extends_classBase_classSealed_mixinInterface() async {
//     await assertDiagnostics(r'''
// interface class I {}
//
// sealed class S extends I {}
//
// base class C extends S {}
// ''', [
//       lint(62, 1),
//     ]);
//   }
//

//
//   test_with_class_mixinFinal_ok() async {
//     await assertDiagnostics(r'''
// final mixin M {}
//
// class C with M {}
// ''', [
//       error(CompileTimeErrorCode.SUBTYPE_OF_FINAL_IS_NOT_BASE_FINAL_OR_SEALED,
//           24, 1),
//     ]);
//   }
//
//   test_with_class_mixinInterface() async {
//     await assertDiagnostics(r'''
// interface mixin M {}
//
// class C with M {}
// ''', [
//       lint(28, 1),
//     ]);
//   }
//
//   test_with_classBase_mixinFinal() async {
//     await assertDiagnostics(r'''
// final mixin M {}
//
// base class B with M {}
// ''', [
//       lint(29, 1),
//     ]);
//   }
//
//   test_with_classBase_mixinInterface() async {
//     await assertDiagnostics(r'''
// interface mixin M {}
//
// base class B with M {}
// ''', [
//       lint(33, 1),
//     ]);
//   }
}
