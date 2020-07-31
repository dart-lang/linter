// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../analyzer.dart';

const _desc = r'Unnecessary null check.';

const _details = r'''

Don't apply null check when nullable value is accepted.

**BAD:**
```
f(int? i);
m() {
  int? j;
  f(j!);
}

```

**GOOD:**
```
f(int? i);
m() {
  int? j;
  f(j);
}
```

''';

class UnnecessaryNullCheck extends LintRule implements NodeLintRule {
  UnnecessaryNullCheck()
      : super(
            name: 'unnecessary_null_check',
            description: _desc,
            details: _details,
            maturity: Maturity.experimental,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry,
      [LinterContext context]) {
    final visitor = _Visitor(this, context);
    registry.addPostfixExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final LintRule rule;
  final LinterContext context;

  @override
  void visitPostfixExpression(PostfixExpression node) {
    if (node.operator.type != TokenType.BANG) return;

    final parent = node.unParenthesized.parent;
    DartType expectedType;
    // in variable declaration
    if (parent is VariableDeclaration) {
      expectedType = parent.declaredElement.type;
    }
    // as named parameter of function
    if (parent is NamedExpression && parent.parent is ArgumentList) {
      final target = _lookupFunctionTypedElement(parent.parent.parent);
      if (target != null) {
        expectedType = target.parameters
            .singleWhere((e) => e.isNamed && e.name == parent.name.label.name)
            .type;
      }
    }
    // as positional parameter of function
    if (parent is ArgumentList) {
      final target = _lookupFunctionTypedElement(parent.parent);
      if (target is FunctionTypedElement) {
        final index = parent.arguments
            .where((e) => e is! NamedExpression)
            .toList()
            .indexOf(node.unParenthesized);
        expectedType =
            target.parameters.where((e) => !e.isNamed).toList()[index].type;
      }
    }
    // as right member of binary operator
    if (parent is BinaryExpression &&
        parent.rightOperand == node.unParenthesized) {
      expectedType = parent.staticElement.parameters.first.type;
    }

    if (expectedType != null && context.typeSystem.isNullable(expectedType)) {
      rule.reportLint(node);
    }
  }

  FunctionTypedElement _lookupFunctionTypedElement(AstNode node) {
    if (node is InvocationExpression) {
      return node.staticInvokeType.element as FunctionTypedElement;
    }
    if (node is InstanceCreationExpression) {
      return node.constructorName.staticElement;
    }
    return null;
  }
}
