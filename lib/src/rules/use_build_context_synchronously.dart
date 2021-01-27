// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../util/flutter_utils.dart';

// todo (pq): flesh out storing context gotchas -- codify here or in another lint?

const _desc = r'Do not use BuildContexts across async calls.';

const _details = r'''
**DO NOT** use BuildContexts across async calls.

TODO: add rationale.

TODO: describe mechanics.


**BAD:**
```
class MyState extends State<MyWidget> {
  void m() async {
    // Uses context from State.
    Navigator.of(context).pushNamed('routeName');

    await Future<void>.delayed(Duration());
    // ^--- async gap.

    // Without a mounted check, this is unsafe.
    Navigator.of(context).pushNamed('routeName'); // LINT
  }
}
```

**GOOD:**
```
class MyState extends State<MyWidget> {
  void m() async {
    // Uses context from State.
    Navigator.of(context).pushNamed('routeName');

    await Future<void>.delayed(Duration());

    if (!mounted) return;

    // OK. We checked mounted checked first.
    Navigator.of(context).pushNamed('routeName'); // OK
  }
}
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
    registry.addInstanceCreationExpression(this, visitor);
    registry.addFunctionExpressionInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  bool accessesContext(ArgumentList argumentList) {
    for (var argument in argumentList.arguments) {
      var argType = argument.staticType;
      if (isBuildContext(argType)) {
        return true;
      }
    }
    return false;
  }

  void check(AstNode node) {
    // Walk back and look for an async gap that is not guarded by a mounted
    // property check.
    var child = node;
    while (child != null && child is! FunctionBody) {
      var parent = child.parent;
      if (parent is Block) {
        var statements = parent.statements;
        var index = statements.indexOf(child as Statement);
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

      child = child.parent;
    }
  }

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
    } else if (statement is WhileStatement) {
      return isAsync(statement.body);
    } else if (statement is ForStatement) {
      return isAsync(statement.body);
    } else if (statement is DoStatement) {
      return isAsync(statement.body);
    }

    return false;
  }

  bool isMountedCheck(Statement statement) {
    // This is intentionally naive.  Using a simple 'mounted' property check
    // as a signal plays nicely w/ unanticipated framework classes that provide
    // their own mounted checks.  The cost of this generality is the possibility
    // of false negatives.
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
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    if (accessesContext(node.argumentList)) {
      check(node);
    }
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (accessesContext(node.argumentList)) {
      check(node);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (isBuildContext(node.target?.staticType) ||
        accessesContext(node.argumentList)) {
      check(node);
    }
  }
}
