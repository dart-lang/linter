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

  test_main() async {
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
// TODO(somebody): something
''',
      [
        lint('flutter_style_todos', 0, 17),
        lint('flutter_style_todos', 18, 17),
        lint('flutter_style_todos', 36, 17),
        lint('flutter_style_todos', 54, 27),
        lint('flutter_style_todos', 82, 18),
        lint('flutter_style_todos', 101, 28),
        lint('flutter_style_todos', 130, 28),
        lint('flutter_style_todos', 159, 28),
      ],
    );
  }
}
