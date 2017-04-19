// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.util.leak_detector_visitor;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/standard_resolution_map.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/util/dart_type_utilities.dart';
import 'package:meta/meta.dart';

/// Builds a function that reports the variable node if the set of nodes
/// inside the [container] node is empty for all the predicates resulting
/// from building (predicates) with the provided [predicateBuilders] evaluated
/// in the variable.
_VisitVariableDeclaration _buildVariableReporter(
        AstNode container,
        Iterable<_PredicateBuilder> predicateBuilders,
        LintRule rule,
        Map<DartTypePredicate, String> predicates) =>
    (variable) {
      if (!predicates.keys.any((predicate) => predicate(
          resolutionMap.elementDeclaredByVariableDeclaration(variable).type))) {
        return;
      }

      final containerNodes = DartTypeUtilities.traverseNodesInDFS(container);

      final validators = <Iterable<AstNode>>[];
      for (final declaration in predicateBuilders) {
        validators.add(containerNodes.where(declaration(variable)));
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
  final prefixedIdentifiers = containerNodes
      .where((n) => n is PrefixedIdentifier)
      .map((n) => n as PrefixedIdentifier);
  return prefixedIdentifiers.where((n) =>
      n.prefix.bestElement == variable.name.bestElement &&
      _hasMatch(
          predicates,
          resolutionMap.elementDeclaredByVariableDeclaration(variable).type,
          n.identifier.token.lexeme));
}

Iterable<AstNode> _findMethodInvocationsWithVariableAsArgument(
    Iterable<AstNode> containerNodes, VariableDeclaration variable) {
  final prefixedIdentifiers = containerNodes
      .where((n) => n is MethodInvocation)
      .map((n) => n as MethodInvocation);
  return prefixedIdentifiers.where((n) => n.argumentList.arguments
      .where((e) => e is SimpleIdentifier)
      .map((e) => (e as SimpleIdentifier).bestElement)
      .contains(variable.name.bestElement));
}

Iterable<AstNode> _findNodesInvokingMethodOnVariable(
        Iterable<AstNode> classNodes,
        VariableDeclaration variable,
        Map<DartTypePredicate, String> predicates) =>
    classNodes.where((node) =>
        node is MethodInvocation &&
        ((_hasMatch(
                    predicates,
                    resolutionMap
                        .elementDeclaredByVariableDeclaration(variable)
                        .type,
                    node.methodName.name) &&
                (_isSimpleIdentifierElementEqualToVariable(
                        node.realTarget, variable) ||
                    (node.getAncestor((a) => a == variable) != null))) ||
            (_isInvocationThroughCascadeExpression(node, variable))));

Iterable<AstNode> _findVariableAssignments(
    Iterable<AstNode> containerNodes, VariableDeclaration variable) {
  if (variable.equals != null &&
      variable.initializer != null &&
      variable.initializer is SimpleIdentifier) {
    return [variable];
  }

  return containerNodes.where((n) =>
      n is AssignmentExpression &&
      (_isSimpleIdentifierElementEqualToVariable(n.leftHandSide, variable) ||
          // Assignment to VariableDeclaration as setter.
          (n.leftHandSide is PropertyAccess &&
              (n.leftHandSide as PropertyAccess).propertyName.token.lexeme ==
                  variable.name.token.lexeme))
      // Being assigned another reference.
      &&
      n.rightHandSide is SimpleIdentifier);
}

FunctionBody _getFunctionBodyAncestor(AstNode node) =>
    node.getAncestor((node) => node is FunctionBody);

_Predicate _hasConstructorFieldInitializers(variable) => (node) =>
    node is ConstructorFieldInitializer &&
    node.fieldName.bestElement == variable.name.bestElement;

_Predicate _hasFieldFormalParameter(variable) => (node) =>
    node is FieldFormalParameter &&
    (node.identifier.bestElement as FieldFormalParameterElement).field ==
        variable.name.bestElement;

bool _hasMatch(Map<DartTypePredicate, String> predicates, DartType type,
        String methodName) =>
    predicates.keys.fold(
        false,
        (previous, predicate) =>
            previous || predicate(type) && predicates[predicate] == methodName);

_Predicate _hasReturn(variable) => (node) =>
    node is ReturnStatement &&
    node.expression is SimpleIdentifier &&
    (node.expression as SimpleIdentifier).bestElement ==
        variable.name.bestElement;

bool _isInvocationThroughCascadeExpression(
    MethodInvocation invocation, VariableDeclaration variable) {
  if (invocation.realTarget is! SimpleIdentifier) {
    return false;
  }

  final identifier = invocation.realTarget;
  if (identifier is SimpleIdentifier) {
    final element = identifier.bestElement;
    if (element is PropertyAccessorElement) {
      return element.variable == variable.element;
    }
  }
  return false;
}

bool _isSimpleIdentifierElementEqualToVariable(
        AstNode n, VariableDeclaration variable) =>
    (n is SimpleIdentifier &&
        // Assignment to VariableDeclaration as variable.
        (n.bestElement == variable.name.bestElement ||
            (n.bestElement is PropertyAccessorElement &&
                (n.bestElement as PropertyAccessorElement).variable ==
                    variable.name.bestElement)));

typedef bool DartTypePredicate(DartType type);

typedef bool _Predicate(AstNode node);

typedef _Predicate _PredicateBuilder(VariableDeclaration v);

typedef void _VisitVariableDeclaration(VariableDeclaration node);

abstract class LeakDetectorVisitor extends SimpleAstVisitor {
  static final List<_PredicateBuilder> _variablePredicateBuilders = [
    _hasReturn
  ];
  static final List<_PredicateBuilder> _fieldPredicateBuilders = [
    _hasConstructorFieldInitializers,
    _hasFieldFormalParameter
  ];

  final LintRule rule;

  LeakDetectorVisitor(this.rule);

  @protected
  Map<DartTypePredicate, String> get predicates;

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    final unit = node.getAncestor((a) => a is CompilationUnit);
    node.fields.variables.forEach(_buildVariableReporter(
        unit, _fieldPredicateBuilders, rule, predicates));
  }

  @override
  void visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    final function = _getFunctionBodyAncestor(node);
    node.variables.variables.forEach(_buildVariableReporter(
        function, _variablePredicateBuilders, rule, predicates));
  }
}
