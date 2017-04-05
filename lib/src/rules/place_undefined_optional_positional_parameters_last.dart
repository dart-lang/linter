// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.place_undefined_optional_positional_parameters_last;

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:linter/src/analyzer.dart';

const _desc = r'Place undefined optional positional parameters last.';

const _details = r'''

**DO** place undefined optional positional parameters last.

**BAD:**
```
DateTime badGetDateTime(int year, [int day, int month = 1]) {
}
```

**GOOD:**
```
DateTime goodGetDateTime(int year, [int month = 1, int day]) {
}
```

''';

DefaultFormalParameter _asDefaultFormalParameter(FormalParameter node) =>
    node as DefaultFormalParameter;

bool _checkParameters(NodeList<FormalParameter> parameters) => parameters
    .where(_isPositionalFormalParameter)
    .toList()
    .reversed
    .map(_asDefaultFormalParameter)
    .skipWhile(_doesNotHaveDefaultValue)
    .any(_doesNotHaveDefaultValue);

bool _doesNotHaveDefaultValue(DefaultFormalParameter node) =>
    node.defaultValue == null;

bool _isPositionalFormalParameter(FormalParameter node) =>
    node.kind == ParameterKind.POSITIONAL;

class PlaceUndefinedOptionalPositionalParametersLast extends LintRule {
  _Visitor _visitor;
  PlaceUndefinedOptionalPositionalParametersLast()
      : super(
            name: 'place_undefined_optional_positional_parameters_last',
            description: _desc,
            details: _details,
            group: Group.style) {
    _visitor = new _Visitor(this);
  }

  @override
  AstVisitor getVisitor() => _visitor;
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;
  _Visitor(this.rule);

  @override
  visitConstructorDeclaration(ConstructorDeclaration node) {
    final parameters = node.parameters?.parameters;
    if (parameters != null && _checkParameters(node.parameters.parameters)) {
      rule.reportLint(node.parameters);
    }
  }

  @override
  visitFunctionExpression(FunctionExpression node) {
    final parameters = node.parameters?.parameters;
    if (parameters != null && _checkParameters(node.parameters.parameters)) {
      rule.reportLint(node.parameters);
    }
  }

  @override
  visitMethodDeclaration(MethodDeclaration node) {
    final parameters = node.parameters?.parameters;
    if (parameters != null && _checkParameters(node.parameters.parameters)) {
      rule.reportLint(node.parameters);
    }
  }
}
