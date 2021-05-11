// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';

import '../analyzer.dart';
import '../util/dart_type_utilities.dart';

const alwaysFalse = 'Always false because length is always greater or equal 0.';

const alwaysTrue = 'Always true because length is always greater or equal 0.';

const useIsEmpty = 'Use isEmpty instead of length';
const useIsNotEmpty = 'Use isNotEmpty instead of length';
const _desc = r'Use `isEmpty` for Iterables and Maps.';
const _details = r'''

**DON'T** use `length` to see if a collection is empty.

The `Iterable` contract does not require that a collection know its length or be
able to provide it in constant time.  Calling `length` just to see if the
collection contains anything can be painfully slow.

Instead, there are faster and more readable getters: `isEmpty` and
`isNotEmpty`.  Use the one that doesn't require you to negate the result.

**GOOD:**
```dart
if (lunchBox.isEmpty) return 'so hungry...';
if (words.isNotEmpty) return words.join(' ');
```

**BAD:**
```dart
if (lunchBox.length == 0) return 'so hungry...';
if (words.length != 0) return words.join(' ');
```

''';

class PreferIsEmpty extends LintRule implements NodeLintRule {
  PreferIsEmpty()
      : super(
            name: 'prefer_is_empty',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this, context);
    registry.addBinaryExpression(this, visitor);
  }

  void reportLintWithDescription(AstNode node, String description) {
    reporter.reportErrorForNode(_LintCode(name, description), node, []);
  }
}

class _LintCode extends LintCode {
  static final registry = <String, _LintCode>{};

  factory _LintCode(String name, String message) =>
      registry.putIfAbsent(name + message, () => _LintCode._(name, message));

  _LintCode._(String name, String message) : super(name, message);
}

class _Visitor extends SimpleAstVisitor<void> {
  final PreferIsEmpty rule;

  final LinterContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitBinaryExpression(BinaryExpression node) {
    var value = _getIntValue(node.rightOperand);
    if (value != null) {
      var accessor = _getLengthAccess(node.leftOperand);
      if (accessor != null) {
        _check(node, value, constantOnRight: true);
      }
    } else {
      value = _getIntValue(node.leftOperand);
      if (value != null) {
        var accessor = _getLengthAccess(node.rightOperand);
        if (accessor != null) {
          _check(node, value, constantOnRight: false);
        }
      }
    }
  }

  void _check(BinaryExpression expression, int value,
      {required bool constantOnRight}) {
    // Don't lint if we're in a const constructor initializer.
    var constructorInitializer =
        expression.thisOrAncestorOfType<ConstructorInitializer>();
    if (constructorInitializer != null) {
      var constructorDecl = constructorInitializer.parent;
      if (constructorDecl is! ConstructorDeclaration ||
          constructorDecl.constKeyword != null) {
        return;
      }
    }

    // Or in a const context.
    // See: https://github.com/dart-lang/linter/issues/1719
    if (expression.inConstantContext) {
      return;
    }

    var operator = expression.operator;
    if (value == 0) {
      if (operator.type == TokenType.EQ_EQ ||
          operator.type == TokenType.LT_EQ) {
        rule.reportLintWithDescription(expression, useIsEmpty);
      } else if (operator.type == TokenType.GT ||
          operator.type == TokenType.BANG_EQ) {
        rule.reportLintWithDescription(expression, useIsNotEmpty);
      } else if (operator.type == TokenType.LT) {
        rule.reportLintWithDescription(expression, alwaysFalse);
      } else if (operator.type == TokenType.GT_EQ) {
        rule.reportLintWithDescription(expression, alwaysTrue);
      }
    } else if (value == 1) {
      if (constantOnRight) {
        // 'length >= 1' is same as 'isNotEmpty',
        // and 'length < 1' is same as 'isEmpty'
        if (operator.type == TokenType.GT_EQ) {
          rule.reportLintWithDescription(expression, useIsNotEmpty);
        } else if (operator.type == TokenType.LT) {
          rule.reportLintWithDescription(expression, useIsEmpty);
        }
      } else {
        // '1 <= length' is same as 'isNotEmpty',
        // and '1 > length' is same as 'isEmpty'
        if (operator.type == TokenType.LT_EQ) {
          rule.reportLintWithDescription(expression, useIsNotEmpty);
        } else if (operator.type == TokenType.GT) {
          rule.reportLintWithDescription(expression, useIsEmpty);
        }
      }
    } else if (value < 0) {
      if (constantOnRight) {
        // 'length' is always >= 0, so comparing with negative makes no sense.
        if (operator.type == TokenType.EQ_EQ ||
            operator.type == TokenType.LT_EQ ||
            operator.type == TokenType.LT) {
          rule.reportLintWithDescription(expression, alwaysFalse);
        } else if (operator.type == TokenType.BANG_EQ ||
            operator.type == TokenType.GT_EQ ||
            operator.type == TokenType.GT) {
          rule.reportLintWithDescription(expression, alwaysTrue);
        }
      } else {
        // 'length' is always >= 0, so comparing with negative makes no sense.
        if (operator.type == TokenType.EQ_EQ ||
            operator.type == TokenType.GT_EQ ||
            operator.type == TokenType.GT) {
          rule.reportLintWithDescription(expression, alwaysFalse);
        } else if (operator.type == TokenType.BANG_EQ ||
            operator.type == TokenType.LT_EQ ||
            operator.type == TokenType.LT) {
          rule.reportLintWithDescription(expression, alwaysTrue);
        }
      }
    }
  }

  /// todo(pq): consider sharing
  T? _drillDownTo<T extends Expression>(Expression expression,
      {required bool ignoreParens, required bool ignoreAs}) {
    var search = expression;
    // ignore: literal_only_boolean_expressions
    while (true) {
      if (ignoreParens && search is ParenthesizedExpression) {
        search = search.expression;
      } else if (ignoreAs && search is AsExpression) {
        search = search.expression;
      } else {
        break;
      }
    }

    return search is T ? search : null;
  }

  /// Returns the value of an [IntegerLiteral] or [PrefixExpression] with a
  /// minus and then an [IntegerLiteral]. For anything else, returns `null`.
  int? _getIntValue(Expression expressions) {
    if (expressions is IntegerLiteral) {
      return expressions.value;
    } else if (expressions is PrefixExpression) {
      var operand = expressions.operand;
      if (expressions.operator.type == TokenType.MINUS &&
          operand is IntegerLiteral) {
        var value = operand.value;
        if (value != null) {
          return -value;
        }
      }
    }
    // ignore: avoid_returning_null
    return null;
  }

  SimpleIdentifier? _getLengthAccess(Expression operand) {
    var node = _drillDownTo(operand, ignoreParens: true, ignoreAs: true);
    if (node == null) {
      return null;
    }

    SimpleIdentifier? identifier;
    InterfaceType? type;

    if (node is PrefixedIdentifier) {
      identifier = node.identifier;
      var operandType = node.prefix.staticType;
      if (operandType is InterfaceType) {
        type = operandType;
      }
    } else if (node is PropertyAccess) {
      identifier = node.propertyName;
      var parentType = node.target?.staticType;
      if (parentType is InterfaceType) {
        type = parentType;
      }
    }

    if (identifier?.name != 'length') {
      return null;
    }

    // Should be subtype of Iterable, Map or String.
    if (type == null ||
        !DartTypeUtilities.implementsInterface(type, 'Iterable', 'dart.core') &&
            !DartTypeUtilities.implementsInterface(type, 'Map', 'dart.core') &&
            !type.isDartCoreString) {
      return null;
    }

    return identifier;
  }
}
