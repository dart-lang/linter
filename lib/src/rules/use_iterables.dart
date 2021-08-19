// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_provider.dart';

import '../analyzer.dart';

const _desc = r'Use lazy iterables.';

const _details = r'''
**DO** use lazy iterables created by `iterable.map`. Since they are lazily
instantiated, the `map` function will not be evaluated until use which can be
confusing.  Alternatively, consider preferring `forEach`.

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
[1, 2, 3].map(print).last;
[1, 2, 3].map(print).toList();
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
    var visitor = _Visitor(this, context);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;
  final TypeProvider typeProvider;

  _Visitor(this.rule, LinterContext context)
      : typeProvider = context.typeProvider;

  @override
  visitMethodInvocation(MethodInvocation node) {
    if (!_isIterable(node.staticType)) {
      return;
    }
    if (node.methodName.name != 'map') {
      return;
    }
    if (_isUsed(node)) {
      return;
    }

    rule.reportLint(node.methodName);
  }

  bool _isIterable(DartType? type) =>
      type != null && type.asInstanceOf(typeProvider.iterableElement) != null;

  static bool _isUsed(AstNode node) {
    var parent = node.parent;
    if (parent == null) {
      return false;
    }

    if (parent is ParenthesizedExpression ||
        parent is ConditionalExpression ||
        parent is CascadeExpression) {
      return _isUsed(parent);
    }

    return parent is ArgumentList ||
        parent is VariableDeclaration ||
        parent is MethodInvocation ||
        parent is PropertyAccess ||
        parent is ExpressionFunctionBody ||
        parent is ReturnStatement ||
        parent is FunctionExpressionInvocation ||
        parent is ListLiteral ||
        parent is SetOrMapLiteral ||
        parent is MapLiteralEntry;
  }
}
