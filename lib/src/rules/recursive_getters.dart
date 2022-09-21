// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../analyzer.dart';
import '../extensions.dart';

const _desc = r'Property getter recursively returns itself.';

const _details = r'''
**DON'T** create recursive getters.

Recursive getters are getters which return themselves as a value.  This is
usually a typo.

**BAD:**
```dart
int get field => field; // LINT
```

**BAD:**
```dart
int get otherField {
  return otherField; // LINT
}
```

**GOOD:**
```dart
int get field => _field;
```

''';

class RecursiveGetters extends LintRule {
  RecursiveGetters()
      : super(
            name: 'recursive_getters',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
  }
}

/// Tests if a simple identifier is a recursive getter by looking at its parent.
class _RecursiveGetterParentVisitor extends SimpleAstVisitor<bool> {
  @override
  bool visitPropertyAccess(PropertyAccess node) =>
      node.target is ThisExpression;

  @override
  bool? visitSimpleIdentifier(SimpleIdentifier node) {
    var parent = node.parent;
    if (parent is ArgumentList ||
        parent is ConditionalExpression ||
        parent is ExpressionFunctionBody ||
        parent is ReturnStatement) {
      return true;
    }

    if (parent is PropertyAccess) {
      return parent.accept(this);
    }

    return false;
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  final visitor = _RecursiveGetterParentVisitor();

  _Visitor(this.rule);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    // getters have null arguments, methods have parameters, could be empty.
    if (node.functionExpression.parameters != null) {
      return;
    }

    var element = node.declaredElement2;
    _verifyElement(node.functionExpression, element);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    // getters have null arguments, methods have parameters, could be empty.
    if (node.parameters != null) {
      return;
    }

    var element = node.declaredElement2;
    _verifyElement(node.body, element);
  }

  void _verifyElement(AstNode node, ExecutableElement? element) {
    node
        .traverseNodesInDFS()
        .whereType<SimpleIdentifier>()
        .where(
            (n) => element == n.staticElement && (n.accept(visitor) ?? false))
        .forEach(rule.reportLint);
  }
}
