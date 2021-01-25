// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../analyzer.dart';

const _desc = r'Use predefined const.';

const _details = r'''

Use already defined const value.

**BAD:**
```
const Duration(seconds: 0);
```

**GOOD:**
```
Duration.zero;
```

''';
const lintName = 'use_named_const';

class UseNamedConst extends LintRule implements NodeLintRule {
  UseNamedConst()
      : super(
          name: lintName,
          description: _desc,
          details: _details,
          group: Group.style,
        );

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    final visitor = _Visitor(this, context);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final LintRule rule;
  final LinterContext context;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.isConst) {
      final library = (node.root as CompilationUnit).declaredElement.library;
      final nodeField =
          node.thisOrAncestorOfType<VariableDeclaration>()?.declaredElement;

      final value = context.evaluateConstant(node).value;
      final element = node.staticType.element;
      if (element is ClassElement) {
        for (final field
            in element.fields.where((e) => e.isStatic && e.isConst)) {
          if (field != nodeField &&
              field.computeConstantValue() == value &&
              (field.isPublic || field.library == library)) {
            rule.reportLint(node,
                arguments: ['${element.name}.${field.name}'],
                errorCode: const LintCode(
                    lintName, "Try using the predefined constant '{0}'."));
            return;
          }
        }
      }
    }
  }
}
