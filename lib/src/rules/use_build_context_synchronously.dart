// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../util/flutter_utils.dart';

const _desc = r' ';

const _details = r'''

**DO** ...

**BAD:**
```

```

**GOOD:**
```

```

''';

class UseBuildContextSynchronously extends LintRule implements NodeLintRule {
  UseBuildContextSynchronously()
      : super(
            name: 'use_build_context_synchronously',
            description: _desc,
            details: _details,
            group: Group.errors,
            maturity: Maturity.experimental);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    final visitor = _Visitor(this);
    registry.addMethodInvocation(this, visitor);
  }
}

bool accessesContext(MethodInvocation node) {
  var argumentList = node.argumentList;
  for (var argument in argumentList.arguments) {
    var argType = argument.staticType;
    if (isBuildContext(argType)) {
      return true;
    }
  }
  return false;
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  bool isAsync(Statement statement) {
    if (statement is ExpressionStatement) {
      var expression = statement.expression;
      if (expression is AwaitExpression) {
        return true;
      }
    } else if (statement is IfStatement) {
      return isAsync(statement.thenStatement) ||
          isAsync(statement.elseStatement);
    } else if (statement is Block) {
      for (var s in statement.statements) {
        if (isAsync(s)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Naive check for mounted.
  /// todo (pq): update to use element model (and check target)
  bool isMountedCheck(Statement statement) {
    if (statement is IfStatement) {
      var condition = statement.condition;
      if (condition is PrefixExpression) {
        if (condition.operator.type == TokenType.BANG) {
          var operand = condition.operand;
          if (operand is SimpleIdentifier) {
            if (operand.name == 'mounted') {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (!accessesContext(node)) {
      return;
    }

    // todo (pq): consider field declarations.
    var parent = node.parent;
    while (parent != null && node is! MethodDeclaration) {
      if (parent is Block) {
        var statements = parent.statements;
        var statement = node.thisOrAncestorOfType<Statement>();
        var index = statements.indexOf(statement);
        for (var i = index - 1; i >= 0; i--) {
          var s = statements.elementAt(i);
          if (isMountedCheck(s)) {
            return;
          } else if (isAsync(s)) {
            rule.reportLint(node);
            return;
          }
        }
      }
      parent = parent.parent;
    }
  }
}
