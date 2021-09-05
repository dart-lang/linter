// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../analyzer.dart';

const _desc = r'Tighten type of initializing formal.';

const _details = r'''

Tighten type of initializing formal if a non-null assert exists. This allows the
type system to catch problems rather than have them only be caught at run-time.

**BAD:**
```dart
class A {
  A.c1(this.p) : assert(p != null);
  A.c2(this.p);
  final String? p;
}
```

**GOOD:**
```dart
class A {
  A.c1(String this.p) : assert(p != null);
  A.c2(this.p);
  final String? p;
}
```

''';

class TightenTypeOfInitializingFormals extends LintRule {
  TightenTypeOfInitializingFormals()
      : super(
          name: 'tighten_type_of_initializing_formals',
          description: _desc,
          details: _details,
          group: Group.style,
        );

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    if (!context.isEnabled(Feature.non_nullable)) {
      return;
    }

    var visitor = _Visitor(this, context);
    registry.addConstructorDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final LintRule rule;
  final LinterContext context;

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    node.initializers
        .whereType<AssertInitializer>()
        .map((e) => e.condition)
        .whereType<BinaryExpression>()
        .where((e) => e.operator.type == TokenType.BANG_EQ)
        .map((e) => e.rightOperand is NullLiteral
            ? e.leftOperand
            : e.leftOperand is NullLiteral
                ? e.rightOperand
                : null)
        .whereType<Identifier>()
        .where((e) {
          var staticType = e.staticType;
          return staticType != null &&
              context.typeSystem.isNullable(staticType);
        })
        .map((e) => e.staticElement)
        .whereType<FieldFormalParameterElement>()
        .forEach((e) {
          rule.reportLint(node.parameters.parameters
              .firstWhere((p) => p.declaredElement == e));
        });
  }
}
