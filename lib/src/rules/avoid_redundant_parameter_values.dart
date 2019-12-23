// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../analyzer.dart';

const _desc = r'Avoid redundant parameter values.';

const _details = r'''Avoid redundant parameter values.

**DON'T** declare parameters with values that match their defaults.

**BAD:**
```
void f({bool valWithDefault = true, bool val}) {
  ...
}

void main() {
  f(valWithDefault = true);
}
```

**GOOD:**
```
void f({bool valWithDefault = true, bool val}) {
  ...
}

void main() {
  f(valWithDefault = false);
  f();
}
```
''';

class AvoidRedundantParameterValues extends LintRule implements NodeLintRule {
  AvoidRedundantParameterValues()
      : super(
            name: 'avoid_redundant_parameter_values',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry,
      [LinterContext context]) {
    final visitor = _Visitor(this, context);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;
  final LinterContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.argumentList.arguments.isEmpty) {
      return;
    }

    final type = node.staticInvokeType;
    final element = type.element;
    var parameters;
    if (element is MethodElement) {
      parameters = element.parameters;
    }
    if (element is FunctionElement) {
      parameters = element.parameters;
    }

    if (parameters != null) {
      for (var arg in node.argumentList.arguments) {
        if (arg is NamedExpression) {
          for (var param in parameters) {
            if (param.name == arg.name.label.name) {
              final expression = arg.expression;
              final value = param.constantValue;
              if (value != null) {
                final expressionValue = context.evaluateConstant(expression);
                if (expressionValue.value == value) {
                  rule.reportLint(arg);
                }
              }
            }
          }
        }
      }
    }
  }
}
