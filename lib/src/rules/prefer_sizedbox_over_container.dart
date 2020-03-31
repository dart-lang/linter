// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../util/flutter_utils.dart';

const _desc = r'Prefer SizedBox over Container.';

const _details = r'''Prefer SizedBox over Container for introducing blank space.

A `Container` is a heavier Widget than a `SizedBox`, and as bonus, `SizedBox` 
has a `const` constructor.

**BAD:**
```
Widget buildRow() {
  return Row(
    children: <Widget>[
      const MyLogo(),
      Container(width: 4),
      const Expanded(
        child: Text('...'),
      ),
    ],
  );
}
```

**GOOD:**
```
Widget buildRow() {
  return Row(
    children: const <Widget>[
      MyLogo(),
      SizedBox(width: 4),
      Expanded(
        child: Text('...'),
      ),
    ],
  );
}
```
''';

class PreferSizedBoxOverContainer extends LintRule implements NodeLintRule {
  PreferSizedBoxOverContainer()
      : super(
            name: 'prefer_sizedbox_over_container',
            description: _desc,
            details: _details,
            group: Group.style);

  @override
  void registerNodeProcessors(NodeLintRegistry registry,
      [LinterContext context]) {
    final visitor = _Visitor(this);

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

    final visitor = _WidthOrHeightArgumentVisitor();
    node.visitChildren(visitor);
    if (visitor.seenWidthOrHeight && !visitor.seenOtherParams) {
      rule.reportLint(node.constructorName);
    }
  }
}

class _WidthOrHeightArgumentVisitor extends SimpleAstVisitor<void> {
  var seenWidthOrHeight = false;
  var seenOtherParams = false;

  @override
  void visitArgumentList(ArgumentList node) {
    for (final arg in node.arguments) {
      if (arg is NamedExpression &&
          (arg.name.label.name == 'width' || arg.name.label.name == 'height')) {
        seenWidthOrHeight = true;
      } else {
        seenOtherParams = true;
      }
    }
  }
}
