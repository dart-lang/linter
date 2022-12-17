// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NonNullableEqualsParameterTest);
  });
}

@reflectiveTest
class NonNullableEqualsParameterTest extends LintRuleTest {
  @override
  String get lintRule => 'non_nullable_equals_parameter';

  test_class_nonNullableParameter() async {
    await assertNoDiagnostics(r'''
class C {
  bool operator ==(Object other) => other is C;
}
''');
  }

  test_class_nonNullableParameter_inherited() async {
    await assertNoDiagnostics(r'''
class C {
  bool operator ==(Object other) => other is C;
}
class D extends C {
  bool operator ==(other) => other is D;
}
''');
  }

  test_class_nullableParameter() async {
    await assertDiagnostics(r'''
class C {
  bool operator ==(Object? other) => other is C;
}
''', [
      lint(29, 13),
    ]);
  }

  test_class_nullableParameter_dynamic() async {
    await assertDiagnostics(r'''
class C {
  bool operator ==(dynamic other) => other is C;
}
''', [
      lint(29, 13),
    ]);
  }

  test_class_nullableParameter_dynamicAndInherited() async {
    await assertDiagnostics(r'''
class C {
  bool operator ==(dynamic other) => other is C;
}
class D extends C {
  bool operator ==(other) => other is D;
}
''', [
      lint(29, 13),
      lint(100, 5),
    ]);
  }

  test_class_nullableParameter_nonObject() async {
    await assertDiagnostics(r'''
class C {
  bool operator ==(num? other) => false;
}
''', [
      error(CompileTimeErrorCode.INVALID_OVERRIDE, 26, 2),
      // No lint.
    ]);
  }

  test_mixin_nullableParameter() async {
    await assertDiagnostics(r'''
mixin M {
  bool operator ==(Object? other) => other is M;
}
''', [
      lint(29, 13),
    ]);
  }
}
