// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

/// The maximum amount of lines that can be considered part of a single
/// summary line (like this one!).
const maxSummaryLines = 2;

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

/// Enforces that DartDoc blocks start with a single, brief line that ends in
/// a period.
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

  /// The summary line should be 'brief' according to the Dart recommendations,
  /// however 'brief' is not defined perfectly. Instead of enforcing a fixed
  /// number of characters, we just look at how many lines are part of the
  /// summary, and if we deem them to be too many (2 should be plenty), we fail
  /// the lint
  ///
  /// The above summary fails with all the checks that this lint adds, it has
  /// more than one sentence, is too long, and doesn't add a period at the end.
  ///
  /// It has it all!
  @override
  void visitComment(Comment node) {
    if (!node.isDocumentation || !node.tokens.first.lexeme.startsWith('///')) {
      // Ignore /** comments.
      return;
    }

    Iterable<Token> summary = _getSummary(node);

    if (!_endsWithPeriod(summary)) {
      Token last = summary.last;
      // Highlight the last character of the sentence...
      rule.reportLintForOffset(last.offset + last.lexeme.length, 1);
    }
    int? sentenceBreakOffset = _findSentenceBreak(summary);
    if (sentenceBreakOffset != null) {
      // Highlight the position of the period that is breaking the summary.
      rule.reportLintForOffset(sentenceBreakOffset, 1);
    }
    if (summary.length > maxSummaryLines) {
      // Highlight the extra lines.
      summary.skip(maxSummaryLines).forEach((token) {
        rule.reportLintForOffset(token.offset, 3);
      });
    }
  }
}

// Some utility functions

/// Removes the first triple slash of a `line` and returns its trimmed value.
String _trimSlashes(String line) => line.replaceFirst('///', '');

/// Determines if a token `tk` represents an empty comment line.
bool _isNotBlankLine(Token tk) => _trimSlashes(tk.lexeme).trim().isNotEmpty;

/// Retrieves the summary line of a [Comment] node.
///
/// This will take "lines" (tokens or actual strings) from the beginning of the
/// node until an empty line is found.
Iterable<Token> _getSummary(Comment node) =>
    node.tokens.takeWhile(_isNotBlankLine);

/// Checks that the last of the `lines` ends in a period.
bool _endsWithPeriod(Iterable<Token> tokens) =>
    tokens.last.lexeme.endsWith('.');

/// See: https://regexr.com/71rtq for docs and tests.
RegExp _sentenceBreak = RegExp(r'[^\.]+\.\s+[^\.]+');

/// Returns the offset of the token that contains a sentence break.
int? _findSentenceBreak(Iterable<Token> tokens) {
  for (Token tk in tokens) {
    RegExpMatch? match = _sentenceBreak.firstMatch(tk.lexeme);
    if (match != null) {
      return tk.offset + tk.lexeme.indexOf('.', match.start);
    }
  }
  return null;
}
