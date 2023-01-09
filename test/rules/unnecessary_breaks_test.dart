// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UnnecessaryBreaksTest);
  });
}

@reflectiveTest
class UnnecessaryBreaksTest extends LintRuleTest {
  @override
  List<String> get experiments => ['patterns', 'records'];

  @override
  String get lintRule => 'unnecessary_breaks';

  test_switchPatternCase() async {
    await assertDiagnostics(r'''
f() {
  switch (1) {
    case 1:
      f();
      break;
    case 2:
      f();
  }
}
''', [
      lint(50, 6),
    ]);
  }

  test_switchPatternCase_empty_ok() async {
    await assertNoDiagnostics(r'''
f() {
  switch (1) {
    case 1:
      break;
    case 2:
      f();
  }
}
''');
  }

  test_switchPatternCase_notLast_ok() async {
    await assertNoDiagnostics(r'''
f(bool c) {
  switch (1) {
    case 1:
      if (c) break;
      f(true);
    case 2:
      f(true);
  }
}
''');
  }
}
