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

  test_relativePath_explicitLib() async {
    var filePath = '$testPackageRootPath/lib/other.dart';
    newFile(filePath);
    await assertDiagnostics(
      '''
// ignore: unused_import
import '../lib/other.dart';
''',
      [
        lint('avoid_relative_lib_imports', 32, 19),
        // TODO(dantup): Why???
        error(CompileTimeErrorCode.URI_DOES_NOT_EXIST, 32, 19),
      ],
    );
  }

  test_relativePath_resolvesToLib() async {
    newFile('$testPackageRootPath/lib/other.dart');
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
}
