// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'The parameter type of `==` operators should be non-nullable.';

const _details = r'''
The parameter type of `==` operators should be non-nullable.

`null` is never passed to `operator ==`, so the parameter type of an `==`
operator override should always be non-nullable.

**BAD:**
```dart
class C {
  String key;
  B(this.key);
  @override
  operator ==(Object? other) => other is C && other.key == key;
}
```

**GOOD:**
```dart
class C {
  String key;
  B(this.key);
  @override
  operator ==(Object other) => other is C && other.key == key;
}
```
''';

class NonNullableEqualsParameter extends LintRule {
  static const LintCode code = LintCode('non_nullable_equals_parameter',
      'The parameter should have a non-nullable type.',
      correctionMessage: 'Try using a non-nullable type.');

  NonNullableEqualsParameter()
      : super(
            name: 'non_nullable_equals_parameter',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  LintCode get lintCode => code;

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this, context);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  final LinterContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.name.type != TokenType.EQ_EQ) {
      return;
    }

    var parameters = node.parameters;
    if (parameters == null) {
      return;
    }

    if (parameters.parameters.length != 1) {
      return;
    }

    var parameter = parameters.parameters.first;
    var parameterElement = parameter.declaredElement;

    if (parameterElement == null) {
      return;
    }

    var type = parameterElement.type;

    if (!type.isDartCoreObject && !type.isDynamic) {
      // There is no legal way to define a nullable parameter type, which is not
      // `dynamic` or `Object?`.
      return;
    }

    if (context.typeSystem.isNullable(parameterElement.type)) {
      rule.reportLint(parameter);
    }
  }
}
