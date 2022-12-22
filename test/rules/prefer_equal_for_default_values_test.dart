// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferEqualForDefaultValuesTest);
  });
}

@reflectiveTest
class PreferEqualForDefaultValuesTest extends LintRuleTest {
  @override
  String get lintRule => 'prefer_equal_for_default_values';

  test_super() async {
    // As of 2.19, this is a warning and the lint is a no-op.
    await assertNoDiagnostics(r'''
class A {
  String? a;
  A({this.a});
}

class B extends A {
  B({super.a = ''});
}
''');
  }
}
