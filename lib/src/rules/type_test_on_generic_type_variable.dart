// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../analyzer.dart';

const _desc = r' ';

const _details = r'''
**DON'T** perform type tests on generic type variables.

A type variable, the type parameter of a generic class or method,
used as an expression always evalautes to a `Type` object.
The first operand of `is` or `as` type tests is an expression,
so a type test of a type variable is always type test on a `Type` instance.
Such a test does not relate to the values which have a type specified by the
type variable.

**BAD:**
```dart
class C<T> {
  void m(T value) {
    assert(T is SomeType);
  }
}
```

**GOOD:**
```dart
class C<T> {
  void m(T value) {
    assert(value is SomeType);
  }
}
```

''';

class TypeTestOnGenericTypeVariable extends LintRule {
  static const LintCode code = LintCode(
      'type_test_on_generic_type_variable', "Type test on type variable '{0}'.",
      correctionMessage:
          'Avoid using `is`, or `as` with generic type variables,'
          ' which always will be a `Type`.');

  TypeTestOnGenericTypeVariable()
      : super(
            name: 'type_test_on_generic_type_variable',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  LintCode get lintCode => code;

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addIsExpression(this, visitor);
    registry.addAsExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitIsExpression(IsExpression node) {
    _reportTypeVariable(node.expression, node.isOperator);
  }

  @override
  void visitAsExpression(AsExpression node) {
    _reportTypeVariable(node.expression, node.asOperator);
  }

  void _reportTypeVariable(Expression expression, Token typeTestToken) {
    if (expression is! Identifier) return;
    var element = expression.staticElement;
    if (element is! TypeParameterElement) return;
    rule.reportLintForToken(typeTestToken,
        arguments: [expression.name],
        errorCode: TypeTestOnGenericTypeVariable.code);
  }
}
