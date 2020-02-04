// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:meta/meta.dart';

import '../analyzer.dart';

const _desc = r'Remove unnecessary backslash in strings.';

const _details = r'''

Remove unnecessary backslash in strings.

**BAD:**
```
'this string contains 2 \"double quotes\" ';
"this string contains 2 \'single quotes\' ";
```

**GOOD:**
```
'this string contains 2 "double quotes" ';
"this string contains 2 'single quotes' ";
```

''';

class UnnecessaryEscapesInString extends LintRule implements NodeLintRule {
  UnnecessaryEscapesInString()
      : super(
            name: 'unnecessary_escapes_in_string',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry,
      [LinterContext context]) {
    final visitor = _Visitor(this);
    registry.addSimpleStringLiteral(this, visitor);
    registry.addStringInterpolation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (node.isRaw) return;

    visitLexeme(node.literal, isSingleQuoted: node.isSingleQuoted);
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    for (var element in node.elements.whereType<InterpolationString>()) {
      visitLexeme(element.contents, isSingleQuoted: node.isSingleQuoted);
    }
  }

  void visitLexeme(Token token, {@required bool isSingleQuoted}) {
    final lexeme = token.lexeme;
    for (var i = 0; i < lexeme.length; i++) {
      final current = lexeme[i];
      if (current == r'\') {
        i += 1;
        final next = lexeme[i];
        if (isSingleQuoted && next == '"' ||
            !isSingleQuoted && next == "'" ||
            !allowedEscapedChars.contains(next)) {
          rule.reporter
              .reportErrorForOffset(rule.lintCode, token.offset + i - 1, 1);
        }
      }
    }
  }

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
}
