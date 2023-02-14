// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../extensions.dart';

const _desc = r"Don't use Future.catchError.";

const _details = r'''
**DON'T** call Future.catchError.

TODO explain.

**BAD:**
```dart
Future<Object?> doSomething() {
  return doSomethingAsync().catchError((_) => null);
}

Future<Object?> doSomethingAsync() => Future<Object?>.value(1);
```

**GOOD:**
```dart
Future<Object?> doSomething() {
  return doSomethingAsync().then(
    (Object? obj) => obj,
    onError: (_) => null,
  );
}

Future<Object?> doSomethingAsync() => Future<Object?>.value(1);
```
''';


class AvoidFutureCatchError extends LintRule {
  static const LintCode classCode = LintCode(
      'avoid_future_catcherror', 'Do not use Future.catchError().',
      uniqueName: 'LintCode.avoid_future_catcherror');

  static const LintCode subclassCode = LintCode('avoid_future_catcherror',
      "The type '{0}' should not be caught because it is a subclass of 'Error'.",
      uniqueName: 'LintCode.avoid_catching_errors_subclass');

  AvoidFutureCatchError()
      : super(
            name: 'avoid_future_catcherror',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  List<LintCode> get lintCodes => [classCode, subclassCode];

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name != 'catchError') return;
    var targetType = node.realTarget?.staticType;
    if (targetType == null ||
        !targetType.isDartAsyncFuture) return;
    rule.reportLint(node);
  }
}
