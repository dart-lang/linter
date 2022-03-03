// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UseSuperInitializersTest);
  });
}

@reflectiveTest
class UseSuperInitializersTest extends LintRuleTest {
  @override
  List<String> get experiments => [
        EnableString.super_parameters,
      ];

  @override
  String get lintRule => 'use_super_initializers';

  test_named_first() async {
    await assertDiagnostics(r'''
class A {
  A({int? x, int? y});
}
class B extends A {
  B({int? x, int? y}) : super(x: x, y: y);
}
''', [
      lint('use_super_initializers', 79, 17),
    ]);
  }

  test_named_last() async {
    await assertDiagnostics(r'''
class A {
  A({int? x, int? y});
}
class B extends A {
  B({int? x, int? y}) : super(x: x, y: y);
}
''', [
      lint('use_super_initializers', 79, 17),
    ]);
  }

  test_named_middle() async {
    await assertDiagnostics(r'''
class A {
  A({int? x, int? y, int? z});
}
class B extends A {
  B({int? x, int? y, int? z}) : super(x: x, y: y, z: z);
}
''', [
      lint('use_super_initializers', 95, 23),
    ]);
  }

  test_named_only() async {
    await assertDiagnostics(r'''
class A {
  A({int? x});
}
class B extends A {
  B({int? x}) : super(x: x);
}
''', [
      lint('use_super_initializers', 63, 11),
    ]);
  }

  test_no_lint_named_noSuperInvocation() async {
    await assertNoDiagnostics(r'''
class A {
  A({int x = 0});
}
class B extends A {
  B({int x = 1});
}
''');
  }

  test_no_lint_named_notGenerative() async {
    await assertNoDiagnostics(r'''
class A {
  A({required int x});
}
class B extends A {
  static List<B> instances = [];
  factory B({required int x}) => instances[x];
}
''');
  }

  test_no_lint_named_notPassed_unreferenced() async {
    await assertNoDiagnostics(r'''
class A {
  A({int x = 0});
}
class B extends A {
  B({int x = 0}) : super(x: 0);
}
''');
  }

  test_no_lint_named_notPassed_usedInExpression() async {
    await assertNoDiagnostics(r'''
class A {
  A({String x = ''});
}
class B extends A {
  B({required Object x}) : super(x: x.toString());
}
''');
  }

  test_no_lint_requiredPositional_noSuperInvocation() async {
    await assertNoDiagnostics(r'''
class A {
  A();
}
class B extends A {
  B(int x);
}
''');
  }

  test_no_lint_requiredPositional_notGenerative() async {
    await assertNoDiagnostics(r'''
class A {
  A(int x);
}
class B extends A {
  static List<B> instances = [];
  factory B(int x) => instances[x];
}
''');
  }

  test_no_lint_requiredPositional_notPassed_unreferenced() async {
    await assertNoDiagnostics(r'''
class A {
  A(int x);
}
class B extends A {
  B(int x) : super(0);
}
''');
  }

  test_no_lint_requiredPositional_notPassed_usedInExpression() async {
    await assertNoDiagnostics(r'''
class A {
  A(String x);
}
class B extends A {
  B(Object x) : super(x.toString());
}
''');
  }

  test_optionalPositional_singleSuperParameter_only() async {
    await assertDiagnostics(r'''
class A {
  A(int x);
}
class B extends A {
  B([int x = 0]) : super(x);
}
''', [
      lint('use_super_initializers', 63, 8),
    ]);
  }

  test_requiredPositional_mixedSuperParameters_first() async {
    await assertDiagnostics(r'''
class A {
  A(int x, {int? y});
}
class B extends A {
  B(int x, int y) : super(x, y: y);
}
''', [
      lint('use_super_initializers', 74, 14),
    ]);
  }

  test_requiredPositional_mixedSuperParameters_last() async {
    await assertDiagnostics(r'''
class A {
  A(int x, {int? y});
}
class B extends A {
  B(int y, int x) : super(x, y: y);
}
''', [
      lint('use_super_initializers', 74, 14),
    ]);
  }
}
