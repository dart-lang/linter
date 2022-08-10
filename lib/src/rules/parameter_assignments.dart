// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../extensions.dart';

const _desc =
    r"Don't reassign references to parameters of functions or methods.";

const _details = r'''

**DON'T** assign new values to parameters of methods or functions.

Assigning new values to parameters is generally a bad practice unless an
operator such as `??=` is used.  Otherwise, arbitrarily reassigning parameters
is usually a mistake.

**BAD:**
```dart
void badFunction(int parameter) { // LINT
  parameter = 4;
}
```

**BAD:**
```dart
void badFunction(int required, {int optional: 42}) { // LINT
  optional ??= 8;
}
```

**BAD:**
```dart
void badFunctionPositional(int required, [int optional = 42]) { // LINT
  optional ??= 8;
}
```

**BAD:**
```dart
class A {
    void badMethod(int parameter) { // LINT
    parameter = 4;
  }
}
```

**GOOD:**
```dart
void ok(String parameter) {
  print(parameter);
}
```

**GOOD:**
```dart
void actuallyGood(int required, {int optional}) { // OK
  optional ??= ...;
}
```

**GOOD:**
```dart
void actuallyGoodPositional(int required, [int optional]) { // OK
  optional ??= ...;
}
```

**GOOD:**
```dart
class A {
  void ok(String parameter) {
    print(parameter);
  }
}
```

''';

bool _isDefaultFormalParameterWithDefaultValue(FormalParameter parameter) =>
    parameter is DefaultFormalParameter && parameter.defaultValue != null;

bool _isDefaultFormalParameterWithoutDefaultValueReassigned(
        FormalParameter parameter, AssignmentExpression assignment) =>
    parameter is DefaultFormalParameter &&
    parameter.defaultValue == null &&
    _isFormalParameterReassigned(parameter, assignment);

bool _isFormalParameterReassigned(
    FormalParameter parameter, AssignmentExpression assignment) {
  var leftHandSide = assignment.leftHandSide;
  return leftHandSide is SimpleIdentifier &&
      leftHandSide.staticElement == parameter.declaredElement;
}

bool _preOrPostFixExpressionMutation(FormalParameter parameter, AstNode n) =>
    n is PrefixExpression &&
        n.operand is SimpleIdentifier &&
        (n.operand as SimpleIdentifier).staticElement ==
            parameter.declaredElement ||
    n is PostfixExpression &&
        n.operand is SimpleIdentifier &&
        (n.operand as SimpleIdentifier).staticElement ==
            parameter.declaredElement;

class ParameterAssignments extends LintRule {
  ParameterAssignments()
      : super(
            name: 'parameter_assignments',
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

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    var parameters = node.functionExpression.parameters;
    if (parameters != null) {
      // Getter do not have formal parameters.
      for (var e in parameters.parameters) {
        var declaredElement = e.declaredElement;
        if (declaredElement != null &&
            node.functionExpression.body
                .isPotentiallyMutatedInScope(declaredElement)) {
          _reportIfSimpleParameterOrWithDefaultValue(e, node);
        }
      }
    }
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    var parameterList = node.parameters;
    if (parameterList != null) {
      // Getters don't have parameters.
      for (var e in parameterList.parameters) {
        var declaredElement = e.declaredElement;
        if (declaredElement != null &&
            node.body.isPotentiallyMutatedInScope(declaredElement)) {
          _reportIfSimpleParameterOrWithDefaultValue(e, node);
        }
      }
    }
  }

  void _reportIfSimpleParameterOrWithDefaultValue(
      FormalParameter parameter, AstNode functionOrMethodDeclaration) {
    var nodes = functionOrMethodDeclaration.traverseNodesInDFS();

    if (parameter is SimpleFormalParameter ||
        _isDefaultFormalParameterWithDefaultValue(parameter)) {
      var mutatedNodes = nodes.where((n) =>
          (n is AssignmentExpression &&
              _isFormalParameterReassigned(parameter, n)) ||
          _preOrPostFixExpressionMutation(parameter, n));
      mutatedNodes.forEach(rule.reportLint);
      return;
    }

    var assignmentsNodes = nodes
        .where((n) =>
            n is AssignmentExpression &&
            _isDefaultFormalParameterWithoutDefaultValueReassigned(
                parameter, n))
        .toList();

    var nonNullCoalescingAssignments = assignmentsNodes.where((n) =>
        (n as AssignmentExpression).operator.type !=
        TokenType.QUESTION_QUESTION_EQ);

    if (assignmentsNodes.length > 1 ||
        nonNullCoalescingAssignments.isNotEmpty) {
      var node = assignmentsNodes.length > 1
          ? assignmentsNodes.last
          : nonNullCoalescingAssignments.isNotEmpty
              ? nonNullCoalescingAssignments.first
              : parameter;
      rule.reportLint(node);
    }
  }
}
