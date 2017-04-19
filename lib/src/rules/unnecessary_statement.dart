// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.unnecessary_statement;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/util/dart_type_utilities.dart';

const _desc =
    r"Don't write unnecessary statements neither use getters with side-effect.";

const _details = r'''

**DON'T** use unnecessary statements neither use getters with side-effect.

**BAD:**
```
void main() {
  int a;
  a; // LINT
}
```

**GOOD:**
```
void main() {
  int a;
  foo(a);
}
```

''';

class UnnecessaryStatement extends LintRule {
  _Visitor _visitor;
  UnnecessaryStatement()
      : super(
            name: 'unnecessary_statement',
            description: _desc,
            details: _details,
            group: Group.style) {
    _visitor = new _Visitor(this);
  }

  @override
  AstVisitor getVisitor() => _visitor;
}

class _UnnecessaryStatementVisitor extends UnifyingAstVisitor {
  var isUnnecessaryStatement = true;

  @override
  visitAssignmentExpression(AssignmentExpression node) {
    isUnnecessaryStatement = false;
  }

  @override
  visitBinaryExpression(BinaryExpression node) {
    if (!isUnnecessaryStatement) {
      return;
    }
    if (node.operator.type == TokenType.EQ_EQ ||
        node.operator.type == TokenType.BANG_EQ) {
      if (DartTypeUtilities.isNullLiteral(node.leftOperand)) {
        node.rightOperand.accept(this);
      } else if (DartTypeUtilities.isNullLiteral(node.rightOperand)) {
        node.leftOperand.accept(this);
      } else {
        isUnnecessaryStatement = false;
      }
    } else if (node.operator.isUserDefinableOperator) {
      isUnnecessaryStatement = false;
    } else {
      visitNode(node);
    }
  }

  @override
  visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    isUnnecessaryStatement = false;
  }

  @override
  visitIndexExpression(IndexExpression node) {
    isUnnecessaryStatement = false;
  }

  @override
  visitInstanceCreationExpression(InstanceCreationExpression node) {
    isUnnecessaryStatement = false;
  }

  @override
  visitMethodInvocation(MethodInvocation node) {
    isUnnecessaryStatement = false;
  }

  @override
  visitNode(AstNode node) {
    if (isUnnecessaryStatement) {
      node.visitChildren(this);
    }
  }

  @override
  visitParenthesizedExpression(ParenthesizedExpression node) {
    node.unParenthesized.accept(this);
  }

  @override
  visitPostfixExpression(PostfixExpression node) {
    isUnnecessaryStatement = false;
  }

  @override
  visitPrefixedIdentifier(PrefixedIdentifier node) {
    isUnnecessaryStatement = false;
  }

  @override
  visitPrefixExpression(PrefixExpression node) {
    isUnnecessaryStatement = false;
  }

  @override
  visitRethrowExpression(RethrowExpression node) {
    isUnnecessaryStatement = false;
  }

  @override
  visitThrowExpression(ThrowExpression node) {
    isUnnecessaryStatement = false;
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;
  _Visitor(this.rule);

  @override
  visitExpressionStatement(ExpressionStatement node) {
    final visitor = new _UnnecessaryStatementVisitor();
    node.expression.accept(visitor);
    if (visitor.isUnnecessaryStatement) {
      rule.reportLint(node);
    }
  }
}
