// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Avoid escape sequences without a well-defined meaning.';

const _details = r'''

**DO** only use well-defined escape sequences (\n, \r, \f, \b, \t, \v, \x, \u, \\, \', \") in String literals.
Dart ignores unknown escape sequences and simply uses the following characters as is, which can lead to unexpected results.
They should also only be used when necessary, for example, \' should only be used in single quoted strings.


**BAD:**
```
print('You can escape double quotes like this: \"') // Prints 'You can escape double quotes like this: "'
```
```
print('For some reason we want to print \z.') // Prints 'For some reason we want to print z.'
```

**GOOD:**
```
print('You can escape double quotes like this: \\"') // Prints 'You can escape double quotes like this: \"'
```
```
print('For some reason we want to print \\z.') // Prints 'For some reason we want to print \z.'
```

''';

class AvoidUndefinedAndUnnecessaryEscapeSequences extends LintRule implements NodeLintRuleWithContext {
  AvoidUndefinedAndUnnecessaryEscapeSequences()
      : super(
            name: 'avoid_undefined_and_unnecessary_escape_sequences',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry, [LinterContext context]) {
    final visitor = _Visitor(this);
    registry.addSimpleStringLiteral(this, visitor);
    registry.addInterpolationString(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  static final definedEscapes = Set<String>.from(['n', 'r', 'f', 'b', 't', 'v', 'x', 'u', r'\', "\'", '"']);
  final LintRule rule;

  _Visitor(this.rule);

  bool _containsUndefinedOrUnnecessaryEscapeSequence(String str) {
    final otherQuote = str[0] == "'" ? '"' : "'";
    var slashIndex = str.indexOf(r'\');
    while (slashIndex >= 0) {
      if (!definedEscapes.contains(str[slashIndex + 1])) {
        return true;
      }
      if (str[slashIndex + 1] == otherQuote) {
        return true;
      }
      slashIndex = str.indexOf(r'\', slashIndex + 1);
    }
    return false;
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    if (!node.isRaw && _containsUndefinedOrUnnecessaryEscapeSequence(node.beginToken.lexeme)) {
      rule.reportLint(node);
    }
  }

  @override
  void visitInterpolationString(InterpolationString node) {
    if (_containsUndefinedOrUnnecessaryEscapeSequence(node.contents.lexeme)) {
      rule.reportLint(node);
    }
  }
}
