// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(FlutterStyleTodosTest);
  });
}

@reflectiveTest
class FlutterStyleTodosTest extends LintRuleTest {
  @override
  String get lintRule => 'flutter_style_todos';

  test_badPatterns() async {
    await assertDiagnostics(
      r'''
// TODO something
// Todo something
// todo something
// TODO(somebody) something
// TODO: something
// Todo(somebody): something
// todo(somebody): something
// ToDo(somebody): something
// TODO(somebody): something, github.com/flutter/flutter
// ToDo(somebody): something, https://github.com/flutter/flutter
''',
      [
        lint(lintRule, 0, 17),
        lint(lintRule, 18, 17),
        lint(lintRule, 36, 17),
        lint(lintRule, 54, 27),
        lint(lintRule, 82, 18),
        lint(lintRule, 101, 28),
        lint(lintRule, 130, 28),
        lint(lintRule, 159, 28),
        lint(lintRule, 245, 64),
      ],
    );
  }

  test_goodPatterns() async {
    await assertNoDiagnostics(
      r'''
// TODO(somebody): something
// TODO(somebody): something, https://github.com/flutter/flutter
''',
    );
  }
}
