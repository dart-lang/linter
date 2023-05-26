// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoWildcardVariableUsesTest);
  });
}

@reflectiveTest
class NoWildcardVariableUsesTest extends LintRuleTest {
  @override
  String get lintRule => 'no_wildcard_variable_uses';

  test_declaredIdentifier() async {
    await assertNoDiagnostics(r'''
f() {
  for (var _ in [1, 2, 3]) ;
}  
''');
  }

  test_localVar() async {
    await assertDiagnostics(r'''
f() {
  var _ = 1;
  print(_);
}
''', [
      lint(27, 1),
    ]);
  }

  test_param() async {
    await assertDiagnostics(r'''
f(int __) {
  print(__);
}
''', [
      lint(20, 2),
    ]);
  }
}
