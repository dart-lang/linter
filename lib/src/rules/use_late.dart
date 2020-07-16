// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../util/dart_type_utilities.dart';

const _desc = r'Use late for private members with non-nullable type.';

const _details = r'''

Use late for private members with non-nullable type to avoid null checks.

**BAD:**
```
int? _i;
m() {
  _i!.abs();
}
```

**GOOD:**
```
late int _i;
m() {
  _i.abs();
}
```

''';

class UseLate extends LintRule implements NodeLintRule {
  UseLate()
      : super(
          name: 'use_late',
          description: _desc,
          details: _details,
          maturity: Maturity.experimental,
          group: Group.style,
        );

  @override
  void registerNodeProcessors(NodeLintRegistry registry,
      [LinterContext context]) {
    final visitor = _Visitor(this, context);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends RecursiveAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final LintRule rule;
  final LinterContext context;

  CompilationUnit _compilationUnit;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    if (node.featureSet.isEnabled(Feature.non_nullable)) {
      _compilationUnit = node;
      super.visitCompilationUnit(node);
    }
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    for (var variable in node.fields.variables) {
      if (Identifier.isPrivateName(
              (node.parent as ClassOrMixinDeclaration).name.name) ||
          Identifier.isPrivateName(variable.name.name)) {
        _visit(variable);
      }
    }
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (var variable in node.variables.variables) {
      if (Identifier.isPrivateName(variable.name.name)) {
        _visit(variable);
      }
    }
  }

  void _visit(VariableDeclaration variable) {
    if (variable.isLate) {
      return;
    }
    if (variable.isSynthetic) {
      return;
    }
    if (context.typeSystem.isNonNullable(variable.declaredElement.type)) {
      return;
    }
    final myVisitor = _MyVisitor(context, variable);
    myVisitor.visitCompilationUnit(_compilationUnit);
    if (myVisitor.lateable) {
      rule.reportLint(variable);
    }
  }
}

class _MyVisitor extends UnifyingAstVisitor<void> {
  _MyVisitor(this.context, this.variable);

  final LinterContext context;
  final VariableDeclaration variable;
  bool lateable = true;

  @override
  void visitNode(AstNode node) {
    if (!lateable) {
      return;
    }
    if (node.offset != variable.offset &&
        DartTypeUtilities.getCanonicalElementFromIdentifier(node) ==
            variable.declaredElement) {
      var parent = node.parent;
      while (parent is ParenthesizedExpression) {
        parent = parent.parent;
      }
      if (parent is PostfixExpression &&
          parent.operand == node &&
          parent.operator.type == TokenType.BANG) {
        // ok non-null access
      } else if (parent is AssignmentExpression &&
          parent.operator.type == TokenType.EQ &&
          context.typeSystem.isNonNullable(parent.rightHandSide.staticType)) {
        // ok non-null access
      } else {
        lateable = false;
      }
    }
    super.visitNode(node);
  }
}
