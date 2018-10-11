// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/util/dart_type_utilities.dart';

const _desc = r'Do not loose voidness.';

const _details = r'''

**DO** not loose voidness. This is likely to lead to a runtime error.

**BAD:**

```dart
List<void> x;
List<int> y = x;
```

```dart
List<void> x;
List<Object> y = x;
```

''';

class VoidnessPropagation extends LintRule implements NodeLintRule {
  VoidnessPropagation()
      : super(
            name: 'voidness_propagation',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry) {
    final visitor = new _Visitor(this);
    registry.addAssignmentExpression(this, visitor);
    registry.addExpressionFunctionBody(this, visitor);
    registry.addInstanceCreationExpression(this, visitor);
    registry.addMethodDeclaration(this, visitor);
    registry.addMethodInvocation(this, visitor);
    registry.addReturnStatement(this, visitor);
    registry.addVariableDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule);

  final LintRule rule;

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    final type = node.leftHandSide?.staticType;
    _check(type, node.rightHandSide?.staticType, node.rightHandSide);
  }

  @override
  void visitExpressionFunctionBody(ExpressionFunctionBody node) {
    DartType returnType;
    if (node?.parent?.parent is FunctionDeclaration) {
      returnType = (node.parent.parent as FunctionDeclaration).returnType?.type;
    } else if (node?.parent is MethodDeclaration) {
      returnType = (node.parent as MethodDeclaration).returnType?.type;
    }
    _check(returnType, node.expression.staticType, node.expression);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final args = node.argumentList.arguments;
    final parameters = node.staticElement?.parameters;
    if (parameters != null) {
      _checkArgs(args, parameters);
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final inheritedMethod = DartTypeUtilities.lookUpInheritedMethod(node);
    if (inheritedMethod != null) {
      _check(inheritedMethod.returnType, node.returnType?.type, node.returnType);
    } else {
      for (final e in DartTypeUtilities.overridenMethods(node)) {
        _check(e.returnType, node.returnType?.type, node.returnType);
      }
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final type = node.staticInvokeType;
    if (type is FunctionType) {
      final args = node.argumentList.arguments;
      final parameters = type.parameters;
      _checkArgs(args, parameters);
    }
  }

  @override
  void visitReturnStatement(ReturnStatement node) {
    final parent = node.getAncestor((e) =>
        e is FunctionExpression ||
        e is MethodDeclaration ||
        e is FunctionDeclaration);
    if (parent is FunctionExpression) {
      final type = parent.staticType;
      if (type is FunctionType) {
        _check(type.returnType, node.expression?.staticType, node.expression);
      }
    } else if (parent is MethodDeclaration) {
      _check(parent.declaredElement.returnType, node.expression?.staticType,
          node.expression);
    } else if (parent is FunctionDeclaration) {
      _check(parent.declaredElement.returnType, node.expression?.staticType,
          node.expression);
    }
  }

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    if (node.initializer != null) {
      _check((node.parent as VariableDeclarationList).type?.type,
          node.initializer.staticType, node.initializer);
    }
  }

  void _check(DartType expectedType, DartType type, AstNode node) {
    if (expectedType == null || type == null) {
      return;
    } else if (expectedType is FunctionType && type is FunctionType) {
      _check(expectedType.returnType, type.returnType, node);
    } else if (type is InterfaceType &&
        expectedType is InterfaceType &&
        type != expectedType &&
        type.element == expectedType.element) {
      for (var i = 0; i < type.typeArguments.length; i++) {
        if (type.typeArguments[i].isVoid &&
            !expectedType.typeArguments[i].isVoid) {
          rule.reportLint(node);
          return;
        }
      }
    }
  }

  void _checkArgs(
      NodeList<Expression> args, List<ParameterElement> parameters) {
    for (final arg in args) {
      final parameterElement = arg.staticParameterElement;
      if (parameterElement != null) {
        final type = parameterElement.type;
        final expression = arg is NamedExpression ? arg.expression : arg;
        _check(type, expression?.staticType, expression);
      }
    }
  }
}
