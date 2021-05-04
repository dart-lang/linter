// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'Noop string calls.';

const _details = r'''

Some operation on String are idempotent and return the same string.

**BAD:**

```dart
f() {
  var s = 'hello';
  s + '';
  s * 1;
  s.toString();
  s.substring(0);
  s.padLeft(0);
  s.padRight(0);
}
```
''';

class NoopStringCalls extends LintRule implements NodeLintRule {
  NoopStringCalls()
      : super(
          name: 'noop_string_calls',
          description: _desc,
          details: _details,
          group: Group.style,
        );

  @override
  void registerNodeProcessors(
    NodeLintRegistry registry,
    LinterContext context,
  ) {
    var visitor = _Visitor(this, context);
    registry.addAdjacentStrings(this, visitor);
    registry.addBinaryExpression(this, visitor);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final LintRule rule;
  final LinterContext context;

  @override
  void visitAdjacentStrings(AdjacentStrings node) {
    for (var literal in node.strings) {
      if (literal.stringValue?.isEmpty ?? false) {
        rule.reportLint(literal);
      }
    }
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    if (!(node.leftOperand.staticType?.isDartCoreString ?? false)) return;

    var right = node.rightOperand;

    // string + ''
    if (node.operator.type == TokenType.PLUS &&
        right is StringLiteral &&
        (right.stringValue?.isEmpty ?? false)) {
      rule.reportLintForToken(node.operator);
      return;
    }

    // string * 1
    if (node.operator.type == TokenType.STAR &&
        right is IntegerLiteral &&
        right.value == 1) {
      rule.reportLintForToken(node.operator);
      return;
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (!(node.realTarget?.staticType?.isDartCoreString ?? false)) return;

    // string.toString()
    if (node.methodName.name == 'toString' &&
        context.typeSystem.isNonNullable(node.target!.staticType!)) {
      rule.reportLint(node.methodName);
      return;
    }

    // string.substring(0)
    if (node.methodName.name == 'substring' &&
        node.argumentList.arguments.length == 1) {
      var arg = node.argumentList.arguments.first;
      if (arg is IntegerLiteral && arg.value == 0) {
        rule.reportLint(node.methodName);
        return;
      }
    }

    // string.padLeft(0,*) or string.padRight(0,*)
    if (['padLeft', 'padRight'].contains(node.methodName.name)) {
      var firstArg = node.argumentList.arguments.first;
      if (firstArg is IntegerLiteral && firstArg.value == 0) {
        rule.reportLint(node.methodName);
        return;
      }
    }
  }
}
