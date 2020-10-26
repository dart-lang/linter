// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'Unnecessary null check for non-nullable value.';

const _details = r'''

Unnecessary null check for non-nullable value in a opted-out library.

**BAD:**
```
nonNullable?.property;
if (nonNullable != null) {}
```

**GOOD:**
```
nonNullable.property;
```

''';

class WeakModeUnnecessaryNullChecks extends LintRule implements NodeLintRule {
  WeakModeUnnecessaryNullChecks()
      : super(
            name: 'weak_mode_unnecessary_null_checks',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    final visitor = _Visitor(this, context);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final LintRule rule;
  final LinterContext context;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    if (node.featureSet.isEnabled(Feature.non_nullable)) {
      return;
    }
    super.visitCompilationUnit(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (node.operator.type == TokenType.QUESTION_PERIOD &&
        context.typeSystem.isNonNullable(node.target.staticType)) {
      rule.reportLintForToken(node.operator);
    }
    super.visitPropertyAccess(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.operator?.type == TokenType.QUESTION_PERIOD &&
        context.typeSystem.isNonNullable(node.target.staticType)) {
      rule.reportLintForToken(node.operator);
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    if (node.operator.type == TokenType.QUESTION &&
        context.typeSystem.isNonNullable(node.operand.staticType)) {
      rule.reportLintForToken(node.operator);
    }
    super.visitPostfixExpression(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    final operands = [
      node.leftOperand,
      node.rightOperand,
    ].map((e) => e.unParenthesized).toList();
    if ((node.operator.type == TokenType.EQ_EQ ||
            node.operator.type == TokenType.BANG_EQ) &&
        operands.where((e) => e.staticType.isDartCoreNull).length == 1) {
      final operand = operands.firstWhere((e) => !e.staticType.isDartCoreNull);
      if (context.typeSystem.isNonNullable(operand.staticType)) {
        rule.reportLint(node);
      }
    }
    super.visitBinaryExpression(node);
  }
}
