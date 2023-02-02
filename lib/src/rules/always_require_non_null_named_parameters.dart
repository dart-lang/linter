// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../extensions.dart';

const _desc = r'Specify `@required` on named parameters without defaults.';

const _details = r'''
**DO** specify `@required` on named parameters without a default value on which 
an `assert(param != null)` is done.

**BAD:**
```dart
m1({a}) {
  assert(a != null);
}
```

**GOOD:**
```dart
m1({@required a}) {
  assert(a != null);
}

m2({a: 1}) {
  assert(a != null);
}
```

NOTE: Only asserts at the start of the bodies will be taken into account.

''';

class AlwaysRequireNonNullNamedParameters extends LintRule {
  static const LintCode code = LintCode(
      'always_require_non_null_named_parameters',
      "Named parameters without a default value should be annotated with '@required'.",
      correctionMessage: "Try adding the '@required' annotation.");

  AlwaysRequireNonNullNamedParameters()
      : super(
            name: 'always_require_non_null_named_parameters',
            description: _desc,
            details: _details,
            state: State.deprecated(since: dart2_12),
            group: Group.style);

  @override
  LintCode get lintCode => code;

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    // In a Null Safety library, this lint is covered by other formal static
    // analysis.
    if (!context.isEnabled(Feature.non_nullable)) {
      var visitor = _Visitor(this);
      registry.addFormalParameterList(this, visitor);
    }
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitFormalParameterList(FormalParameterList node) {
    List<DefaultFormalParameter> getParams() {
      var params = <DefaultFormalParameter>[];
      for (var p in node.parameters) {
        // Only named parameters
        if (p.isNamed) {
          var parameter = p as DefaultFormalParameter;
          // Without a default value or marked required
          if (parameter.defaultValue == null) {
            var declaredElement = parameter.declaredElement;
            if (declaredElement != null && !declaredElement.hasRequired) {
              params.add(parameter);
            }
          }
        }
      }
      return params;
    }

    var parent = node.parent;
    if (parent is FunctionExpression) {
      _checkParams(getParams(), parent.body);
    } else if (parent is ConstructorDeclaration) {
      _checkInitializerList(getParams(), parent.initializers);
      _checkParams(getParams(), parent.body);
    } else if (parent is MethodDeclaration) {
      _checkParams(getParams(), parent.body);
    }
  }

  void _checkAssert(
      Expression assertExpression, List<DefaultFormalParameter> params) {
    for (var param in params) {
      var name = param.name;
      if (name != null && _hasAssertNotNull(assertExpression, name.lexeme)) {
        rule.reportLintForToken(name);
        params.remove(param);
        return;
      }
    }
  }

  void _checkInitializerList(List<DefaultFormalParameter> params,
      NodeList<ConstructorInitializer> initializers) {
    for (var initializer in initializers) {
      if (initializer is AssertInitializer) {
        _checkAssert(initializer.condition, params);
      }
    }
  }

  void _checkParams(List<DefaultFormalParameter> params, FunctionBody body) {
    if (body is BlockFunctionBody) {
      for (var statement in body.block.statements) {
        if (statement is AssertStatement) {
          _checkAssert(statement.condition, params);
        } else {
          // Bail on first non-assert.
          return;
        }
      }
    }
  }

  bool _hasAssertNotNull(Expression node, String name) {
    bool hasSameName(Expression rawExpression) {
      var expression = rawExpression.unParenthesized;
      return expression is SimpleIdentifier && expression.name == name;
    }

    var expression = node.unParenthesized;
    if (expression is BinaryExpression) {
      if (expression.operator.type == TokenType.AMPERSAND_AMPERSAND) {
        return _hasAssertNotNull(expression.leftOperand, name) ||
            _hasAssertNotNull(expression.rightOperand, name);
      }
      if (expression.operator.type == TokenType.BANG_EQ) {
        var operands = [expression.leftOperand, expression.rightOperand];
        return operands.any((e) => e.isNullLiteral) &&
            operands.any(hasSameName);
      }
    }
    return false;
  }
}
