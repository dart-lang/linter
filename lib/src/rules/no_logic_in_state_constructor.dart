// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../analyzer.dart';
import '../util/flutter_utils.dart';

const _desc = r"Don't put any logic in the state constructor.";

const _details = r'''
**DON'T** put any logic in the `State` constructor.

The constructor of a `State` object should never contain any logic as it often
causes trouble. That logic should always go into `State.initState()`.

**BAD:**
```dart
class FooState extends State<Foo> with SingleTickerProviderStateMixin {
  FooState() {
   _controller = AnimationController(vsync: this);
  }

  late final AnimationController _controller;
}
```

**GOOD:**
```dart
class FooState extends State<Foo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
}
```

**GOOD:**
```dart
class FooState extends State<Foo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }
}
```
''';

class NoLogicInStateConstructor extends LintRule {
  NoLogicInStateConstructor()
      : super(
            name: 'no_logic_in_state_constructor',
            description: _desc,
            details: _details,
            group: Group.errors);

  @override
  void registerNodeProcessors(
      NodeLintRegistry registry, LinterContext context) {
    var visitor = _Visitor(this);
    registry.addConstructorDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor {
  final LintRule rule;

  _Visitor(this.rule);

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    var declaredElement = node.declaredElement;
    if (declaredElement == null) return;
    if (isState(
        declaredElement.enclosingElement.thisType.superclass?.element)) {
      var body = node.body;
      if (body is BlockFunctionBody) {
        var block = body.block;
        if (block.statements.isNotEmpty) {
          rule.reportLint(block);
        }
      }
    }
  }
}
