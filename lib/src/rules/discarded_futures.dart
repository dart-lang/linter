// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../analyzer.dart';

const _desc = r"Don't invoke asynchronous functions in non-async blocks.";

const _details = r'''
Making asynchronous calls in non-`async` functions is usually the sign of a
programming error.  In general these functions should be marked `async` and such
futures should likely be awaited (as enforced by `unawaited_futures`).

**DON'T** invoke asynchronous functions in non-`async` blocks.

**BAD:**
```dart
void recreateDir(String path) {
  deleteDir(path);
  createDir(path);
}

Future<void> deleteDir(String path) async {}

Future<void> createDir(String path) async {}
```

**GOOD:**
```dart
Future<void> recreateDir(String path) async {
  await deleteDir(path);
  await createDir(path);
}

Future<void> deleteDir(String path) async {}

Future<void> createDir(String path) async {}
```
''';

class DiscardedFutures extends LintRule {
  DiscardedFutures()
      : super(
            name: 'discarded_futures',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
  }
}

class _InvocationVisitor extends RecursiveAstVisitor<void> {
  final LintRule rule;
  _InvocationVisitor(this.rule);

  @override
  void visitFunctionExpression(FunctionExpression node) {
    if (node.body.isAsynchronous) return;
    super.visitFunctionExpression(node);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    if (node.staticInvokeType.isFuture) {
      rule.reportLint(node.function);
    }
    super.visitFunctionExpressionInvocation(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.staticElement.isDartAsyncUnawaited) return;
    if (node.staticInvokeType.isFuture) {
      rule.reportLint(node.methodName);
    }
    super.visitMethodInvocation(node);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  void check(FunctionBody body) {
    if (body.isAsynchronous) return;
    var visitor = _InvocationVisitor(rule);
    body.accept(visitor);
  }

  @override
  visitFunctionDeclaration(FunctionDeclaration node) {
    check(node.functionExpression.body);
  }

  @override
  visitMethodDeclaration(MethodDeclaration node) {
    check(node.body);
  }
}

extension on DartType? {
  bool get isFuture {
    var self = this;
    if (self is! FunctionType) return false;
    var returnType = self.returnType;
    return returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr;
  }
}

extension ElementExtension on Element? {
  bool get isDartAsyncUnawaited {
    var self = this;
    return self is FunctionElement &&
        self.name == 'unawaited' &&
        self.library.isDartAsync;
  }
}
