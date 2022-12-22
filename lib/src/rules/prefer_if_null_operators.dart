// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'Prefer using if null operators.';

const _details = r'''
**PREFER** using if null operators instead of null checks in conditional
expressions.

**BAD:**
```dart
v = a == null ? b : a;
```

**GOOD:**
```dart
v = a ?? b;
```

''';

class PreferIfNullOperators extends LintRule {
  static const LintCode code = LintCode('prefer_if_null_operators',
      "Use the '??' operator rather than '?:' when testing for 'null'.",
      correctionMessage: "Try rewriting the code to use '??'.");

  PreferIfNullOperators()
      : super(
            name: 'prefer_if_null_operators',
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
      // ensure condition is a null check
      Expression expression;
      if (condition.leftOperand is NullLiteral) {
        expression = condition.rightOperand;
      } else if (condition.rightOperand is NullLiteral) {
        expression = condition.leftOperand;
      } else {
        return;
      }

      var exp = condition.operator.type == TokenType.EQ_EQ
          ? node.elseExpression
          : node.thenExpression;
      if (exp.toString() == expression.toString()) {
        rule.reportLint(node);
      }
    }
  }
}
