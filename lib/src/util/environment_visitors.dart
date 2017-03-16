// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.util.visitor_with_scope;

import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:linter/src/util/dart_type_utilities.dart';

Element _getLeftElement(AssignmentExpression assignment) {
  final leftPart = assignment.leftHandSide;
  return leftPart is SimpleIdentifier
      ? DartTypeUtilities.getCanonicalElement(leftPart.bestElement)
      : leftPart is PropertyAccess
          ? DartTypeUtilities.getCanonicalElement(leftPart.propertyName.bestElement)
          : null;
}

bool _isBreakStatement(Statement statement) => (statement is BreakStatement ||
    (statement is Block &&
        statement.statements.length == 1 &&
        statement.statements.first is BreakStatement));

bool _isContinueStatement(
        Statement statement) =>
    (statement is ContinueStatement ||
        (statement is Block &&
            statement.statements.length == 1 &&
            statement.statements.first is ContinueStatement));

bool _isReturnStatement(Statement statement) => (statement is ReturnStatement ||
    (statement is Block &&
        statement.statements.length == 1 &&
        statement.statements.first is ReturnStatement));

/// An AST visitor that can be asked for conditions that its value is statically
/// well known this visitor is supposed to be a superclass for classes that
/// needs these data.
/// Clients may extend this class.
abstract class ConditionScopeVisitor extends _SimpleScopeVisitor {
  _MainCallVisitor _mainCallVisitor;
  _ConditionEnvironmentVisitor _conditionsEnvironmentVisitor;

  ConditionScopeVisitor() {
    _conditionsEnvironmentVisitor = new _ConditionEnvironmentVisitor(this);
    _mainCallVisitor = new _MainCallVisitor(_conditionsEnvironmentVisitor);
  }

  @override
  AstVisitor get mainCallVisitor => _mainCallVisitor;

  Iterable<Expression> getFalseExpressions(Iterable<Element> elements) =>
      _conditionsEnvironmentVisitor.getFalseExpressions(elements);

  Iterable<Expression> getTrueExpressions(Iterable<Element> elements) =>
      _conditionsEnvironmentVisitor.getTrueExpressions(elements);
}

/// An AST visitor that can be asked for the element that has the same name than
/// a given string.
///
/// Clients may extend this class.
abstract class ElementScopeVisitor extends _SimpleScopeVisitor {
  _MainCallVisitor _mainCallVisitor;
  _ElementEnvironmentVisitor _elementEnvironmentVisitor;

  ElementScopeVisitor() {
    _elementEnvironmentVisitor = new _ElementEnvironmentVisitor(this);
    _mainCallVisitor = new _MainCallVisitor(_elementEnvironmentVisitor);
  }

  @override
  AstVisitor get mainCallVisitor => _mainCallVisitor;

  Element lookUp(String name) => _elementEnvironmentVisitor.lookUp(name);
}

class _ConditionEnvironmentVisitor extends _EnvironmentVisitor<_ExpressionBox> {
  _ConditionEnvironmentVisitor(AstVisitor baseVisitor) : super(baseVisitor);

  Iterable<Expression> getFalseExpressions(Iterable<Element> elements) =>
      _getExpressions(elements, value: false);

  Iterable<Expression> getTrueExpressions(Iterable<Element> elements) =>
      _getExpressions(elements);

  @override
  visitAssignmentExpression(AssignmentExpression node) {
    _baseVisitor.visitAssignmentExpression(node);
    _addElementToEnvironment(new _UndefinedExpression(_getLeftElement(node)));
    node.visitChildren(this);
  }

  @override
  visitClassDeclaration(ClassDeclaration node) {
    _addLocalEnvironment();
    _addElementToEnvironment(new _UndefinedAllExpression());
    _baseVisitor.visitClassDeclaration(node);
    node.visitChildren(this);
    _removeLocalEnvironment();
  }

  @override
  visitConstructorDeclaration(ConstructorDeclaration node) {
    _addLocalEnvironment();
    _addElementToEnvironment(new _UndefinedAllExpression());
    _baseVisitor.visitConstructorDeclaration(node);
    node.visitChildren(this);
    _removeLocalEnvironment();
  }

  @override
  visitForStatement(ForStatement node) {
    _addLocalEnvironment();
    _addElementToEnvironment(new _ConditionExpression(node.condition));
    node.variables?.accept(this);
    node.initialization?.accept(this);
    _baseVisitor.visitForStatement(node);
    node.condition?.accept(this);
    _addElementToEnvironment(new _ConditionExpression(node.condition));
    node.updaters.accept(this);
    node.body?.accept(this);
    _removeLocalEnvironment();
    _addElementToEnvironment(
        new _ConditionExpression(node.condition, value: false));
  }

  @override
  visitFunctionDeclaration(FunctionDeclaration node) {
    _addLocalEnvironment();
    _addElementToEnvironment(new _UndefinedAllExpression());
    _baseVisitor.visitFunctionDeclaration(node);
    node.visitChildren(this);
    _removeLocalEnvironment();
  }

  @override
  visitIfStatement(IfStatement node) {
    _baseVisitor.visitIfStatement(node);
    final elseUndefinedExpressions =
        _visitElseStatement(node.elseStatement, node.condition);
    _visitIfStatement(node);
    elseUndefinedExpressions
        .where((e) => e is _UndefinedExpression)
        .forEach(_addElementToEnvironment);
    _addExpressionIfStatementIsStopStatement(node.thenStatement,
        new _ConditionExpression(node.condition, value: false));
    _addExpressionIfStatementIsStopStatement(
        node.elseStatement, new _ConditionExpression(node.condition));
  }

  @override
  visitMethodDeclaration(MethodDeclaration node) {
    _addLocalEnvironment();
    _addElementToEnvironment(new _UndefinedAllExpression());
    _baseVisitor.visitMethodDeclaration(node);
    node.visitChildren(this);
    _removeLocalEnvironment();
  }

  @override
  visitPostfixExpression(PostfixExpression node) {
    _baseVisitor.visitPostfixExpression(node);
    final operand = node.operand;
    if (operand is SimpleIdentifier) {
      _addElementToEnvironment(new _UndefinedExpression(operand.bestElement));
    }
    node.visitChildren(this);
  }

  @override
  visitPrefixExpression(PrefixExpression node) {
    _baseVisitor.visitPrefixExpression(node);
    final operand = node.operand;
    if (operand is SimpleIdentifier) {
      _addElementToEnvironment(new _UndefinedExpression(operand.bestElement));
    }
    node.visitChildren(this);
  }

  @override
  visitVariableDeclaration(VariableDeclaration node) {
    _baseVisitor.visitVariableDeclaration(node);
    _addElementToEnvironment(new _UndefinedExpression(node.element));
    node.visitChildren(this);
  }

  @override
  visitWhileStatement(WhileStatement node) {
    _baseVisitor.visitWhileStatement(node);
    _addLocalEnvironment();
    _addElementToEnvironment(new _ConditionExpression(node.condition));
    node.visitChildren(this);
    _removeLocalEnvironment();
    _addElementToEnvironment(
        new _ConditionExpression(node.condition, value: false));
  }

  _addExpressionIfStatementIsStopStatement(
      Statement statement, _ExpressionBox expressionBox) {
    if (_isReturnStatement(statement) ||
        _isBreakStatement(statement) ||
        _isContinueStatement(statement)) {
      _addElementToEnvironment(expressionBox);
    }
  }

  Iterable<Expression> _getExpressions(Iterable<Element> elements,
      {bool value: true}) {
    final expressions = <Expression>[];
    for (final environment in environments) {
      for (final element in environment) {
        if (element.haveToStop(elements)) {
          return expressions;
        }
        if (element is _ConditionExpression && element.value == value) {
          expressions.add(element.expression);
        }
      }
    }
    return expressions;
  }

  @override
  Queue<_ExpressionBox> _removeLocalEnvironment() {
    Queue<_ExpressionBox> localEnvironment = super._removeLocalEnvironment();
    localEnvironment
        .where((e) => e is _UndefinedExpression)
        .forEach(_addElementToEnvironment);
    return localEnvironment;
  }

  Queue<_ExpressionBox> _visitElseStatement(
      Statement elseStatement, Expression condition) {
    _addLocalEnvironment();
    _addElementToEnvironment(new _ConditionExpression(condition, value: false));
    elseStatement?.accept(this);
    return super._removeLocalEnvironment();
  }

  _visitIfStatement(IfStatement node) {
    _addLocalEnvironment();
    _addElementToEnvironment(new _ConditionExpression(node.condition));
    node.condition?.accept(this);
    node.thenStatement?.accept(this);
    _removeLocalEnvironment();
  }
}

class _ConditionExpression extends _ExpressionBox {
  Expression expression;
  bool value;

  _ConditionExpression(this.expression, {this.value: true});

  @override
  bool haveToStop(Iterable<Element> elements) => false;

  @override
  String toString() => '$expression is $value';
}

class _DelegatingAstVisitor extends UnifyingAstVisitor {
  final AstVisitor delegate;

  _DelegatingAstVisitor(this.delegate);

  @override
  void visitNode(AstNode node) {
    node.accept(delegate);
    node.visitChildren(this);
  }
}

class _ElementEnvironmentVisitor extends _EnvironmentVisitor<Element> {
  _ElementEnvironmentVisitor(AstVisitor baseVisitor) : super(baseVisitor);

  Element lookUp(String name) {
    if (name == null) {
      throw new ArgumentError.notNull('name');
    }
    for (final localEnvironment in environments) {
      for (final element in localEnvironment) {
        if (element.name == name) {
          return element;
        }
      }
    }
    return null;
  }

  @override
  visitClassDeclaration(ClassDeclaration node) {
    _addLocalEnvironment();
    node.members.forEach((e) {
      _addElementToEnvironment(e.element);
    });
    _baseVisitor.visitClassDeclaration(node);
    node.visitChildren(this);
    _removeLocalEnvironment();
  }

  @override
  visitCompilationUnit(CompilationUnit node) {
    _addLocalEnvironment();
    node.declarations.forEach((e) {
      this._addElementToEnvironment(e.element);
    });
    _baseVisitor.visitCompilationUnit(node);
    node.visitChildren(this);
    _removeLocalEnvironment();
  }

  @override
  visitFormalParameterList(FormalParameterList node) {
    _baseVisitor.visitFormalParameterList(node);
    node.parameterElements.forEach(this._addElementToEnvironment);
    node.visitChildren(this);
  }

  @override
  visitFunctionDeclaration(FunctionDeclaration node) {
    // Necessary for local functions
    if (node.parent is FunctionDeclarationStatement) {
      _addElementToEnvironment(node.element);
    }
    _addLocalEnvironment();
    _baseVisitor.visitFunctionDeclaration(node);
    node.visitChildren(this);
    _removeLocalEnvironment();
  }

  @override
  visitVariableDeclaration(VariableDeclaration node) {
    _baseVisitor.visitVariableDeclaration(node);
    _addElementToEnvironment(node.element);
    node.visitChildren(this);
  }
}

abstract class _EnvironmentVisitor<E> extends _DelegatingAstVisitor {
  final Queue<Queue<E>> environments = new Queue();
  AstVisitor _baseVisitor;

  _EnvironmentVisitor(this._baseVisitor) : super(_baseVisitor);

  @override
  visitCatchClause(CatchClause node) {
    _addLocalEnvironment();
    super.visitCatchClause(node);
    _removeLocalEnvironment();
  }

  @override
  visitClassDeclaration(ClassDeclaration node) {
    _addLocalEnvironment();
    super.visitClassDeclaration(node);
    _removeLocalEnvironment();
  }

  @override
  visitCompilationUnit(CompilationUnit node) {
    _addLocalEnvironment();
    super.visitCompilationUnit(node);
    _removeLocalEnvironment();
  }

  @override
  visitConstructorDeclaration(ConstructorDeclaration node) {
    _addLocalEnvironment();
    super.visitConstructorDeclaration(node);
    _removeLocalEnvironment();
  }

  @override
  visitDoStatement(DoStatement node) {
    _addLocalEnvironment();
    super.visitDoStatement(node);
    _removeLocalEnvironment();
  }

  @override
  visitForEachStatement(ForEachStatement node) {
    _addLocalEnvironment();
    super.visitForEachStatement(node);
    _removeLocalEnvironment();
  }

  @override
  visitForStatement(ForStatement node) {
    _addLocalEnvironment();
    super.visitForStatement(node);
    _removeLocalEnvironment();
  }

  @override
  visitFunctionDeclaration(FunctionDeclaration node) {
    _addLocalEnvironment();
    super.visitFunctionDeclaration(node);
    _removeLocalEnvironment();
  }

  @override
  visitIfStatement(IfStatement node) {
    _addLocalEnvironment();
    super.visitIfStatement(node);
    _removeLocalEnvironment();
  }

  @override
  visitMethodDeclaration(MethodDeclaration node) {
    _addLocalEnvironment();
    super.visitMethodDeclaration(node);
    _removeLocalEnvironment();
  }

  @override
  visitSwitchStatement(SwitchStatement node) {
    _addLocalEnvironment();
    super.visitSwitchStatement(node);
    _removeLocalEnvironment();
  }

  @override
  visitTryStatement(TryStatement node) {
    _addLocalEnvironment();
    super.visitTryStatement(node);
    _removeLocalEnvironment();
  }

  @override
  visitWhileStatement(WhileStatement node) {
    _addLocalEnvironment();
    super.visitWhileStatement(node);
    _removeLocalEnvironment();
  }

  void _addElementToEnvironment(E e) {
    if (e != null && environments.isNotEmpty) {
      environments.first.addFirst(e);
    }
  }

  void _addLocalEnvironment() {
    environments.addFirst(new Queue());
  }

  Queue<E> _removeLocalEnvironment() {
    return environments.removeFirst();
  }
}

abstract class _ExpressionBox {
  bool haveToStop(Iterable<Element> elements);
}

class _MainCallVisitor extends SimpleAstVisitor {
  _EnvironmentVisitor _environmentVisitor;

  _MainCallVisitor(this._environmentVisitor);

  @override
  visitCompilationUnit(CompilationUnit node) {
    _environmentVisitor.visitCompilationUnit(node);
  }
}

/// An AST visitor that need a kind of scope in its behavior should extend this
/// class and the visitor that must be used in the root of an AST is
/// mainCallVisitor.
///
/// Clients may extend this class.
abstract class _SimpleScopeVisitor extends SimpleAstVisitor {
  AstVisitor get mainCallVisitor;
}

class _UndefinedAllExpression extends _ExpressionBox {
  @override
  bool haveToStop(Iterable<Element> elements) => true;

  @override
  String toString() => '*All* got undefined';
}

class _UndefinedExpression extends _ExpressionBox {
  Element element;
  _UndefinedExpression(element) {
    this.element = DartTypeUtilities.getCanonicalElement(element);
  }

  @override
  bool haveToStop(Iterable<Element> elements) => elements.contains(element);

  @override
  String toString() => '$element got undefined';
}
