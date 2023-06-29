// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'Remove unnecessary backslashes in strings.';

const _details = r'''
Remove unnecessary backslashes in strings.

**BAD:**
```dart
'this string contains 2 \"double quotes\" ';
"this string contains 2 \'single quotes\' ";
```

**GOOD:**
```dart
'this string contains 2 "double quotes" ';
"this string contains 2 'single quotes' ";
```

''';

class UnnecessaryStringEscapes extends LintRule {
  bool get canUseParsedResult => true;

  static const LintCode code = LintCode(
      'unnecessary_string_escapes', 'Unnecessary escape in string literal.',
      correctionMessage: "Remove the '\\' escape.");

  UnnecessaryStringEscapes()
      : super(
            name: 'unnecessary_string_escapes',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  LintCode get lintCode => code;

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addSimpleStringLiteral(this, visitor);
    registry.addStringInterpolation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  /// The special escaped chars listed in language specification
  static const allowedEscapedChars = [
    '"',
    "'",
    r'$',
    r'\',
    'n',
    'r',
    'f',
    'b',
    't',
    'v',
    'x',
    'u',
  ];

  final LintRule rule;

  _Visitor(this.rule);

  void visitLexeme(
    Token token, {
    required bool isSingleQuoted,
    required bool isMultiline,
    required int contentsOffset,
    required int contentsEnd,
  }) {
    // For multiline string we keep the list on pending quotes.
    // Starting from 3 consecutive quotes, we allow escaping.
    // index -> escaped
    var pendingQuotes = <int, bool>{};
    void checkPendingQuotes() {
      if (isMultiline && pendingQuotes.length < 3) {
        var escapeIndexes =
            pendingQuotes.entries.where((e) => e.value).map((e) => e.key);
        for (var index in escapeIndexes) {
          // case for '''___\'''' : without last backslash it leads a parsing error
          if (contentsEnd != token.end && index + 2 == contentsEnd) continue;
          rule.reporter.reportErrorForOffset(rule.lintCode, index, 1);
        }
      }
    }

    var lexeme = token.lexeme
        .substring(contentsOffset - token.offset, contentsEnd - token.offset);
    for (var i = 0; i < lexeme.length; i++) {
      var current = lexeme[i];
      var escaped = false;
      if (current == r'\' && i < lexeme.length - 1) {
        escaped = true;
        i += 1;
        current = lexeme[i];
        if (isSingleQuoted && current == '"' ||
            !isSingleQuoted && current == "'" ||
            !allowedEscapedChars.contains(current)) {
          rule.reporter
              .reportErrorForOffset(rule.lintCode, contentsOffset + i - 1, 1);
        }
      }
      if (isSingleQuoted ? current == "'" : current == '"') {
        pendingQuotes[contentsOffset + i - (escaped ? 1 : 0)] = escaped;
      } else {
        checkPendingQuotes();
        pendingQuotes.clear();
      }
    }
    checkPendingQuotes();
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (node.isRaw) return;

    visitLexeme(
      node.literal,
      isSingleQuoted: node.isSingleQuoted,
      isMultiline: node.isMultiline,
      contentsOffset: node.contentsOffset,
      contentsEnd: node.contentsEnd,
    );
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    for (var element in node.elements.whereType<InterpolationString>()) {
      visitLexeme(
        element.contents,
        isSingleQuoted: node.isSingleQuoted,
        isMultiline: node.isMultiline,
        contentsOffset: element.contentsOffset,
        contentsEnd: element.contentsEnd,
      );
    }
  }
}
