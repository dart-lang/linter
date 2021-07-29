// Copyright (c) 2018, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../analyzer.dart';

const _desc = r'Avoid types as parameter names.';

const _details = r'''

**AVOID** using a parameter name that is the same as an existing type.

**BAD:**
```dart
m(f(int));
```

**GOOD:**
```dart
m(f(int v));
```

''';

class AvoidTypesAsParameterNames extends LintRule implements NodeLintRule {
  AvoidTypesAsParameterNames()
      : super(
            name: 'avoid_types_as_parameter_names',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this, context);
    registry.addFormalParameterList(this, visitor);
    registry.addCatchClause(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;
  final LinterContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitCatchClause(CatchClause node) {
    var parameter = node.exceptionParameter;
    if (parameter != null && _isTypeName(node, parameter)) {
      rule.reportLint(parameter);
    }
  }

  @override
  void visitFormalParameterList(FormalParameterList node) {
    for (var parameter in node.parameters) {
      var declaredElement = parameter.declaredElement;
      var identifier = parameter.identifier;
      if (declaredElement != null &&
          declaredElement is! FieldFormalParameterElement &&
          identifier != null &&
          _isTypeName(node, identifier)) {
        rule.reportLint(identifier);
      }
    }
  }

  bool _isTypeName(AstNode scope, SimpleIdentifier node) {
    // TODO (asashour): the below sections should be removed once
    // https://github.com/dart-lang/sdk/issues/46753 is fixed
    var parent = scope.parent;
    if (parent is FunctionExpression &&
        _isTypeParameter(parent.typeParameters, node)) {
      return true;
    }
    var classDeclaration = parent?.thisOrAncestorOfType<ClassDeclaration>();
    if (classDeclaration != null &&
        _isTypeParameter(classDeclaration.typeParameters, node)) {
      return true;
    }
    if (parent is GenericFunctionType &&
        _isTypeParameter(parent.typeParameters, node)) {
      return true;
    }
    var result = context.resolveNameInScope(node.name, false, scope);
    if (result.isRequestedName) {
      var element = result.element;
      return element is ClassElement || element is TypeAliasElement;
    }
    return false;
  }

  bool _isTypeParameter(
          TypeParameterList? typeParameters, SimpleIdentifier node) =>
      typeParameters?.typeParameters
          .any((element) => element.name.name == node.name) ??
      false;
}
