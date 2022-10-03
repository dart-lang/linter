// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(NoAdjacentStringsInCollectionTest);
  });
}

@reflectiveTest
class NoAdjacentStringsInCollectionTest extends LintRuleTest {
  @override
  String get lintRule => 'no_adjacent_strings_in_collection';

  test_adjacent_in_for_element() async {
    await assertDiagnostics('''
var list = [
    for (var _ in [])
      'a'
      'b',
    'c',
];
''', [
      lint(41, 13),
    ]);
  }

  test_adjacent_in_if_element() async {
    await assertDiagnostics('''
var list = [
    if (1 == 1)
      'a'
      'b',
    'c',
];
''', [
      lint(35, 13),
    ]);
  }

  test_adjacent_in_list() async {
    await assertDiagnostics('''
var list = [
    'a'
    'b',
    'c',
];
''', [
      lint(17, 11),
    ]);
  }

  test_adjacent_in_set() async {
    await assertDiagnostics('''
var list = {
    'a'
    'b',
    'c',
};
''', [
      lint(17, 11),
    ]);
  }

  test_no_adjacent_in_for_element() async {
    await assertNoDiagnostics('''
var list = [
    for (var _ in [])
      'a',
    'b',
    'c',
];
''');
  }

  test_no_adjacent_in_if_element() async {
    await assertNoDiagnostics('''
var list = [
    if (1 == 1)
      'a',
    'b',
    'c',
];
''');
  }

  test_no_adjacent_in_list() async {
    await assertDiagnostics('''
var list = [
    'a'
    'b',
    'c',
];
''', [
      lint(17, 11),
    ]);
  }

  test_no_adjacent_in_set() async {
    await assertDiagnostics('''
var list = {
    'a'
    'b',
    'c',
};
''', [
      lint(17, 11),
    ]);
  }
}
