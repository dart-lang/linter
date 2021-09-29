// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(OverriddenFieldsTest);
  });
}

@reflectiveTest
class OverriddenFieldsTest extends LintRuleTest {
  @override
  String get lintRule => 'overridden_fields';

  /// https://github.com/dart-lang/linter/issues/2874
  test_conflictingStaticAndInstance() async {
    await assertNoLint(r'''
class A {
  static final String field = 'value';
}

class B extends A {
  String field = 'otherValue';
}
''');
  }

  test_recursiveInterfaceInheritance() async {
    // Produces a recursive_interface_inheritance diagnostic.
    await assertNoLint(r'''
class A extends B {}
class B extends A {
  int field = 0;
}
''');
  }

  test_mixinInheritsFromNotObject() async {
    // See: https://github.com/dart-lang/linter/issues/2969
    // Preserves existing testing logic but has so many misuses of mixins that
    // that it's hard to know how much tested logic is intentional.
    await assertDiagnostics(r'''
class Base {
  Object field = 'lorem';

  Object something = 'change';
}

class Bad1 extends Base {
  @override
  final x = 1, field = 'ipsum'; // LINT
}

class GC11 extends Bad1 {
  @override
  Object something = 'done'; // LINT

  Object gc33 = 'gc33';
}

class GC13 extends Object with Bad1 {
  @override
  Object something = 'done'; // OK

  @override
  Object field = 'lint'; // LINT
}

abstract class GC21 extends GC11 {
  @override
  Object something = 'done'; // LINT
}

class GC23 extends Object with GC13 {
  @override
  Object something = 'done'; // LINT

  @override
  Object field = 'lint'; // LINT
}

abstract class GC31 extends GC13 {
  @override
  Object something = 'done'; // LINT
}

abstract class GC32 implements GC13 {
  @override
  Object something = 'done'; // OK
}

class GC33 extends GC21 with GC13 {
  @override
  Object something = 'done'; // LINT

  @override
  Object gc33 = 'yada'; // LINT
}

class GC34 extends GC33 {
  @override
  var x = 3; // LINT

  @override
  Object gc33 = 'yada'; // LINT
}
''',
    [
      error(HintCode.OVERRIDE_ON_NON_OVERRIDING_FIELD, 120, 1),
      lint('overridden_fields', 127, 5),
      lint('overridden_fields', 202, 9),
      error(CompileTimeErrorCode.MIXIN_INHERITS_FROM_NOT_OBJECT, 289, 4),
      lint('overridden_fields', 365, 5),
      lint('overridden_fields', 448, 9),
      error(CompileTimeErrorCode.MIXIN_INHERITS_FROM_NOT_OBJECT, 510, 4),
      lint('overridden_fields', 538, 9),
      lint('overridden_fields', 588, 5),
      lint('overridden_fields', 671, 9),
      error(CompileTimeErrorCode.MIXIN_INHERITS_FROM_NOT_OBJECT, 819, 4),
      lint('overridden_fields', 847, 9),
      lint('overridden_fields', 897, 4),
      lint('overridden_fields', 967, 1),
      lint('overridden_fields', 1004, 4),
    ]);
  }

}


