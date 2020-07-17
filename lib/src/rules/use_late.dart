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

Use late for private members with non-nullable type that are always expected to
be non-null. Thus it's clear that the field is not expected to be `null` and it
avoids null checks.

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

  CompilationUnitElement currentUnit;

  static final lateables =
      <CompilationUnitElement, List<VariableDeclaration>>{};
  static final nullableAccess = <CompilationUnitElement, Set<Element>>{};

  @override
  void visitCompilationUnit(CompilationUnit node) {
    if (node.featureSet.isEnabled(Feature.non_nullable)) {
      currentUnit = node.declaredElement;
      lateables.putIfAbsent(currentUnit, () => []);
      nullableAccess.putIfAbsent(currentUnit, () => {});

      super.visitCompilationUnit(node);

      final units = node.declaredElement.library.units;
      if (units.every(lateables.keys.contains)) {
        _checkAccess(units);

        // clean up
        units.forEach((unit) {
          lateables.remove(unit);
          nullableAccess.remove(unit);
        });
      }
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
      if (node is SimpleIdentifier && node.inDeclarationContext()) {
        // ok
      } else if (parent is PostfixExpression &&
          parent.operand == node &&
          parent.operator.type == TokenType.BANG) {
        // ok non-null access
      } else if (parent is AssignmentExpression &&
          parent.operator.type == TokenType.EQ &&
          context.typeSystem.isNonNullable(parent.rightHandSide.staticType)) {
        // ok non-null access
      } else {
        nullableAccess[currentUnit].add(element);
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
    lateables[currentUnit].add(variable);
  }

  void _checkAccess(List<CompilationUnitElement> units) {
    final allNullableAccess =
        units.expand((unit) => nullableAccess[unit]).toSet();
    for (final unit in units) {
      for (var variable in lateables[unit]) {
        if (!allNullableAccess.contains(variable.declaredElement)) {
          rule.reportLint(variable);
        }
      }
    }
  }
}

// see https://github.com/dart-lang/linter/pull/2189#issuecomment-660115569
// Ideally we need to also ensure that there are no instances of either the
// enclosing class or any subclass of the enclosing class that are ever
// accessible outside this library.
bool _isPrivateNamedCompilationUnitMember(AstNode parent) =>
    parent is NamedCompilationUnitMember &&
    Identifier.isPrivateName(parent.name.name);

bool _isPrivateExtension(AstNode parent) =>
    parent is ExtensionDeclaration &&
    (parent.name == null || Identifier.isPrivateName(parent.name.name));
