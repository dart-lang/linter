// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../util/dart_type_utilities.dart';

const _desc = r"Don't ignore the value of lazy iterables.";

const _details = r'''
**DON'T** ignore the value of lazy iterables created by `iterable.map`. Since 
these iterables are lazily instantiated, the `map` function is not evaluated
until use which can be surprising.  Alternatively, consider preferring 
`forEach`.

**BAD:**
```dart
[1, 2, 3].map(print);
```

**GOOD:**
```dart
[1, 2, 3].forEach(print);
for (var v in [1, 2, 3]) {
  print(v);
}
```
''';

class UseIterables extends LintRule {
  UseIterables()
      : super(
            name: 'use_iterables',
            description: _desc,
            details: _details,
            group: Group.errors,
            maturity: Maturity.experimental);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;
  _Visitor(this.rule);

  @override
  visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name != 'map') return;
    if (!_implementsIterable(node.realTarget)) return;
    if (_isUsed(node)) return;

    rule.reportLint(node.methodName);
  }

  static bool _implementsIterable(Expression? target) =>
      target != null &&
      DartTypeUtilities.implementsInterface(
          target.staticType, 'Iterable', 'dart.core');

  static bool _isUsed(AstNode? node) {
    // todo(pq):consider refactoring to a check for "un"-use instead.
    var parent = node?.parent;
    if (parent == null) return false;

    if (parent is ExpressionFunctionBody) {
      // Are we in a lambda?
      return _isUsed(parent.parent);
    }

    if (parent is ReturnStatement) {
      // Are we in a lambda?
      return parent.thisOrAncestorOfType<ArgumentList>() != null;
    }

    if (parent is ParenthesizedExpression ||
        parent is AsExpression ||
        parent is BinaryExpression ||
        parent is ConditionalExpression ||
        parent is SpreadElement ||
        parent is CascadeExpression) {
      return _isUsed(parent);
    }

    return parent is ArgumentList ||
        parent is IndexExpression ||
        parent is VariableDeclaration ||
        parent is MethodInvocation ||
        parent is PropertyAccess ||
        parent is FunctionExpressionInvocation ||
        parent is ListLiteral ||
        parent is SetOrMapLiteral ||
        parent is MapLiteralEntry;
  }
}
