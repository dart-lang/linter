// Copyright (c) 2016, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';

import '../analyzer.dart';
import '../extensions.dart';
import '../util/boolean_expression_utilities.dart';
import '../util/condition_scope_visitor.dart';
import '../util/dart_type_utilities.dart';
import '../util/tested_expressions.dart';

const _desc =
    r'Conditions should not unconditionally evaluate to `true` or to `false`.';

const _details = r'''
**DEPRECATED:** This rule is unmaintained and will be removed in a future Linter
release.

**DON'T** test for conditions that can be inferred at compile time or test the
same condition twice.

Conditional statements using a condition which cannot be anything but `false`
have the effect of making blocks of code non-functional.  If the condition
cannot evaluate to anything but `true`, the conditional statement is completely
redundant, and makes the code less readable.
It is quite likely that the code does not match the programmer's intent.
Either the condition should be removed or it should be updated so that it does
not always evaluate to `true` or `false` and does not perform redundant tests.
This rule will hint to the test conflicting with the linted one.

**BAD:**
```dart
// foo can't be both equal and not equal to bar in the same expression
if(foo == bar && something && foo != bar) {...}
```

**BAD:**
```dart
void compute(int foo) {
  if (foo == 4) {
    doSomething();
    // we know foo is equal to 4 at this point, so the next condition is always false
    if (foo > 4) {...}
    ...
  }
  ...
}
```

**BAD:**
```dart
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
```dart
void nestedOK() {
  if (foo == bar) {
    foo = baz;
    if (foo != bar) {...}
  }
}
```

**GOOD:**
```dart
void nestedOk2() {
  if (foo == bar) {
    return;
  }

  foo = baz;
  if (foo == bar) {...} // OK
}
```

**GOOD:**
```dart
void nestedOk5() {
  if (foo != null) {
    if (bar != null) {
      return;
    }
  }

  if (bar != null) {...} // OK
}
```

''';

Iterable<Element?> _getElementsInExpression(Expression node) =>
    DartTypeUtilities.traverseNodesInDFS(node)
        .map((e) => e.canonicalElement)
        .where((e) => e != null);

class InvariantBooleans extends LintRule {
  InvariantBooleans()
      : super(
            name: 'invariant_booleans',
            description: _desc,
            details: _details,
            maturity: Maturity.deprecated,
            group: Group.errors);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _InvariantBooleansVisitor(this);
    registry.addCompilationUnit(this, visitor);
  }
}

/// The only purpose of this rule is to report the second node on a contradictory
/// comparison indicating the first node as the cause of the inconsistency.
class _ContradictionReportRule extends LintRule {
  _ContradictionReportRule(ContradictoryComparisons comparisons)
      : super(
            name: 'invariant_booleans',
            description: '$_desc verify: ${comparisons.first}.',
            details: _details,
            group: Group.errors);
}

class _InvariantBooleansVisitor extends ConditionScopeVisitor {
  final LintRule rule;

  _InvariantBooleansVisitor(this.rule);

  @override
  void visitCondition(Expression? node) {
    // Right part discards reporting a subexpression already reported.
    if (node == null || node.staticType?.isDartCoreBool != true) {
      return;
    }

    var testedNodes = _findPreviousTestedExpressions(node);
    testedNodes?.evaluateInvariant()?.forEach((ContradictoryComparisons e) {
      var reportRule = _ContradictionReportRule(e);
      reportRule
        ..reporter = rule.reporter
        ..reportLint(e.second);
    });

    // In dart booleanVariable == true is a valid comparison since the variable
    // can be null.
    var binaryExpression = node is BinaryExpression ? node : null;
    if (binaryExpression != null &&
        !BooleanExpressionUtilities.EQUALITY_OPERATIONS
            .contains(binaryExpression.operator.type) &&
        (binaryExpression.leftOperand is BooleanLiteral ||
            binaryExpression.rightOperand is BooleanLiteral) &&
        binaryExpression.operator.type != TokenType.QUESTION_QUESTION) {
      rule.reportLint(node);
    }
  }

  TestedExpressions? _findPreviousTestedExpressions(Expression node) {
    var elements = _getElementsInExpression(node);
    var conjunctions = getTrueExpressions(elements)?.toSet();
    var negations = getFalseExpressions(elements)?.toSet();
    if (conjunctions == null || negations == null) {
      return null;
    }
    return TestedExpressions(node, conjunctions, negations);
  }
}
