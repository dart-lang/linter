// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.invariant_booleans;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/standard_resolution_map.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/util/boolean_expression_utilities.dart';
import 'package:linter/src/util/dart_type_utilities.dart';
import 'package:linter/src/util/environment_visitors.dart';
import 'package:linter/src/util/tested_expressions.dart';

const _desc =
    r'Conditions should not unconditionally evaluate to "TRUE" or to "FALSE"';

const _details = r'''

**DON'T** test for conditions that can be inferred at compile time or test the
same condition twice.
Conditional statements using a condition which cannot be anything but FALSE have
the effect of making blocks of code non-functional. If the condition cannot
evaluate to anything but TRUE, the conditional statement is completely
redundant, and makes the code less readable.
It is quite likely that the code does not match the programmer's intent.
Either the condition should be removed or it should be updated so that it does
not always evaluate to TRUE or FALSE and does not perform redundant tests.
This rule will hint to the test conflicting with the linted one.

**BAD:**
```
//foo can't be both equal and not equal to bar in the same expression
if(foo == bar && something && foo != bar) {...}
```

**BAD:**
```
void compute(int foo) {
  if (foo == 4) {
    doSomething();
    // We know foo is equal to 4 at this point, so the next condition is always false
    if (foo > 4) {...}
    ...
  }
  ...
}
```

**BAD:**
```
void compute(bool foo) {
  if (foo) {
    return;
  }
  doSomething();
  // foo is always false here
  if (foo){...}
  ...
}
```

**GOOD:**
```
void nestedOK() {
  if (foo == bar) {
    foo = baz;
    if (foo != bar) {...}
  }
}
```

**GOOD:**
```
void nestedOk2() {
  if (foo == bar) {
    return;
  }

  foo = baz;
  if (foo == bar) {...} // OK
}
```

**GOOD:**
```
void nestedOk5() {
  if (foo != null) {
    if (bar != null) {
      return;
    }
  }

  if (bar != null) {...} // OK
}
```

_**WARNING:** this lint is comparatively expensive as, in general, calculating 
[boolean satisfiability](https://en.wikipedia.org/wiki/Boolean_satisfiability_problem) is hard. 
Performance improvements are planned ([#434](https://github.com/dart-lang/linter/issues/434)) but 
in the meantime, this lint should be sparingly enabled in large projects or when lint performance 
is a concern._
''';

Element _getRealElement(AstNode node) {
  Element element;
  if (node is SimpleIdentifier) {
    element = node.bestElement;
  } else if (node is PropertyAccess) {
    element = node.propertyName.bestElement;
  }
  return DartTypeUtilities.getCanonicalElement(element);
}

Iterable<Element> _getRealElementsInExpression(Expression node) =>
    DartTypeUtilities
        .traverseNodesInDFS(node)
        .where((e) => (e is SimpleIdentifier || e is PropertyAccess))
        .map(_getRealElement);

bool _isAnalyzedNode(AstNode node) =>
    node is IfStatement ||
    node is DoStatement ||
    node is ForStatement ||
    node is WhileStatement;

List<Expression> _splitConjunctions(Expression expression) {
  if (expression is BinaryExpression &&
      expression.operator.type == TokenType.AMPERSAND_AMPERSAND) {
    return _splitConjunctions(expression.leftOperand)
      ..addAll(_splitConjunctions(expression.rightOperand));
  }

  return [expression];
}

class InvariantBooleans extends LintRule {
  _Visitor _visitor;

  InvariantBooleans()
      : super(
            name: 'invariant_booleans',
            description: _desc,
            details: _details,
            group: Group.errors,
            maturity: Maturity.stable) {
    _visitor = new _Visitor(this);
  }

  @override
  AstVisitor getVisitor() => _visitor.mainCallVisitor;
}

/// The only purpose of this rule is to report the second node on a contradictory
/// comparison indicating the first node as the cause of the inconsistency.
class _ContradictionReportRule extends LintRule {
  _ContradictionReportRule(ContradictoryComparisons comparisons)
      : super(
            name: 'invariant_booleans',
            description: _desc + ' verify: ${comparisons.first}.',
            details: _details,
            group: Group.errors,
            maturity: Maturity.stable);
}

class _Visitor extends ConditionScopeVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  visitDoStatement(DoStatement node) {
    _reportExpressionIfConstantValue(node.condition);
  }

  @override
  visitForStatement(ForStatement node) {
    _reportExpressionIfConstantValue(node.condition);
  }

  @override
  visitIfStatement(IfStatement node) {
    _reportExpressionIfConstantValue(node.condition);
  }

  @override
  visitWhileStatement(WhileStatement node) {
    _reportExpressionIfConstantValue(node.condition);
  }

  TestedExpressions _findPreviousTestedExpressions(Expression node) {
    final elements = _getRealElementsInExpression(node);
    Iterable<Expression> conjunctions = getTrueExpressions(elements)
        .map(_splitConjunctions)
        .expand((iterable) => iterable)
        .toSet();
    Iterable<Expression> negations = getFalseExpressions(elements).toSet();
    return new TestedExpressions(node, conjunctions, negations);
  }

  _reportExpressionIfConstantValue(Expression node) {
    // Right part discards reporting a subexpression already reported.
    if (node == null ||
        resolutionMap.bestTypeForExpression(node).name != 'bool' ||
        !_isAnalyzedNode(node.parent)) {
      return;
    }

    TestedExpressions testedNodes = _findPreviousTestedExpressions(node);
    testedNodes.evaluateInvariant().forEach((ContradictoryComparisons e) {
      final reportRule = new _ContradictionReportRule(e);
      reportRule
        ..reporter = rule.reporter
        ..reportLint(e.second);
    });

    // In dart booleanVariable == true is a valid comparison since the variable
    // can be null.
    final BinaryExpression binaryExpression =
        node is BinaryExpression ? node : null;
    if (binaryExpression != null &&
        !BooleanExpressionUtilities.EQUALITY_OPERATIONS
            .contains(binaryExpression.operator.type) &&
        (binaryExpression.leftOperand is BooleanLiteral ||
            binaryExpression.rightOperand is BooleanLiteral) &&
        binaryExpression.operator.type != TokenType.QUESTION_QUESTION) {
      rule.reportLint(node);
    }
  }
}
