// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../rule_test_support.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(DanglingLibraryDocCommentsTest);
  });
}

@reflectiveTest
class DanglingLibraryDocCommentsTest extends LintRuleTest {
  @override
  String get lintRule => 'dangling_library_doc_comments';

  test_doc_comment_above_declaration() async {
    await assertDiagnostics(
      r'''
/// Doc comment.

class C {}
''',
      [lint(0, 16)],
    );
  }

  test_doc_comment_above_declaration_ending_in_reference() async {
    await assertNoDiagnostics(r'''
/// Doc comment [C]
class C {}
''');
  }

  test_doc_comment_above_declaration_with_annotation() async {
    await assertNoDiagnostics(r'''
/// Doc comment.
@deprecated
class C {}
''');
  }

  test_doc_comment_above_declaration_with_other_comment1() async {
    await assertNoDiagnostics(r'''
/// Doc comment.
// Comment.
class C {}
''');
  }

  test_doc_comment_above_declaration_with_other_comment2() async {
    await assertDiagnostics(
      r'''
/// Doc comment.

// Comment.
class C {}
''',
      [lint(0, 16)],
    );
  }

  test_doc_comment_above_declaration_with_other_comment3() async {
    await assertDiagnostics(
      r'''
/// Doc comment.
// Comment.

class C {}
''',
      [lint(0, 16)],
    );
  }

  test_doc_comment_above_declaration_with_other_comment4() async {
    await assertNoDiagnostics(r'''
/// Doc comment.
// Comment.
/* Comment 2. */
class C {}
''');
  }

  test_doc_comment_at_end_of_file() async {
    await assertDiagnostics(
      r'''
/// Doc comment with [int].
''',
      [lint(0, 27)],
    );
  }

  test_doc_comment_attached_to_declaration() async {
    await assertNoDiagnostics(r'''
/// Doc comment.
class C {}
''');
  }

  test_doc_comment_on_first_directive() async {
    await assertDiagnostics(
      r'''
/// Doc comment.
export 'dart:math';
''',
      [lint(0, 16)],
    );
  }

  test_doc_comment_on_later_directive() async {
    await assertNoDiagnostics(r'''
export 'dart:math';
/// Doc comment for some reason.
export 'dart:io';
''');
  }

  test_doc_comment_on_library_directive() async {
    await assertNoDiagnostics(r'''
/// Doc comment.
library l;
''');
  }
}
