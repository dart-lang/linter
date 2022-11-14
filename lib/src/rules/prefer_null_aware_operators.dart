// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'Prefer using null aware operators.';

const _details = r'''
**PREFER** using null aware operators instead of null checks in conditional
expressions.

**BAD:**
```dart
v = a == null ? null : a.b;
```

**GOOD:**
```dart
v = a?.b;
```

''';

class PreferNullAwareOperators extends LintRule {
  static const LintCode code = LintCode(
      'prefer_null_aware_operators',
      "Use the null-aware operator '?.' rather than an explicit 'null' "
          'comparison.',
      correctionMessage: "Try using '?.'.");

  PreferNullAwareOperators()
      : super(
            name: 'prefer_null_aware_operators',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  LintCode get lintCode => code;

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addConditionalExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    var condition = node.condition;
    if (condition is BinaryExpression &&
        (condition.operator.type == TokenType.EQ_EQ ||
            condition.operator.type == TokenType.BANG_EQ)) {
      // ensure pattern `xx == null ? null : yy` or `xx != null ? yy : null`
      if (condition.operator.type == TokenType.EQ_EQ) {
        if (node.thenExpression is! NullLiteral) {
          return;
        }
      } else {
        if (node.elseExpression is! NullLiteral) {
          return;
        }
      }

      // ensure condition is a null check
      Expression expression;
      if (condition.leftOperand is NullLiteral) {
        expression = condition.rightOperand;
      } else if (condition.rightOperand is NullLiteral) {
        expression = condition.leftOperand;
      } else {
        return;
      }

      Expression? exp = condition.operator.type == TokenType.EQ_EQ
          ? node.elseExpression
          : node.thenExpression;
      while (exp is PrefixedIdentifier ||
          exp is MethodInvocation ||
          exp is PropertyAccess) {
        if (exp is PrefixedIdentifier) {
          exp = exp.prefix;
        } else if (exp is MethodInvocation) {
          exp = exp.target;
        } else if (exp is PropertyAccess) {
          exp = exp.target;
        }
        if (exp.toString() == expression.toString()) {
          rule.reportLint(node);
        }
      }
    }
  }
}
