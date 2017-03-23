// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library linter.src.rules.prefer_async_await_over_raw_futures;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:linter/src/analyzer.dart';
import 'package:linter/src/util/dart_type_utilities.dart';

const _desc = r'Prefer async/await over using raw futures.';

const _details = r'''

**PREFER** async/await over using raw futures.

**BAD:**
```
Future<bool> doAsyncComputation() {
  return longRunningCalculation().then((result) {
    return verifyResult(result.summary);
  }).catchError((e) {
    log.error(e);
    return new Future.value(false);
  });
}
```

**GOOD:**
```
Future<bool> doAsyncComputation() async {
  try {
    var result = await longRunningCalculation();
    return verifyResult(result.summary);
  } catch(e) {
    log.error(e);
    return false;
  }
}
```

''';

bool _implementsFuture(DartType dartType) =>
    DartTypeUtilities.implementsInterface(dartType, 'Future', 'dart.async');

bool _isDynamic(DartType dartType) => dartType.name == 'dynamic';

bool _isFunctionExpression(AstNode node) => node is FunctionExpression;

bool _isRelevantMethodInvocation(ReturnStatement returnStatement) {
  final expression = returnStatement.expression;
  if (expression is MethodInvocation) {
    final name = expression.methodName?.name;
    return expression is MethodInvocation &&
        (name == 'then' || name == 'catchError' || name == 'whenComplete') &&
        _implementsFuture(expression.bestType);
  }
  return false;
}

bool _isReturnStatement(AstNode node) => node is ReturnStatement;

class PreferAsyncAwaitOverRawFutures extends LintRule {
  _Visitor _visitor;
  PreferAsyncAwaitOverRawFutures()
      : super(
            name: 'prefer_async_await_over_raw_futures',
            description: _desc,
            details: _details,
            group: Group.style) {
    _visitor = new _Visitor(this);
  }

  @override
  AstVisitor getVisitor() => _visitor;
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;
  _Visitor(this.rule);

  @override
  visitFunctionExpression(FunctionExpression node) {
    if (_implementsFuture(node.element?.returnType) ||
        _isDynamic(node.element?.returnType)) {
      _visitFunctionBody(node.body, node);
    }
  }

  @override
  visitMethodDeclaration(MethodDeclaration node) {
    if (_implementsFuture(node.element?.returnType) ||
        _isDynamic(node.element?.returnType)) {
      _visitFunctionBody(node.body, node);
    }
  }

  _visitFunctionBody(FunctionBody body, AstNode nodeToLint) {
    if (body == null) {
      return;
    }
    final returnsStatements = DartTypeUtilities
        .traverseNodesInDFS(body, excludeCriteria: _isFunctionExpression)
        .where(_isReturnStatement)
        .map((e) => e as ReturnStatement);
    if (returnsStatements.isNotEmpty &&
        returnsStatements.every(_isRelevantMethodInvocation)) {
      rule.reportLint(nodeToLint);
    }
  }
}
