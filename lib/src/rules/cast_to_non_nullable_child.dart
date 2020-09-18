// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = r"Don't cast a nullable value to a non nullable subtype.";

const _details = r'''

Don't cast a nullable value to a non nullable subtype. This hides a null check
and most of the time it is not what is expected.

**BAD:**
```
class A {}
class B extends A {}

A? a;
var v = a as B;
```

**GOOD:**
```
class A {}
class B extends A {}

A? a;
var v = a! as B;
var v = a as B?;
```

''';

class CastToNonNullableChild extends LintRule implements NodeLintRule {
  CastToNonNullableChild()
      : super(
          name: 'cast_to_non_nullable_child',
          description: _desc,
          details: _details,
          group: Group.style,
        );

  @override
  void registerNodeProcessors(NodeLintRegistry registry,
      [LinterContext context]) {
    final visitor = _Visitor(this, context);
    registry.addCompilationUnit(this, visitor);
    registry.addAsExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final LintRule rule;
  final LinterContext context;

  bool _isNonNullableEnabled;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    _isNonNullableEnabled = node.featureSet.isEnabled(Feature.non_nullable);
  }

  @override
  void visitAsExpression(AsExpression node) {
    if (!_isNonNullableEnabled) return;

    final expressionType = node.expression.staticType;
    final type = node.type.type;
    if (!expressionType.isDynamic &&
        context.typeSystem.isNullable(expressionType) &&
        context.typeSystem.isNonNullable(type) &&
        context.typeSystem.isSubtypeOf(
            type, context.typeSystem.promoteToNonNull(expressionType))) {
      rule.reportLint(node);
    }
  }
}
