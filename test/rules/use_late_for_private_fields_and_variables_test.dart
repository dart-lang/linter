// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UseLateForPrivateFieldsAndVariablesTest);
  });
}

@reflectiveTest
class UseLateForPrivateFieldsAndVariablesTest extends LintRuleTest {
  @override
  List<String> get experiments => [
        EnableString.enhanced_enums,
      ];

  @override
  String get lintRule => 'use_late_for_private_fields_and_variables';

  @FailingTest(reason: 'Needs new analyzer')
  test_enum() async {
    await assertDiagnostics(r'''
enum A {
  a,b,c;
  int? _i;
  m() {
    _i!.abs();
  }
}
''', [
      lint('use_late_for_private_fields_and_variables', 25, 2),
    ]);
  }
}
