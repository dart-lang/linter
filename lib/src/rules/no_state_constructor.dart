// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../util/flutter_utils.dart';

const _desc = r"Don't define constructors on State subclasses.";

const _details = r'''
**DON'T** define constructors on State subclasses.

Avoid passing data to `State` objects using custom constructor parameters.
Prefer accessing state via the `widget` field.

**BAD:**
```
class MyStateful extends StatefulWidget {
  const MyStateful({Key key, this.props}): super(key: key);

  final int props;

  MyStatefulState createState() {
    return MyStatefulState(props);
  }
}

class MyStatefulState extends State<MyStateful> {
  MyStatefulState(this.props);

  int props;

  @override
  Widget build(BuildContext context) {
    return Text('$props');
  }
}
```

**GOOD:**
```
class MyStateful extends StatefulWidget {
  const MyStateful({Key key, this.props}): super(key: key);

  final int props;

  MyStatefulState createState() => MyStatefulState();
}

class MyStatefulState extends State<MyStateful> {
  Widget build(BuildContext context) {
    return Text('${widget.props}');
  }
}
```
''';

class NoStateConstructor extends LintRule implements NodeLintRule {
  NoStateConstructor() 
      : super(
            name: 'no_state_constructor',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  void registerNodeProcessors(NodeLintRegistry registry, [LinterContext context]) {
    final visitor = _Visitor(this);
    registry.addConstructorDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  visitConstructorDeclaration(ConstructorDeclaration node) {
    final parent = node.parent;
    if (parent is ClassDeclaration) {
      // ignore: deprecated_member_use
      final type = parent.declaredElement.type;
      if (isStateType(type)) {
        rule.reportLint(node);
      }
    }
  }
}
