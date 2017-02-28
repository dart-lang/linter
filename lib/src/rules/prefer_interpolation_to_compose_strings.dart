// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.prefer_interpolation_to_compose_strings;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Use interpolation to compose strings and values.';

const _details = r'''

**PREFER** using interpolation to compose strings and values.

**BAD:**
```
'Hello, ' + name + '! You are ' + (year - birth) + ' years old.';
```

**GOOD:**
```
'Hello, $name! You are ${year - birth} years old.';
```

''';

class PreferInterpolationToComposeStrings extends LintRule {
  _Visitor _visitor;
  PreferInterpolationToComposeStrings()
      : super(
            name: 'prefer_interpolation_to_compose_strings',
            description: _desc,
            details: _details,
            group: Group.style) {
    _visitor = new _Visitor(this);
  }

  @override
  AstVisitor getVisitor() => _visitor;
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;
  _Visitor(this.rule);

  @override
  visitBinaryExpression(BinaryExpression node) {
    if (node.operator.type.lexeme == '+') {
      if (node.leftOperand is StringLiteral &&
          node.rightOperand is StringLiteral) {
        return;
      }
      if (node.leftOperand.staticType.name == 'String' ||
          node.rightOperand.staticType.name == 'String') {
        rule.reportLintForToken(node.operator);
      }
    }
  }
}
