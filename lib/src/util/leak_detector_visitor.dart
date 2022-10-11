// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';

import '../analyzer.dart';
import '../ast.dart';
import '../extensions.dart';

_Predicate _hasConstructorFieldInitializers(
        VariableDeclaration v) =>
    (AstNode n) =>
        n is ConstructorFieldInitializer &&
        n.fieldName.staticElement == v.declaredElement;

_Predicate _hasFieldFormalParameter(VariableDeclaration v) => (AstNode n) {
      if (n is FieldFormalParameter) {
        var staticElement = n.declaredElement;
        return staticElement is FieldFormalParameterElement &&
            staticElement.field == v.declaredElement;
      }
      return false;
    };

_Predicate _hasReturn(VariableDeclaration v) => (AstNode n) {
      if (n is ReturnStatement) {
        var expression = n.expression;
        if (expression is SimpleIdentifier) {
          return expression.staticElement == v.declaredElement;
        }
      }
      return false;
    };

/// Builds a function that reports the variable node if the set of nodes
/// inside the [container] node is empty for all the predicates resulting
/// from building (predicates) with the provided [predicateBuilders] evaluated
/// in the variable.
_VisitVariableDeclaration _buildVariableReporter(
        AstNode container,
        Iterable<_PredicateBuilder> predicateBuilders,
        LintRule rule,
        Map<DartTypePredicate, String> predicates) =>
    (VariableDeclaration variable) {
      if (!predicates.keys.any((DartTypePredicate p) {
        var declaredElement = variable.declaredElement;
        return declaredElement != null && p(declaredElement.type);
      })) {
        return;
      }

      var containerNodes = container.traverseNodesInDFS();

      var validators = <Iterable<AstNode>>[];
      for (var f in predicateBuilders) {
        validators.add(containerNodes.where(f(variable)));
      }

      validators
        ..add(_findVariableAssignments(containerNodes, variable))
        ..add(_findNodesInvokingMethodOnVariable(
            containerNodes, variable, predicates))
        ..add(_findMethodCallbackNodes(containerNodes, variable, predicates))
        // If any function is invoked with our variable, we suppress lints. This
        // is because it is not so uncommon to invoke the target method there. We
        // might not have access to the body of such function at analysis time, so
        // trying to infer if the close method is invoked there is not always
        // possible.
        // TODO: Should there be another lint more relaxed that omits this step?
        ..add(_findMethodInvocationsWithVariableAsArgument(
            containerNodes, variable));

      if (validators.every((i) => i.isEmpty)) {
        rule.reportLint(variable);
      }
    };

Iterable<AstNode> _findMethodCallbackNodes(Iterable<AstNode> containerNodes,
    VariableDeclaration variable, Map<DartTypePredicate, String> predicates) {
  var prefixedIdentifiers = containerNodes.whereType<PrefixedIdentifier>();
  return prefixedIdentifiers.where((n) {
    var declaredElement = variable.declaredElement;
    return declaredElement != null &&
        n.prefix.staticElement == variable.declaredElement &&
        _hasMatch(predicates, declaredElement.type, n.identifier.token.lexeme);
  });
}

Iterable<AstNode> _findMethodInvocationsWithVariableAsArgument(
    Iterable<AstNode> containerNodes, VariableDeclaration variable) {
  var prefixedIdentifiers = containerNodes.whereType<MethodInvocation>();
  return prefixedIdentifiers.where((n) => n.argumentList.arguments
      .whereType<SimpleIdentifier>()
      .map((e) => e.staticElement)
      .contains(variable.declaredElement));
}

Iterable<AstNode> _findNodesInvokingMethodOnVariable(
        Iterable<AstNode> classNodes,
        VariableDeclaration variable,
        Map<DartTypePredicate, String> predicates) =>
    classNodes.where((AstNode n) {
      var declaredElement = variable.declaredElement;
      return declaredElement != null &&
          n is MethodInvocation &&
          ((_hasMatch(predicates, declaredElement.type, n.methodName.name) &&
                  (_isSimpleIdentifierElementEqualToVariable(
                          n.realTarget, variable) ||
                      _isPostfixExpressionOperandEqualToVariable(
                          n.realTarget, variable) ||
                      _isPropertyAccessThroughThis(n.realTarget, variable) ||
                      (n.thisOrAncestorMatching((a) => a == variable) !=
                          null))) ||
              (_isInvocationThroughCascadeExpression(n, variable)));
    });

Iterable<AstNode> _findVariableAssignments(
    Iterable<AstNode> containerNodes, VariableDeclaration variable) {
  if (variable.equals != null &&
      variable.initializer != null &&
      variable.initializer is SimpleIdentifier) {
    return [variable];
  }

  return containerNodes.where((n) =>
      n is AssignmentExpression &&
      (_isElementEqualToVariable(n.writeElement, variable) ||
          // Assignment to VariableDeclaration as setter.
          (n.leftHandSide is PropertyAccess &&
              (n.leftHandSide as PropertyAccess).propertyName.token.lexeme ==
                  variable.name.lexeme))
      // Being assigned another reference.
      &&
      n.rightHandSide is SimpleIdentifier);
}

bool _hasMatch(Map<DartTypePredicate, String> predicates, DartType type,
        String methodName) =>
    predicates.keys.fold(
        false,
        (bool previous, DartTypePredicate p) =>
            previous || p(type) && predicates[p] == methodName);

bool _isElementEqualToVariable(
    Element? propertyElement, VariableDeclaration variable) {
  var variableElement = variable.declaredElement;
  return propertyElement == variableElement ||
      propertyElement is PropertyAccessorElement &&
          propertyElement.variable == variableElement;
}

bool _isInvocationThroughCascadeExpression(
    MethodInvocation invocation, VariableDeclaration variable) {
  if (invocation.realTarget is! SimpleIdentifier) {
    return false;
  }

  var identifier = invocation.realTarget;
  if (identifier is SimpleIdentifier) {
    var element = identifier.staticElement;
    if (element is PropertyAccessorElement) {
      return element.variable == variable.declaredElement;
    }
  }
  return false;
}

bool _isPropertyAccessThroughThis(Expression? n, VariableDeclaration variable) {
  if (n is! PropertyAccess) {
    return false;
  }

  var target = n.realTarget;
  if (target is! ThisExpression) {
    return false;
  }

  var property = n.propertyName;
  var propertyElement = property.staticElement;
  return _isElementEqualToVariable(propertyElement, variable);
}

bool _isSimpleIdentifierElementEqualToVariable(
        AstNode? n, VariableDeclaration variable) =>
    n is SimpleIdentifier &&
    _isElementEqualToVariable(n.staticElement, variable);

bool _isPostfixExpressionOperandEqualToVariable(
    AstNode? n, VariableDeclaration variable) {
  if (n is PostfixExpression) {
    var operand = n.operand;
    return operand is SimpleIdentifier &&
        _isElementEqualToVariable(operand.staticElement, variable);
  }
  return false;
}

typedef DartTypePredicate = bool Function(DartType type);

typedef _Predicate = bool Function(AstNode node);

typedef _PredicateBuilder = _Predicate Function(VariableDeclaration v);

typedef _VisitVariableDeclaration = void Function(VariableDeclaration node);

abstract class LeakDetectorProcessors extends SimpleAstVisitor<void> {
  static final _variablePredicateBuilders = <_PredicateBuilder>[_hasReturn];
  static final _fieldPredicateBuilders = <_PredicateBuilder>[
    _hasConstructorFieldInitializers,
    _hasFieldFormalParameter
  ];

  final LintRule rule;

  LeakDetectorProcessors(this.rule);

  @protected
  Map<DartTypePredicate, String> get predicates;

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    var unit = getCompilationUnit(node);
    if (unit != null) {
      node.fields.variables.forEach(_buildVariableReporter(
          unit, _fieldPredicateBuilders, rule, predicates));
    }
  }

  @override
  void visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    var function = node.thisOrAncestorOfType<FunctionBody>();
    if (function != null) {
      node.variables.variables.forEach(_buildVariableReporter(
          function, _variablePredicateBuilders, rule, predicates));
    }
  }
}
