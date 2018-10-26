// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Avoid shadowing type parameters.';

const _details = r'''

**DO NOT** shadow type parameters.

**BAD:**
```
class A<T> {
  void fn<T>() {}
}
```

**GOOD:**
```
class A<T> {
  void fn<U>() {}
}
```

''';

class ShadowTypeParameters extends LintRule implements NodeLintRule {
  ShadowTypeParameters()
      : super(
            name: 'shadow_type_parameters',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry) {
    final visitor = _Visitor(this);
    registry.addMethodDeclaration(this, visitor);
    registry.addFunctionExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.typeParameters == null) {
      return;
    }

    // Static methods have nothing above them to shadow.
    if (!node.isStatic) {
      _checkAncestorParameters(node);
    }
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    if (node.typeParameters == null) {
      return;
    }

    _checkAncestorParameters(node);
  }

  // Check the ancestors of [node] for type parameter shadowing.
  _checkAncestorParameters(AstNode node) {
    TypeParameterList typeParameters = (node as dynamic).typeParameters;
    var parent = node.parent;

    // If node is the `functionExpression` of a FunctionDeclaration, we must
    // skip `node.parent`, or we will be comparing its type parameters with
    // themselves.
    if (node is FunctionExpression && node.parent is FunctionDeclaration) {
      parent = parent.parent;
    }

    while (parent != null) {
      if (parent is ClassDeclaration) {
        _checkForShadowing(typeParameters, parent.typeParameters);
      } else if (parent is MethodDeclaration) {
        _checkForShadowing(typeParameters, parent.typeParameters);
      } else if (parent is FunctionDeclaration) {
        _checkForShadowing(
            typeParameters, parent.functionExpression.typeParameters);
      }
      parent = parent.parent;
    }
  }

  // Check whether any of [typeParameters] shadow [ancestorTypeParameters].
  _checkForShadowing(TypeParameterList typeParameters,
      TypeParameterList ancestorTypeParameters) {
    var typeParameterIds = typeParameters.typeParameters.map((tp) => tp.name);
    var ancestorTypeParameterNames =
        ancestorTypeParameters.typeParameters.map((tp) => tp.name.name);
    var shadowingTypeParameters = typeParameterIds
        .where((tp) => ancestorTypeParameterNames.contains(tp.name));

    shadowingTypeParameters.forEach(rule.reportLint);
  }
}
