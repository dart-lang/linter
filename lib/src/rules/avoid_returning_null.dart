// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';

import '../analyzer.dart';
import '../extensions.dart';
import '../util/dart_type_utilities.dart';

const _desc =
    r'Avoid returning null from members whose return type is bool, double, int,'
    r' or num.';

const _details = r'''

**AVOID** returning null from members whose return type is bool, double, int,
or num.

Functions that return primitive types such as bool, double, int, and num are
generally expected to return non-nullable values.  Thus, returning null where a
primitive type was expected can lead to runtime exceptions.

**BAD:**
```dart
bool getBool() => null;
num getNum() => null;
int getInt() => null;
double getDouble() => null;
```

**GOOD:**
```dart
bool getBool() => false;
num getNum() => -1;
int getInt() => -1;
double getDouble() => -1.0;
```

''';

bool _isFunctionExpression(AstNode node) => node is FunctionExpression;

bool _isPrimitiveType(DartType type) =>
    DartTypeUtilities.isClass(type, 'bool', 'dart.core') ||
    DartTypeUtilities.isClass(type, 'num', 'dart.core') ||
    DartTypeUtilities.isClass(type, 'int', 'dart.core') ||
    DartTypeUtilities.isClass(type, 'double', 'dart.core');

bool _isReturnNull(AstNode node) =>
    node is ReturnStatement && node.expression.isNullLiteral;

class AvoidReturningNull extends LintRule {
  AvoidReturningNull()
      : super(
            name: 'avoid_returning_null',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    // This lint does not make sense in the context of nullability.
    // Long-term it should be deprecated and slated for removal.
    // See: https://github.com/dart-lang/linter/issues/2636
    if (!context.isEnabled(Feature.non_nullable)) {
      var visitor = _Visitor(this);
      registry.addFunctionExpression(this, visitor);
      registry.addMethodDeclaration(this, visitor);
    }
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitFunctionExpression(FunctionExpression node) {
    var declaredElement = node.declaredElement;
    if (declaredElement != null &&
        _isPrimitiveType(declaredElement.returnType)) {
      _visitFunctionBody(node.body);
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    var declaredElement = node.declaredElement;
    if (declaredElement != null &&
        _isPrimitiveType(declaredElement.returnType)) {
      _visitFunctionBody(node.body);
    }
  }

  void _visitFunctionBody(FunctionBody node) {
    if (node is ExpressionFunctionBody && node.expression.isNullLiteral) {
      rule.reportLint(node);
      return;
    }
    DartTypeUtilities.traverseNodesInDFS(node,
            excludeCriteria: _isFunctionExpression)
        .where(_isReturnNull)
        .forEach(rule.reportLint);
  }
}
