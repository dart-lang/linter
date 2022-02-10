// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidRelativeLibImportsTest);
  });
}

@reflectiveTest
class AvoidRelativeLibImportsTest extends LintRuleTest {
  @override
  String get lintRule => 'avoid_relative_lib_imports';

  @override
  String get testFilePath => '$testPackageLibPath/folder/test.dart';

  test_packageImport() async {
    newFile('$testPackageRootPath/lib/other.dart');
    await assertNoDiagnostics(
      r'''
// ignore: unused_import
import 'package:test/other.dart';
''',
    );
  }

  test_absolutePath() async {
    var filePath = '$testPackageRootPath/lib/other.dart';
    newFile(filePath);
    await assertDiagnostics(
      '''
// ignore: unused_import
import '$filePath';
''',
      [
        lint('avoid_relative_lib_imports', 32, filePath.length + 2),
        // TODO(dantup): Why???
        error(CompileTimeErrorCode.URI_DOES_NOT_EXIST, 32, filePath.length + 2),
      ],
    );
  }

  @FailingTest(
    issue: 'https://github.com/dart-lang/sdk/issues/44673',
    reason: 'Imports with ../lib do not resolve. '
        'Remove test_relativePath_explicitLib2 when this annotation is removed.',
  )
  test_relativePath_explicitLib() async {
    var filePath = '$testPackageRootPath/lib/other.dart';
    newFile(filePath);
    await assertDiagnostics(
      '''
// ignore: unused_import
import '../../lib/other.dart';
''',
      [
        lint('avoid_relative_lib_imports', 32, 22),
      ],
    );
  }

  test_relativePath_explicitLib2() async {
    // This test is a copy of test_relativePath_explicitLib but with
    // the (unwanted) uri_does_not_exist error ignored, to allow the lint to
    // be tested while that test is marked @FailingTest.
    // When @FailingTest is removed from that test, this one can be removed.
    var filePath = '$testPackageRootPath/lib/other.dart';
    newFile(filePath);
    await assertDiagnostics(
      '''
// ignore: unused_import, uri_does_not_exist
import '../../lib/other.dart';
''',
      [
        lint('avoid_relative_lib_imports', 52, 22),
      ],
    );
  }

  test_relativePath_sibling() async {
    newFile('$testPackageRootPath/lib/folder/other.dart');
    await assertDiagnostics(
      '''
// ignore: unused_import
import 'other.dart';
''',
      [
        lint('avoid_relative_lib_imports', 32, 12),
      ],
    );
  }

  test_relativePath_parent() async {
    newFile('$testPackageRootPath/lib/other.dart');
    await assertDiagnostics(
      '''
// ignore: unused_import
import '../other.dart';
''',
      [
        lint('avoid_relative_lib_imports', 32, 15),
      ],
    );
  }

  test_relativePath_child() async {
    newFile('$testPackageRootPath/lib/folder/folder2/other.dart');
    await assertDiagnostics(
      '''
// ignore: unused_import
import 'folder2/other.dart';
''',
      [
        lint('avoid_relative_lib_imports', 32, 20),
      ],
    );
  }
}
