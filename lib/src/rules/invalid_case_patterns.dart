// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r'Use case expressions that are valid in Dart 3.0.';

/// todo(pq): add details
/// todo(pq): add a doc link
const _details = r'''
Some case expressions that are valid in Dart 2.19 and below will become an error
or have changed semantics when a library is upgraded to 3.0. This lint flags
those expressions in order to ease migration to Dart 3.0.
''';

class InvalidCasePatterns extends LintRule {
  static const LintCode code = LintCode('invalid_case_patterns',
      "This expression is not valid in a 'case' clause in Dart 3.0.",
      correctionMessage: 'Try refactoring the expression to be valid in 3.0.');

  InvalidCasePatterns()
      : super(
            name: 'invalid_case_patterns',
            description: _desc,
            details: _details,
            state: State.experimental(),
            group: Group.errors);

  @override
  LintCode get lintCode => code;

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addSwitchCase(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  visitSwitchCase(SwitchCase node) {
    var expression = node.expression;
    if (expression is SetOrMapLiteral) {
      if (expression.constKeyword == null) {
        rule.reportLint(expression);
      }
    } else if (expression is ListLiteral) {
      if (expression.constKeyword == null) {
        rule.reportLint(expression);
      }
    } else if (expression is ParenthesizedExpression) {
      rule.reportLint(expression);
    } else if (expression is MethodInvocation) {
      if (expression.methodName.isDartCoreIdentifier(named: 'identical')) {
        rule.reportLint(expression);
      }
    } else if (expression is PrefixExpression) {
      if (expression.operand is! IntegerLiteral) {
        rule.reportLint(expression);
      }
    } else if (expression is BinaryExpression) {
      rule.reportLint(expression);
    } else if (expression is ConditionalExpression) {
      rule.reportLint(expression);
    } else if (expression is PropertyAccess) {
      if (expression.propertyName.isDartCoreIdentifier(named: 'length')) {
        rule.reportLint(expression);
      }
    } else if (expression is IsExpression) {
      rule.reportLint(expression);
    } else if (expression is InstanceCreationExpression) {
      if (expression.isConst) {
        rule.reportLint(expression);
      }
    } else if (expression is SimpleIdentifier) {
      var token = expression.token;
      if (token is StringToken && token.lexeme == '_') {
        rule.reportLint(expression);
      }
    }
  }
}

extension on SimpleIdentifier {
  bool isDartCoreIdentifier({required String named}) {
    if (name != named) return false;
    var library = staticElement?.library;
    return library != null && library.isDartCore;
  }
}
