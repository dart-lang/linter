// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

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

class _Visitor extends UnifyingAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final LintRule rule;
  final LinterContext context;

  final lateables = <VariableDeclaration>[];
  final nullableAccess = <AstNode, Element>{};

  @override
  void visitCompilationUnit(CompilationUnit node) {
    if (node.featureSet.isEnabled(Feature.non_nullable)) {
      super.visitCompilationUnit(node);
      _checkAccess();
    }
  }

  @override
  void visitNode(AstNode node) {
    var element = DartTypeUtilities.getCanonicalElementFromIdentifier(node);
    if (element != null) {
      var parent = node.parent;
      if (parent is Expression) {
        parent = (parent as Expression).unParenthesized;
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
        nullableAccess[node] = element;
      }
    }
    super.visitNode(node);
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    for (var variable in node.fields.variables) {
      final parent = node.parent;
      if (Identifier.isPrivateName(variable.name.name) ||
          _isPrivateNamedCompilationUnitMember(parent) ||
          _isPrivateExtension(parent)) {
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
    lateables.add(variable);
  }

  void _checkAccess() {
    for (var variable in lateables) {
      final lateable = nullableAccess.entries
          .where((e) =>
              e.value == variable.declaredElement &&
              e.key.offset != variable.offset)
          .isEmpty;
      if (lateable) {
        rule.reportLint(variable);
      }
    }
  }
}

bool _isPrivateNamedCompilationUnitMember(AstNode parent) =>
    parent is NamedCompilationUnitMember &&
    Identifier.isPrivateName(parent.name.name);

bool _isPrivateExtension(AstNode parent) =>
    parent is ExtensionDeclaration &&
    (parent.name == null || Identifier.isPrivateName(parent.name.name));
