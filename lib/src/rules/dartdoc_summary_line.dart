// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: slash_for_doc_comments

import 'dart:convert';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

/// The maximum allowed length for a summary line.
const maxSummaryLength = 140;

const _desc =
    r'Start your DartDoc comment with a single, brief sentence that ends with a period.';

const _details = r'''
From [Effective Dart](https://dart.dev/guides/language/effective-dart/documentation#do-start-doc-comments-with-a-single-sentence-summary):

**DO** start doc comments with a single-sentence summary.

Start your doc comment with a brief, user-centric description ending with a
period. A sentence fragment is often sufficient. Provide just enough context
for the reader to orient themselves and decide if they should keep reading or
look elsewhere for the solution to their problem.

For example:

**GOOD:**
```dart
/// Deletes the file at [path] from the file system.
void delete(String path) {
  ...
}
```

**BAD:**
```dart
/// Depending on the state of the file system and the user's permissions,
/// certain operations may or may not be possible. If there is no file at
/// [path] or it can't be accessed, this function throws either [IOError]
/// or [PermissionError], respectively. Otherwise, this deletes the file.
void delete(String path) {
  ...
}
```

From [Effective Dart](https://dart.dev/guides/language/effective-dart/documentation#do-separate-the-first-sentence-of-a-doc-comment-into-its-own-paragraph):

**DO** separate the first sentence of a doc comment into its own paragraph.

Add a blank line after the first sentence to split it out into its own
paragraph. If more than a single sentence of explanation is useful, put the
rest in later paragraphs.

This helps you write a tight first sentence that summarizes the documentation.
Also, tools like dart doc use the first paragraph as a short summary in places
like lists of classes and members.

For example:

**GOOD:**
```dart
/// Deletes the file at [path].
///
/// Throws an [IOError] if the file could not be found. Throws a
/// [PermissionError] if the file is present but could not be deleted.
void delete(String path) {
  ...
}
```

**BAD:**
```dart
/// Deletes the file at [path]. Throws an [IOError] if the file could not
/// be found. Throws a [PermissionError] if the file is present but could
/// not be deleted.
void delete(String path) {
  ...
}
```
''';

/// Enforces that DartDoc blocks start with a single, brief line that ends in a period.
///
/// (Like the one above!)
class DartdocSummaryLine extends LintRule {
  DartdocSummaryLine()
      : super(
            name: 'dartdoc_summary_line',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addComment(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  /**
   * Visits a [Comment] node, and finds and validates its summary line.
   */
  @override
  void visitComment(Comment node) {
    if (!node.isDocumentation) {
      // Skip things that may not be proper dartdoc (like a /** */ comment)
      return;
    }

    List<String> summary = _getSummary(node).toList();

    // Should we enforce that summary.length == 1?
    if (!_endsWithPeriod(summary) ||
        summary.join(' ').length > maxSummaryLength) {
      // Highlight the offending comment
      rule.reportLintForOffset(node.offset, 3);
    }
  }
}

// Some utility functions

/**
 * Detects if a Comment starts with slash-star-star.
 *
 * This is a less common style for Dart Docs, but still [valid](https://dart.dev/guides/language/language-tour#documentation-comments).
 */
bool _isSlashStarStar(Comment node) =>
    node.tokens.first.lexeme.startsWith('/**');

/// Removes the first appearance of `prefix` from `line`, and trims the output.
String _trimPrefix(String line, String prefix) =>
    line.replaceFirst(prefix, '').trim();

/// Removes the first triple slash of a `line` and returns its trimmed value.
String _trimSlashes(String line) => _trimPrefix(line, '///');

/**
 * Removes the first asterisk of a `line` and and returns its trimmed value.
 *
 * (Like the ones that make this comment!)
 */
String _trimStars(String line) => _trimPrefix(line, ' *');

/// [String.isNotEmpty] so it can be torn off.
bool _isNotEmpty(String line) => line.isNotEmpty;

/// Retrieves the summary line of a [Comment] node.
///
/// This will take "lines" (tokens or actual strings) from the beginning of the
/// node until an empty line is found.
Iterable<String> _getSummary(Comment node) {
  if (_isSlashStarStar(node)) {
    // The first token contains the whole block comment... Split in lines, then
    // take as many as needed...
    LineSplitter splitter = LineSplitter();
    List<String> lines = splitter.convert(node.tokens.first.lexeme);
    return lines
        .sublist(1, lines.length - 1)
        .map(_trimStars)
        .takeWhile(_isNotEmpty);
  } else {
    return node.tokens
        .map((tk) => _trimSlashes(tk.lexeme))
        .takeWhile(_isNotEmpty);
  }
}

/// Checks that the last of the `lines` ends in a period.
bool _endsWithPeriod(Iterable<String> lines) => lines.last.endsWith('.');
