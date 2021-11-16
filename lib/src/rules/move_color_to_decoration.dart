// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../util/flutter_utils.dart';

const _desc = r'Move color to decoration.';

const _details = r'''Don't provide `Container` with both non-null `color` and
`decoration`. Place `color` inside `decoration` instead.

**BAD:**
```dart
Widget buildArea() {
  return Container(
    color: Colors.black,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white),
    ),
  );
}
```

**GOOD:**
```dart
Widget buildArea() {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white),
      color: Colors.black,
    ),
  );
}
```
''';

class MoveColorToDecoration extends LintRule {
  MoveColorToDecoration()
      : super(
            name: 'move_color_to_decoration',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);

    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!isExactWidgetTypeContainer(node.staticType)) {
      return;
    }

    var data = _ArgumentData(node.argumentList);

    if (data.wasPositionalArgumentFound) {
      return;
    }

    if (data.hasColor && data.hasDecoration) {
      rule.reportLint(node.constructorName);
    }
  }
}

class _ArgumentData {
  var wasPositionalArgumentFound = false;
  var hasColor = false;
  var hasDecoration = false;

  _ArgumentData(ArgumentList node) {
    for (var argument in node.arguments) {
      if (argument is! NamedExpression) {
        wasPositionalArgumentFound = true;
        return;
      }
      var label = argument.name.label;
      if (label.name == 'color' && argument.expression is! NullLiteral) {
        hasColor = true;
      } else if (label.name == 'decoration' &&
          argument.expression is! NullLiteral) {
        hasDecoration = true;
      }
    }
  }
}
