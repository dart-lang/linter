// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import '../analyzer.dart';

const _desc = r'Missing deprecated annotation.';

const _details = r'''

Do apply `@Deprecated()` consistently:

- if a class is deprecated, its constructors should also be deprecated.
- if a field is deprecated, the constructor parameter pointing to it should also be deprecated.
- if a constructor parameter pointing to a field is deprecated, the field should also be deprecated.

**BAD:**
```dart
@deprecated
class A {
  A();
}

class B {
  B({this.field});
  @deprecated
  Object field;
}
```

**GOOD:**
```dart
@deprecated
class A {
  @deprecated
  A();
}

class B {
  B({@deprecated this.field});
  @deprecated
  Object field;
}
```

''';

class DeprecatedConsistency extends LintRule {
  DeprecatedConsistency()
      : super(
          name: 'deprecated_consistency',
          description: _desc,
          details: _details,
          group: Group.style,
        );

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addConstructorDeclaration(this, visitor);
    registry.addFieldFormalParameter(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    var constructorElement = node.declaredElement;
    if (constructorElement != null &&
        constructorElement.enclosingElement2.hasDeprecated &&
        !constructorElement.hasDeprecated) {
      rule.reportLint(node);
    }
  }

  @override
  void visitFieldFormalParameter(FieldFormalParameter node) {
    var declaredElement = node.declaredElement;
    if (declaredElement is! FieldFormalParameterElement) return;

    var field = declaredElement.field;
    if (field == null) return;

    if (field.hasDeprecated && !declaredElement.hasDeprecated) {
      rule.reportLint(node);
    }
    if (!field.hasDeprecated && declaredElement.hasDeprecated) {
      rule.reportLintForOffset(field.nameOffset, field.nameLength);
    }
  }
}
