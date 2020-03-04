// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/constant/value.dart';

import '../analyzer.dart';

const _desc =
    r"Two constant-valued elements / keys in a set / map literal shouldn't be equal.";

const _details = r'''

Two constant-valued elements / keys in a set / map literal shouldn't be equal.

**BAD:**
```
var mySet = {
  1,
  2,
  1,
};
var myMap = {
  1: 2,
  2: 1,
  1: 2,
};
```

**GOOD:**
```
var mySet = {
  1,
  2,
};
var myMap = {
  1: 2,
  2: 1,
};
```

''';

class DuplicatedKeys extends LintRule implements NodeLintRule {
  DuplicatedKeys()
      : super(
            name: 'duplicated_keys',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry,
      [LinterContext context]) {
    final visitor = _Visitor(this, context);
    registry.addSetOrMapLiteral(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final LintRule rule;
  final LinterContext context;

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) {
    final expressions = node.isSet
        ? node.elements.whereType<Expression>()
        : node.elements.whereType<MapLiteralEntry>().map((e) => e.key);
    final alreadySeen = <DartObject>{};
    for (final expression in expressions) {
      final constEvaluation = context.evaluateConstant(expression);
      if (constEvaluation.errors.isNotEmpty) continue;
      if (!alreadySeen.add(constEvaluation.value)) {
        rule.reportLint(expression);
      }
    }
  }
}
