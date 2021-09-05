// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';

const _desc = "Don't type annotate initializing formals.";

const _details = r'''

From the [style guide](https://dart.dev/guides/language/effective-dart/style/):

**DON'T** type annotate initializing formals.

If a constructor parameter is using `this.x` to initialize a field, then the
type of the parameter is understood to be the same type as the field.

**GOOD:**
```dart
class Point {
  int x, y;
  Point(this.x, this.y);
}
```

**BAD:**
```dart
class Point {
  int x, y;
  Point(int this.x, int this.y);
}
```

''';

class TypeInitFormals extends LintRule {
  TypeInitFormals()
      : super(
            name: 'type_init_formals',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addFieldFormalParameter(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitFieldFormalParameter(FieldFormalParameter node) {
    var nodeType = node.type;
    if (nodeType != null) {
      var cls = node.thisOrAncestorOfType<ClassDeclaration>()?.declaredElement;
      if (cls != null) {
        var field = cls.getField(node.identifier.name);
        // If no such field exists, the code is invalid; do not report lint.
        if (field != null) {
          if (nodeType.type == field.type) {
            rule.reportLint(nodeType);
          }
        }
      }
    }
  }
}
