// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../util/flutter_utils.dart';

const _desc = r'SizedBox shrink and expand.';

const _details =
    r'''Use SizedBox.shrink and SizedBox.expand constructors appropriately.

The `SizedBox.shrink(...)` and `SizedBox.expand(...)` constructors should be used
instead of the more general `SizedBox(...)` constructor for specific use cases. 

**Examples**

**BAD:**
```
Widget buildLogo() {
  return SizedBox(
    height: 0,
    width: 0,
    child:const MyLogo(),
  );
}
```

```
Widget buildLogo() {
  return SizedBox(
    height: double.infinity,
    width: double.infinity,
    child:const MyLogo(),
  );
}
```


**GOOD:**
```
Widget buildLogo() {
  return SizedBox.shrink(
    child:const MyLogo(),
  );
}
```

```
Widget buildLogo() {
  return SizedBox.expand(
    child:const MyLogo(),
  );
}
```
''';

class SizedBoxShrinkExpand extends LintRule {
  SizedBoxShrinkExpand()
      : super(
            name: 'sized_box_shrink_expand',
            description: _desc,
            details: _details,
            group: Group.style);

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

    var visitor = _WidthOrHeightArgumentVisitor();
    node.visitChildren(visitor);
    if (visitor.seenIncompatibleParams) {
      return;
    }
    if (visitor.seenChild && (visitor.seenWidth || visitor.seenHeight) ||
        visitor.seenWidth && visitor.seenHeight) {
      rule.reportLint(node.constructorName);
    }
  }
}

class _WidthOrHeightArgumentVisitor extends SimpleAstVisitor<void> {
  var seenWidth = false;
  var seenHeight = false;
  var seenChild = false;
  var seenIncompatibleParams = false;

  @override
  void visitArgumentList(ArgumentList node) {
    for (var name in node.arguments
        .cast<NamedExpression>()
        .map((arg) => arg.name.label.name)) {
      if (name == 'width') {
        seenWidth = true;
      } else if (name == 'height') {
        seenHeight = true;
      } else if (name == 'child') {
        seenChild = true;
      } else if (name == 'key') {
        // key doesn't matter (both SiezdBox and Container have it)
      } else {
        seenIncompatibleParams = true;
      }
    }
  }
}
