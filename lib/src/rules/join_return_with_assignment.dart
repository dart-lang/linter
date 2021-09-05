// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../util/dart_type_utilities.dart';

const _desc = r'Join return statement with assignment when possible.';

const _details = r'''

**DO** join return statement with assignment when possible.

**BAD:**
```dart
class A {
  B _lazyInstance;
  static B get instance {
    _lazyInstance ??= B(); // LINT
    return _lazyInstance;
  }
}
```

**GOOD:**
```dart
class A {
  B _lazyInstance;
  static B get instance => _lazyInstance ??= B();
}
```

''';

Expression? _getExpressionFromAssignmentStatement(Statement node) {
  var visitor = _AssignmentStatementVisitor();
  node.accept(visitor);
  return visitor.expression;
}

Expression? _getExpressionFromReturnStatement(Statement node) =>
    node is ReturnStatement ? node.expression : null;

class JoinReturnWithAssignment extends LintRule {
  JoinReturnWithAssignment()
      : super(
            name: 'join_return_with_assignment',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addBlock(this, visitor);
  }
}

class _AssignmentStatementVisitor extends SimpleAstVisitor {
  Expression? expression;
  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    expression = node.leftHandSide;
  }

  @override
  void visitExpressionStatement(ExpressionStatement statement) {
    statement.expression.accept(this);
  }

  @override
  void visitParenthesizedExpression(ParenthesizedExpression node) {
    node.unParenthesized.accept(this);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    expression = node.operand;
  }

  @override
  void visitPrefixExpression(PrefixExpression node) {
    expression = node.operand;
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitBlock(Block node) {
    var statements = node.statements;
    var length = statements.length;
    if (length < 2) {
      return;
    }
    var secondLastStatement = statements[length - 2];
    var lastStatement = statements.last;
    var secondLastExpression =
        _getExpressionFromAssignmentStatement(secondLastStatement);
    var lastExpression = _getExpressionFromReturnStatement(lastStatement);

    // In this case, the last statement was not a return statement with a
    // simple target.
    if (lastExpression == null) {
      return;
    }

    Expression? thirdLastExpression;
    if (length >= 3) {
      var thirdLastStatement = statements[length - 3];
      thirdLastExpression =
          _getExpressionFromAssignmentStatement(thirdLastStatement);
    }
    if (!DartTypeUtilities.canonicalElementsFromIdentifiersAreEqual(
            secondLastExpression, thirdLastExpression) &&
        DartTypeUtilities.canonicalElementsFromIdentifiersAreEqual(
            lastExpression, secondLastExpression)) {
      rule.reportLint(secondLastStatement);
    }
  }
}
