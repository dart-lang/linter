// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Use null aware access with other null aware expressions.';

const _details = r'''

**DO** Use null aware access with other null aware expressions.

**BAD:**
```
a?.p.m();
```

**GOOD:**
```
a?.p?.m();
```

''';

class UseNullAwareAccess extends LintRule {
  UseNullAwareAccess()
      : super(
            name: 'use_null_aware_access',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  AstVisitor getVisitor() => new Visitor(this);
}

class Visitor extends SimpleAstVisitor {
  Visitor(this.rule);

  final LintRule rule;

  @override
  visitMethodInvocation(MethodInvocation node) => _visit(node);

  @override
  visitPropertyAccess(PropertyAccess node) => _visit(node);

  _visit(Expression node) {
    if (node is MethodInvocation && node.operator?.lexeme == '?.' ||
        node is PropertyAccess && node.operator?.lexeme == '?.') {
      var parent = node.parent;
      while (parent is ParenthesizedExpression) {
        parent = parent.parent;
      }

      if (parent is CascadeExpression) {
        parent = parent.childEntities.skip(1).first;
      }

      if (parent is MethodInvocation && parent.operator.lexeme != '?.') {
        rule.reportLintForToken(parent.operator);
        return;
      }
      if (parent is PropertyAccess && parent.operator.lexeme != '?.') {
        rule.reportLintForToken(parent.operator);
        return;
      }
      if (parent is BinaryExpression &&
          !['??', '==', '!='].contains(parent.operator.lexeme)) {
        rule.reportLintForToken(parent.operator);
        return;
      }
      if (parent is IfStatement && parent.condition == node) {
        rule.reportLint(node);
        return;
      }
      if (parent is ConditionalExpression && parent.condition == node) {
        rule.reportLint(node);
        return;
      }
    }
  }
}
