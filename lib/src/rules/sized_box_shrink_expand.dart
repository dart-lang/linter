// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../util/flutter_utils.dart';

const _sizedBoxShrinkDescription =
    r'Use the `SizedBox.shrink(...)` named constructor.';

const _sizedBoxExpandDescription =
    r'Use the `SizedBox.expand(...)` named constructor';

const _details =
    r'''Use `SizedBox.shrink(...)` and `SizedBox.expand(...)` constructors appropriately.

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
            description: 'Use SizedBox shrink and expand named constructors.',
            details: _details,
            group: Group.style) {
    lintCode = LintCode(name, 'Unused');
  }

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);

    registry.addInstanceCreationExpression(this, visitor);
  }

  @override
  late LintCode lintCode;
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
    if (data.width == 0 && data.height == 0) {
      rule.lintCode = LintCode(rule.name, _sizedBoxShrinkDescription);
      rule.reportLint(node.constructorName);
    } else if (data.width == double.infinity &&
        data.height == double.infinity) {
      rule.lintCode = LintCode(rule.name, _sizedBoxExpandDescription);
      rule.reportLint(node.constructorName);
    }
  }
}

class _ArgumentData {
  _ArgumentData(ArgumentList node) {
    for (var argument in node.arguments.cast<NamedExpression>()) {
      if (argument.name.label.name == 'width') {
        var argumentVisitor = _ArgumentVisitor();
        argument.expression.visitChildren(argumentVisitor);
        width = argumentVisitor.argument;
      } else if (argument.name.label.name == 'height') {
        var argumentVisitor = _ArgumentVisitor();
        argument.expression.visitChildren(argumentVisitor);
        height = argumentVisitor.argument;
      }
    }
  }

  double? width;
  double? height;
}

class _ArgumentVisitor extends SimpleAstVisitor {
  double? argument;

  @override
  visitIntegerLiteral(IntegerLiteral node) {
    argument = node.value!.toDouble();
  }

  @override
  visitDoubleLiteral(DoubleLiteral node) {
    argument = node.value;
  }

  @override
  visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name.toLowerCase() == 'infinity') {
      argument = double.infinity;
    }
  }
}
