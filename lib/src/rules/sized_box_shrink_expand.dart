// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../util/flutter_utils.dart';

const _details =
    r'''Use `SizedBox.shrink(...)` and `SizedBox.expand(...)` constructors appropriately.

The `SizedBox.shrink(...)` and `SizedBox.expand(...)` constructors should be used
instead of the more general `SizedBox(...)` constructor when the named constructors
capture the intent of the code more succinctly.

**Examples**

**BAD:**
```dart
Widget buildLogo() {
  return SizedBox(
    height: 0,
    width: 0,
    child: const MyLogo(),
  );
}
```

```dart
Widget buildLogo() {
  return SizedBox(
    height: double.infinity,
    width: double.infinity,
    child: const MyLogo(),
  );
}
```

**GOOD:**
```dart
Widget buildLogo() {
  return SizedBox.shrink(
    child: const MyLogo(),
  );
}
```

```dart
Widget buildLogo() {
  return SizedBox.expand(
    child: const MyLogo(),
  );
}
```
''';

class SizedBoxShrinkExpand extends LintRule {
  static const LintCode code = LintCode(
      'sized_box_shrink_expand',
      "Use 'SizedBox.{0}' to avoid needing to specify the 'height' and "
          "'width'.",
      correctionMessage:
          "Try using 'SizedBox.{0}' and removing the 'height' and 'width' "
          'arguments.');

  SizedBoxShrinkExpand()
      : super(
            name: 'sized_box_shrink_expand',
            description: 'Use SizedBox shrink and expand named constructors.',
            details: _details,
            group: Group.style);

  @override
  LintCode get lintCode => code;

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);

    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _ArgumentData {
  var positionalArgumentFound = false;

  double? width;

  double? height;
  _ArgumentData(ArgumentList node) {
    for (var argument in node.arguments) {
      if (argument is! NamedExpression) {
        positionalArgumentFound = true;
        return;
      }
      var label = argument.name.label;
      if (label.name == 'width') {
        width = _argumentValue(argument.expression);
      } else if (label.name == 'height') {
        height = _argumentValue(argument.expression);
      }
    }
  }
  double? _argumentValue(Expression argument) {
    if (argument is IntegerLiteral) {
      return argument.value?.toDouble();
    } else if (argument is DoubleLiteral) {
      return argument.value;
    } else if (argument is PrefixedIdentifier &&
        argument.identifier.name == 'infinity' &&
        argument.prefix.name == 'double') {
      return double.infinity;
    }
    return null;
  }
}

class _Visitor extends SimpleAstVisitor {
  final SizedBoxShrinkExpand rule;

  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // Only interested in the default constructor for the SizedBox widget
    if (!isExactWidgetTypeSizedBox(node.staticType) ||
        node.constructorName.name != null) {
      return;
    }

    var data = _ArgumentData(node.argumentList);
    if (data.positionalArgumentFound) {
      return;
    }
    if (data.width == 0 && data.height == 0) {
      rule.reportLint(node.constructorName, arguments: ['shrink']);
    } else if (data.width == double.infinity &&
        data.height == double.infinity) {
      rule.reportLint(node.constructorName, arguments: ['expand']);
    }
  }
}
