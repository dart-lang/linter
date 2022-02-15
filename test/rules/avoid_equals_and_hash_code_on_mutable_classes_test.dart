// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidEqualsAndHashCodeOnMutableClassesTest);
  });
}

@reflectiveTest
class AvoidEqualsAndHashCodeOnMutableClassesTest extends LintRuleTest {
  @override
  bool get addMetaPackageDep => true;

  @override
  List<String> get experiments => [
        EnableString.enhanced_enums,
      ];

  @override
  String get lintRule => 'avoid_equals_and_hash_code_on_mutable_classes';

  @FailingTest(issue: 'https://github.com/dart-lang/sdk/issues/48404', reason: 'Needs new analyzer')
  test_enum_bad() async {
    await assertDiagnostics(r'''
enum E {
  e(1), f(2), g(3);
  final int key;
  const E(this.key);
  bool operator ==(Object other) => other is E && other.key == key;
  int get hashCode => key.hashCode;
}
''', [
      lint('avoid_equals_and_hash_code_on_mutable_classes', 69, 4),
      lint('avoid_equals_and_hash_code_on_mutable_classes', 137, 3),
    ]);
  }

  @FailingTest(issue: 'https://github.com/dart-lang/sdk/issues/48404', reason: 'Enums cannot be marked @immutable')
  test_enum_ok() async {
    await assertNoDiagnostics(r'''
import 'package:meta/meta.dart';

@immutable
enum E {
  e(1), f(2), g(3);
  final int key;
  const E(this.key);
  bool operator ==(Object other) => other is E && other.key == key;
  int get hashCode => key.hashCode;
}
''');
  }


}
