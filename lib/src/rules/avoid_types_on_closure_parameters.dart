// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';

import '../analyzer.dart';

const _desc = r'Avoid annotating types for function expression parameters.';

const _details = r'''

From [effective dart](https://dart.dev/guides/language/effective-dart/design#dont-annotate-inferred-parameter-types-on-function-expressions):

**DON’T** annotate inferred parameter types on function expressions.

**BAD:**
```dart
var names = people.map((Person person) => person.name);
```

**GOOD:**
```dart
var names = people.map((person) => person.name);
```

''';

class AvoidTypesOnClosureParameters extends LintRule {
  AvoidTypesOnClosureParameters()
      : super(
            name: 'avoid_types_on_closure_parameters',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  List<String> get incompatibleRules => const ['always_specify_types'];

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this, context);
    registry.addFunctionExpression(this, visitor);
  }
}

class AvoidTypesOnClosureParametersVisitor extends SimpleAstVisitor<void> {
  LintRule rule;

  AvoidTypesOnClosureParametersVisitor(this.rule);

  @override
  void visitDefaultFormalParameter(DefaultFormalParameter node) {
    node.parameter.accept(this);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    if (node.parent is FunctionDeclaration) {
      return;
    }
    var parameterList = node.parameters?.parameters;
    if (parameterList != null) {
      for (var parameter in parameterList) {
        parameter.accept(this);
      }
    }
  }

  @override
  void visitFunctionTypedFormalParameter(FunctionTypedFormalParameter node) {
    rule.reportLint(node);
  }

  @override
  void visitSimpleFormalParameter(SimpleFormalParameter node) {
    var type = node.type;
    if (type is NamedType && type.name.name != 'dynamic') {
      rule.reportLint(node.type);
    }
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);
  final LintRule rule;
  final LinterContext context;

  @override
  void visitFunctionExpression(FunctionExpression node) {
    var staticParameterElement = node.staticParameterElement;
    var parent = node.parent;
    while (parent is ParenthesizedExpression) {
      parent = parent.parent;
    }
    DartType? expectedType;
    if (parent is AssignmentExpression) {
      expectedType = parent.writeType;
    } else if (parent is VariableDeclaration) {
      var parentParent = parent.parent;
      if (parentParent is VariableDeclarationList) {
        if (parentParent.type == null) {
          // type infered: allow types
          return;
        }
      }
      expectedType = parent.declaredElement?.type;
    } else if (parent is ReturnStatement || parent is ExpressionFunctionBody) {
      expectedType =
          node.thisOrAncestorOfType<FunctionDeclaration>()?.returnType?.type;
    } else if (staticParameterElement != null) {
      expectedType = staticParameterElement.type;
    } else if (parent is NamedExpression) {
      // TODO(a14n): remove this if-block once https://github.com/dart-lang/sdk/issues/45964 is fixed
      expectedType = parent.element?.type;
    }

    if (expectedType != null &&
        context.typeSystem.promoteToNonNull(expectedType) != node.staticType) {
      return;
    }
    var visitor = AvoidTypesOnClosureParametersVisitor(rule);
    visitor.visitFunctionExpression(node);
  }
}
