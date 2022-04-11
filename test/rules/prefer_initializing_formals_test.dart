// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(PreferInitializingFormalsTest);
  });
}

@reflectiveTest
class PreferInitializingFormalsTest extends LintRuleTest {
  @override
  String get lintRule => 'prefer_initializing_formals';

  /// https://github.com/dart-lang/linter/issues/3345
  test_noLint() async {
    await assertNoDiagnostics(r'''
class C {
  final Object name;
  final int length;
  C.forName(String name) : name = name,
    length = name.length;
}
''');
  }
}
