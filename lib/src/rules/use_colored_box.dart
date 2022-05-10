// Copyright (c) 2022, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../util/dart_type_utilities.dart';
import '../util/flutter_utils.dart';

const _desc = r'Use `ColoredBox`.';

const _details = r'''

**DO** use `ColoredBox` when `Container` has only a `Color`.

A `Container` is a heavier Widget than a `ColoredBox`, and as bonus,
`ColoredBox` has a `const` constructor.

**BAD:**
```dart
Widget buildArea() {
  return Container(
    color: Colors.blue,
    child: const Text('hello'),
  );
}
```

**GOOD:**
```dart
Widget buildArea() {
  return const ColoredBox(
    color: Colors.blue,
    child: Text('hello'),
  );
}
```
''';

class UseColoredBox extends LintRule {
  UseColoredBox()
      : super(
            name: 'use_colored_box',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this, context);

    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  _Visitor(this.rule, this.context);

  final LintRule rule;
  final LinterContext context;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!isExactWidgetTypeContainer(node.staticType)) {
      return;
    }

    var data = _ArgumentData(node.argumentList, context);

    if (data.additionalArgumentsFound || data.positionalArgumentsFound) {
      return;
    }

    if (data.hasNonNullColor) {
      rule.reportLint(node.constructorName);
    }
  }
}

class _ArgumentData {
  var positionalArgumentsFound = false;
  var additionalArgumentsFound = false;
  var hasNonNullColor = false;

  _ArgumentData(ArgumentList node, LinterContext context) {
    for (var argument in node.arguments) {
      if (argument is! NamedExpression) {
        positionalArgumentsFound = true;
        return;
      }
      var name = argument.name.label.name;
      if (name == 'color') {
        // Not lint if color is null or nullable because a ColoredBox only
        // accepts a non-null Color
        if (DartTypeUtilities.isNonNullable(
            context, argument.expression.staticType)) {
          hasNonNullColor = true;
        }
      } else if (name == 'child') {
        // Ignore child
      } else if (name == 'key') {
        // Ignore key
      } else {
        additionalArgumentsFound = true;
      }
    }
  }
}
