// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:path/path.dart' as path;

import '../analyzer.dart';

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

    // OK. We checked mounted first.
    Navigator.of(context).pushNamed('routeName'); // OK
  }
}
```
''';

class UseBuildContextSynchronously extends LintRule implements NodeLintRule {
  // todo (pq): use LinterContext.inTestDir() when available
  static final _testDirectories = [
    '${path.separator}test${path.separator}',
    '${path.separator}integration_test${path.separator}',
    '${path.separator}test_driver${path.separator}',
    '${path.separator}testing${path.separator}',
  ];

  /// Flag to short-circuit `inTestDir` checking when running tests.
  final bool inTestMode;

  UseBuildContextSynchronously({this.inTestMode = false})
      : super(
            name: 'use_build_context_synchronously',
            description: _desc,
            details: _details,
            group: Group.errors,
            maturity: Maturity.experimental);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var unit = context.currentUnit.unit;
    if (inTestMode || !inTestDir(unit)) {
      final visitor = _Visitor(this);
      registry.addMethodInvocation(this, visitor);
      registry.addInstanceCreationExpression(this, visitor);
      registry.addFunctionExpressionInvocation(this, visitor);
    }
  }

  static bool inTestDir(CompilationUnit unit) {
    var path = unit.declaredElement?.source?.fullName;
    return path != null && _testDirectories.any(path.contains);
  }
}

class _AwaitVisitor extends RecursiveAstVisitor {
  bool hasAwait = false;

  @override
  void visitAwaitExpression(AwaitExpression node) {
    hasAwait = true;
  }
}

class _Visitor extends SimpleAstVisitor {
  static const _nameBuildContext = 'BuildContext';
  final Uri _uriFramework;

  final LintRule rule;

  _Visitor(this.rule)
      : _uriFramework = Uri.parse('package:flutter/src/widgets/framework.dart');

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
    var visitor = _AwaitVisitor();
    statement.accept(visitor);
    return visitor.hasAwait;
  }

  /// todo (pq): replace in favor of flutter_utils.isBuildContext
  bool isBuildContext(DartType type) {
    if (type is! InterfaceType) {
      return false;
    }
    var element = type.element;
    return element != null &&
        element.name == _nameBuildContext &&
        element.source.uri == _uriFramework;
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
          // stateContext.mounted => mounted
          while (operand is PrefixedIdentifier) {
            operand = (operand as PrefixedIdentifier).identifier;
          }
          if (operand is SimpleIdentifier) {
            if (operand.name == 'mounted') {
              var then = statement.thenStatement;
              if (then is ReturnStatement) {
                return true;
              }
              if (then is Block) {
                return then.statements.last is ReturnStatement;
              }
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
