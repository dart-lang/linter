// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UnnecessaryNullChecksTest);
  });
}

@reflectiveTest
class UnnecessaryNullChecksTest extends LintRuleTest {
  @override
  String get lintRule => 'unnecessary_this';

  /// https://github.com/dart-lang/linter/issues/4457
  @FailingTest(issue: 'https://github.com/dart-lang/linter/issues/4457')
  test_shadowSwitchPatternCase() async {
    await assertNoDiagnostics(r'''
class C {
  String? name;

  void m(bool b) {
    switch (b) {
      case true:
        var name = this.name!;
        print(name);
      case false:
        break;
    }
  }
}
''');
  }

  test_shadowInObjectPattern() async {
    await assertNoDiagnostics(r'''
class C {
  Object? value;
  bool equals(Object other) =>
      switch (other) { C(:var value) => this.value == value, _ => false };
}
''');
  }
}
