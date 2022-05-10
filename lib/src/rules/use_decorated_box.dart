// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../util/dart_type_utilities.dart';
import '../util/flutter_utils.dart';

const _desc = r'Use `DecoratedBox`.';

const _details = r'''

**DO** use `DecoratedBox` when `Container` has only a `Decoration`.

A `Container` is a heavier Widget than a `DecoratedBox`, and as bonus,
`DecoratedBox` has a `const` constructor.

**BAD:**
```dart
Widget buildArea() {
  return Container(
    decoration: const BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.all(
        Radius.circular(5),
      ),
    ),
    child: const Text('...'),
  );
}
```

**GOOD:**
```dart
Widget buildArea() {
  return const DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.all(
        Radius.circular(5),
      ),
    ),
    child: Text('...'),
  );
}
```
''';

class UseDecoratedBox extends LintRule {
  UseDecoratedBox()
      : super(
            name: 'use_decorated_box',
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

    if (data.hasNonNullDecoration) {
      rule.reportLint(node.constructorName);
    }
  }
}

class _ArgumentData {
  var positionalArgumentsFound = false;
  var additionalArgumentsFound = false;
  var hasNonNullDecoration = false;

  _ArgumentData(ArgumentList node, LinterContext context) {
    for (var argument in node.arguments) {
      if (argument is! NamedExpression) {
        positionalArgumentsFound = true;
        return;
      }
      var name = argument.name.label.name;
      if (name == 'decoration') {
        // Not lint if decoration is null or nullable because a DecoratedBox
        // only accepts a non-null Decoration
        if (DartTypeUtilities.isNonNullable(
            context, argument.expression.staticType)) {
          hasNonNullDecoration = true;
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
